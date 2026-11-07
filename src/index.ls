module.exports =
  pkg:
    name: 'bar-race', version: '0.0.1'
    # lite: 不帶 d3 的 base ( 見 @plotdb/chart utils )
    extend: {name: "@makechart/base", path: "lite/index.html"}
    dependencies: []
    i18n:
      "zh-TW":
        "order": "順序"
        "value": "數值"
        "name": "名稱"
  init: ({root, context, t, pubsub}) ->
    pubsub.fire \init, mod: mod({context, t})

svgns = "http://www.w3.org/2000/svg"

# 以 order 為時間軸, 每個 order 是一格. 畫面完全由播放位置決定 ( 數值與名次都在相鄰兩格之間內插 ),
# 所以同一個播放位置永遠畫出一樣的東西 - 逐格錄影時用 chart.anim 的 manual 時鐘推進即可.
mod = ({context, t}) ->
  {chart} = context
  {scale: Scale, format, anim: {join}} = chart.utils
  # 依目前的播放位置畫一格 ( mod 的方法以 chart 為 this 執行, 自訂的函式要自己 apply )
  draw = ->
    if !@orders or !@orders.length => return
    {table, ranks, names, cfg, tint} = @
    dur = cfg.duration or 1000
    last = @orders.length - 1
    pos = Math.min(@playhead / dur, last)
    i = Math.floor pos
    j = Math.min(i + 1, last)
    f = pos - i
    lerp = (a, b) -> a + (b - a) * f
    top = cfg.top or 10
    box = @layout.get-box \view
    bh = box.height / top
    gap = cfg.gap or 0
    items = []
    for n from 0 til names.length =>
      r = lerp ranks[i][n], ranks[j][n]
      # 擠出前 top 名的漸漸淡出, 進來的從下面滑上來
      if r > top => continue
      items.push {name: names[n], idx: n, value: lerp(table[n][i], table[n][j]), rank: r}
    max = Math.max.apply(Math, [0] ++ items.map -> it.value) or 1
    fmt = format.from(cfg.label.format or '.3s')
    @scale.x.domain([0, max]).range([0, box.width])
    xs = @scale.x.ticks(Math.max(2, Math.floor(box.width / 80)))
    @xaxis.config cfg.xaxis
    @xaxis.ticks xs
    @xaxis.scale @scale.x
    @xaxis.render!

    bj = join root: @g.bars, tag: \g, cls: \bar, data: items, key: (d) -> d.name
    bj.enter.map (n) ->
      n.appendChild document.createElementNS(svgns, \rect)
        ..setAttribute \class, \data
      n.appendChild document.createElementNS(svgns, \text)
        ..setAttribute \class, \name
        ..setAttribute \text-anchor, \end
        ..setAttribute \dominant-baseline, \central
        ..setAttribute \fill, \#fff
      n.appendChild document.createElementNS(svgns, \text)
        ..setAttribute \class, \value
        ..setAttribute \dominant-baseline, \central
        ..setAttribute \fill, \currentColor
    bj.nodes.map (n) ~>
      d = n.__data__
      w = Math.max(0, @scale.x d.value)
      h = Math.max(1, bh - gap)
      n.setAttribute \transform, "translate(0,#{d.rank * bh})"
      n.setAttribute \opacity, Math.max(0, Math.min(1, top - d.rank))
      [rect, name, value] = n.childNodes
      rect.__data__ = d <<< {_raw: {name: d.name, value: d.value}}
      rect.setAttribute \width, w
      rect.setAttribute \height, h
      rect.setAttribute \fill, tint.get(d.name)
      name.setAttribute \x, w - 4
      name.setAttribute \y, h / 2
      name.setAttribute \font-size, Math.min(14, h * 0.6)
      name.textContent = d.name
      # 長條太短放不下名字就整個藏起來, 數值照樣放在右邊
      name.setAttribute \opacity, if w > 60 => 1 else 0
      value.setAttribute \x, w + 4
      value.setAttribute \y, h / 2
      value.setAttribute \font-size, Math.min(12, h * 0.5)
      value.textContent = fmt(d.value)
    @g.order
      ..setAttribute \x, box.width - 8
      ..setAttribute \y, box.height - 8
      ..setAttribute \font-size, Math.min(64, box.height / 5)
      ..textContent = @orders[if f < 0.5 => i else j]

  sample: ->
    names = <[Apple Banana Cherry Durian Elderberry Fig Grape Honeydew]>
    acc = names.map -> 0
    raw: [].concat.apply [], [0 til 12].map (o) ->
      names.map (n, i) ->
        acc[i] += Math.round(Math.random! * 100)
        {name: n, value: acc[i], order: 2000 + o}
    binding:
      order: {key: "order"}
      value: {key: "value"}
      name: {key: "name"}
  config: {
    xaxis: JSON.parse(JSON.stringify(chart.utils.config.preset.axis))
  } <<< chart.utils.config.preset.default <<<
    top: type: \number, default: 10, min: 1, max: 50, step: 1
    # 每一格 ( 一個 order ) 播放的時間, ms
    duration: type: \number, default: 1000, min: 100, max: 10000, step: 100
    autoplay: type: \boolean, default: true
    loop: type: \boolean, default: true
    gap: type: \number, default: 2, min: 0, max: 20, step: 1
    label: format: type: \format, default: \.3s
  dimension:
    order: {type: \O, name: "order", priority: 1}
    value: {type: \R, name: "value", priority: 2}
    name: {type: \N, name: "name"}
  init: ->
    @tint = new chart.utils.tint!
    @g = Object.fromEntries <[view xaxis]>.map ~> [it, @layout.get-group it]
    @g.bars = @g.view.appendChild document.createElementNS(svgns, \g)
    @g.order = @g.view.appendChild document.createElementNS(svgns, \text)
      ..setAttribute \class, \order
      ..setAttribute \text-anchor, \end
      ..setAttribute \fill, \currentColor
      ..setAttribute \opacity, 0.3
    @xaxis = new chart.utils.axis layout: @layout, name: \xaxis, direction: \bottom
    @scale = x: Scale.linear!
    @playhead = 0
    @start!

  parse: ->
    num = (v) -> if isNaN(+v) => 0 else +v
    # order 依值排序 ( 全是數字就照數字排 ), 每一格是 name -> value 的表
    os = Array.from(new Set(@data.map -> it.order))
    if os.every(-> !isNaN(+it)) => os.sort (a, b) -> +a - +b else os.sort!
    @orders = os
    @names = Array.from(new Set(@data.map -> it.name))
    oidx = Object.fromEntries os.map (o, i) -> [o, i]
    nidx = Object.fromEntries @names.map (n, i) -> [n, i]
    @table = @names.map -> os.map -> null
    @data.map (d) ~> @table[nidx[d.name]][oidx[d.order]] = num(d.value)
    # 某一格缺值就沿用前一格 ( 沒有前一格算 0 ), 免得長條在缺資料的那一格掉到 0 再彈回來
    @table.map (row) -> for i from 0 til row.length => if !(row[i]?) => row[i] = if i => row[i - 1] else 0
    # 各格的名次 ( 0 = 第一名 ). 同值依名稱出現順序
    @ranks = os.map (o, i) ~>
      idx = [0 til @names.length].sort (a, b) ~> (@table[b][i] - @table[a][i]) or (a - b)
      r = []
      idx.map (n, k) -> r[n] = k
      r

  resize: ->
    @tint.set @cfg.palette
    @layout.update false

  render: -> draw.apply @

  # 播放位置只靠 dt 累加: realtime 時是 rAF 的間隔, 錄影 ( manual ) 時是 step 的 dt, seek 時是 0
  tick: (t, dt = 0) ->
    if !@cfg.autoplay or !@orders or @orders.length < 2 => return
    dur = @cfg.duration or 1000
    # 最後一格停一格的時間再重來
    span = @orders.length * dur
    @playhead += dt
    if @playhead >= span => @playhead = if @cfg.loop => @playhead % span else span - dur
    draw.apply @
