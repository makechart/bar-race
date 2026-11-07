# bar-race 的 test case ( @makechart/viewer 的 mctest )
rnd = mctest.random 5
names = <[Apple Banana Cherry Durian Elderberry Fig Grape Honeydew Kiwi Lemon Mango Nectarine]>
race = do ->
  acc = names.map -> 0
  raw: [].concat.apply [], [0 til 8].map (o) ->
    names.map (n, i) ->
      acc[i] += Math.round(rnd! * 100)
      {name: n, value: acc[i], order: 2000 + o}
  binding: {order: {key: \order}, value: {key: \value}, name: {key: \name}}

# 用 anim 的 manual 時鐘推進播放位置 ( 每步 1000/30 ms )
play = (ms) -> (c) -> for i from 0 til Math.round(ms * 30 / 1000) => c.anim.step 1000 / 30

mctest.suite do
  size: [560, 360]
  data: {race}
  cases:
    * name: "start"
    * name: "top:5", config: {top: 5}
    * name: "play"
      steps:
        * (c, ctx) -> (play 500) c; ctx.snap \half-frame
        * (c, ctx) -> (play 1500) c; ctx.snap \two-frames
        * play 6000
    * name: "no-loop", config: {loop: false}, steps: [play 12000]
    * name: "autoplay:off", config: {autoplay: false}, steps: [play 3000]
