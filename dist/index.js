(function(){
  var mod;
  module.exports = {
    pkg: {
      name: 'bar-race',
      version: '0.0.1',
      extend: {
        name: "base",
        version: "0.0.1"
      },
      dependencies: [],
      i18n: {
        "zh-TW": {
          "height": "高度"
        }
      }
    },
    init: function(arg$){
      var root, context, t, pubsub;
      root = arg$.root, context = arg$.context, t = arg$.t, pubsub = arg$.pubsub;
      return pubsub.fire('init', {
        mod: mod({
          context: context,
          t: t
        })
      });
    }
  };
  mod = function(arg$){
    var context, t, chart, d3, debounce;
    context = arg$.context, t = arg$.t;
    chart = context.chart, d3 = context.d3, debounce = context.debounce;
    return {
      sample: function(){
        return {
          raw: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100].map(function(val){
            var ref$, n, o, ret;
            ref$ = [val % 10, Math.floor(val / 10)], n = ref$[0], o = ref$[1];
            ret = {
              name: n,
              value: Math.random(),
              order: o
            };
            return ret;
          }),
          binding: {
            order: {
              key: "order"
            },
            value: {
              key: "value"
            },
            name: {
              key: "name"
            }
          }
        };
      },
      config: {},
      dimension: {
        order: {
          type: 'O',
          name: "order",
          priority: 1
        },
        value: {
          type: 'R',
          name: "value",
          priority: 2
        },
        name: {
          type: 'N',
          name: "name"
        }
      },
      init: function(){
        var tint, scale;
        this.tint = tint = new chart.utils.tint();
        this.g = {
          view: d3.select(this.layout.getGroup('view')),
          axis: d3.select(this.layout.getGroup('axis'))
        };
        this.scale = scale = {};
        this.axisBottom = d3.axisBottom();
        return this.legend = new chart.utils.legend({
          layout: this.layout,
          name: 'legend',
          root: this.root,
          shape: function(d){
            return d3.select(this).attr('fill', tint.get(d.key));
          }
        });
      },
      parse: function(){
        this.data.map(function(d){
          return d.value = d.value.map(function(it){
            if (isNaN(it)) {
              return 0;
            } else {
              return +it;
            }
          });
        });
        return this.names = Array.from(new Set(this.data.map(function(it){
          return it.name;
        })));
      },
      resize: function(){
        var ref$, i, max, box, this$ = this;
        this.layout.getNode('legend').style.width = !(((ref$ = this.cfg).legend || (ref$.legend = {})).enabled != null) || this.cfg.legend.enabled ? '' : '0';
        this.layout.update(false);
        this.maxPerGroup = this.binding.height.map(function(d, i){
          return Math.max.apply(Math, this$.data.map(function(it){
            return it.height[i];
          }));
        });
        this.order = this.data.map(function(d, i){
          return {
            key: d._idx,
            idx: i,
            name: d.order
          };
        });
        this.order.sort(function(a, b){
          if (b.name > a.name) {
            return 1;
          } else if (b.name < a.name) {
            return -1;
          } else {
            return 0;
          }
        });
        this.tint.set(this.cfg.palette);
        this.legend.data((function(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = this.names.length; i$ < to$; ++i$) {
            i = i$;
            results$.push({
              key: i,
              text: this.names[i]
            });
          }
          return results$;
        }.call(this)));
        this.layout.update(false);
        max = Math.max(this.data.map(function(it){
          return it.value;
        }));
        box = this.layout.getBox('view');
        return ref$ = this.scale, ref$.y = d3.scaleLinear().domain([0, max]).range([box.width, 0]), ref$.x = d3.scaleBand().domain(this.order.map(function(it){
          return it.name || it.key;
        })).range([0, box.height]), ref$;
      },
      render: function(){
        var binding, scale, range, delta, cfg, tint, data, x$;
        binding = this.binding, scale = this.scale, range = this.range, delta = this.delta, cfg = this.cfg, tint = this.tint, data = this.data;
        x$ = this.g.view.selectAll('g.bar').data(this.data);
        x$.exit().remove();
        x$.enter().append('g').attr('class', 'bar');
        this.g.view.selectAll('g.bar').attr('transform', function(d, i){
          return "translate(" + scale.x(d.name) + ",0)";
        });
        return this.g.axis.call(this.axisBottom).attr('font-size', '');
      },
      tick: function(){}
    };
  };
}).call(this);
