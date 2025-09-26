module.exports =
  pkg:
    name: 'bar-race', version: '0.0.1'
    extend: {name: "@makechart/base"}
    dependencies: []
    i18n:
      "zh-TW":
        "height": "高度"
  init: ({root, context, t, pubsub}) ->
    pubsub.fire \init, mod: mod({context, t})

mod = ({context, t}) ->
  {chart,d3,debounce} = context
  sample: ->
    raw: [0 to 100].map (val) ~>
      [n,o] = [val % 10, Math.floor(val / 10)]
      ret = {name: n, value: Math.random!, order: o}
      return ret
    binding:
      order: {key: "order"}
      value: {key: "value"}
      name: {key: "name"}
  config: {}
  dimension:
    order: {type: \O, name: "order", priority: 1}
    value: {type: \R, name: "value", priority: 2}
    name: {type: \N, name: "name"}
  init: ->
    @tint = tint = new chart.utils.tint!
    @g =
      view: d3.select(@layout.get-group \view)
      axis: d3.select(@layout.get-group \axis)
    @scale = scale = {}
    @axis-bottom = d3.axis-bottom!
    @legend = new chart.utils.legend do
      layout: @layout
      name: \legend
      root: @root
      shape: (d) -> d3.select(@).attr \fill, tint.get d.key
  parse: ->
    @data.map (d) -> d.value = d.value.map -> if isNaN(it) => 0 else +it
    @names = Array.from(new Set(@data.map -> it.name))
  resize: ->
    @layout.get-node \legend .style.width = if !(@cfg.{}legend.enabled?) or @cfg.legend.enabled => '' else '0'
    @layout.update false

    @max-per-group = @binding.height.map (d,i) ~> Math.max.apply(Math, @data.map -> it.height[i])
    @order = @data.map (d,i) -> {key: d._idx, idx: i, name: d.order}
    @order.sort (a,b) -> if b.name > a.name => 1 else if b.name < a.name => -1 else 0

    @tint.set @cfg.palette
    @legend.data [{ key: i, text: @names[i] } for i from 0 til @names.length]
    @layout.update false
    max = Math.max @data.map -> it.value

    box = @layout.get-box \view
    @scale <<<
      y: d3.scaleLinear!domain([0,max]).range [box.width, 0]
      x: d3.scaleBand!domain @order.map(->it.name or it.key) .range [0, box.height]
    /*
    @axis-bottom.scale @scale.x
      ..ticks(@cfg.tick.count) if @cfg.tick.count?
      ..tickFormat(d3.format(@cfg.tick-format)) if @cfg.tick-format?
      ..tickSizeInner @cfg.tick-size-inner if @cfg.tick-size-inner?
      ..tickSizeOuter @cfg.tick-size-outer if @cfg.tick-size-outer?
      ..tickPadding @cfg.tick-padding if @cfg.tick-padding?
    */

  render: ->
    {binding, scale, range, delta, cfg, tint, data} = @
    @g.view.selectAll \g.bar .data @data
      ..exit!remove!
      ..enter!append \g .attr \class, \bar
    @g.view.selectAll \g.bar
      .attr \transform, (d,i) -> "translate(#{scale.x(d.name)},0)"

    @g.axis.call @axis-bottom
      .attr \font-size, ''
  tick: ->
