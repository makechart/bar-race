# Change Logs

## v0.0.2

 - rewrite: it couldn't run before. bars and ranks interpolate between adjacent orders by a playhead,
   so the same playhead always draws the same frame. add config `top`, `duration`, `autoplay`, `loop`, `gap`,
   `label.format` and `xaxis`
 - extend the lite base ( `@makechart/base` `lite/index.html`, no d3 ): needs `@makechart/base` >= 0.2.0
   and `@plotdb/chart` >= 3.7.0. scales / shapes / transitions use `chart.utils`, and transitions run on
   `chart.anim`, so animation can be recorded frame by frame ( `anim.manual` / `step` )
 - add test cases ( `test/index.ls`, run with `npm test` via `@makechart/viewer` )


## v0.0.1

init release
