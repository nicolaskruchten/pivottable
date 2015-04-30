(function() {
  var callWithJQuery;

  callWithJQuery = function(pivotModule) {
    if (typeof exports === "object" && typeof module === "object") {
      return pivotModule(require("jquery"));
    } else if (typeof define === "function" && define.amd) {
      return define(["jquery"], pivotModule);
    } else {
      return pivotModule(jQuery);
    }
  };

  callWithJQuery(function($) {
    var makeC3Chart;
    makeC3Chart = function(chartOpts) {
      if (chartOpts == null) {
        chartOpts = {};
      }
      return function(pivotData, opts) {
        var agg, colKey, colKeys, columns, dataArray, datum, defaults, fullAggName, h, hAxisTitle, headers, params, renderArea, result, row, rowHeader, rowKey, rowKeys, tree2, vAxisTitle, x, y, _i, _j, _len, _len1, _ref;
        defaults = {
          localeStrings: {
            vs: "vs",
            by: "by"
          }
        };
        opts = $.extend(defaults, opts);
        if (chartOpts.type == null) {
          chartOpts.type = "line";
        }
        rowKeys = pivotData.getRowKeys();
        if (rowKeys.length === 0) {
          rowKeys.push([]);
        }
        colKeys = pivotData.getColKeys();
        if (colKeys.length === 0) {
          colKeys.push([]);
        }
        headers = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = colKeys.length; _i < _len; _i++) {
            h = colKeys[_i];
            _results.push(h.join("-"));
          }
          return _results;
        })();
        fullAggName = pivotData.aggregatorName;
        if (pivotData.valAttrs.length) {
          fullAggName += "(" + (pivotData.valAttrs.join(", ")) + ")";
        }
        if (chartOpts.type === "scatter") {
          dataArray = [];
          hAxisTitle = pivotData.colAttrs.join("-");
          vAxisTitle = pivotData.rowAttrs.join("-");
          _ref = pivotData.tree;
          for (y in _ref) {
            tree2 = _ref[y];
            for (x in tree2) {
              agg = tree2[x];
              datum = {};
              datum[hAxisTitle] = parseFloat(x);
              datum[vAxisTitle] = parseFloat(y);
              datum["tooltip"] = agg.format(agg.value());
              dataArray.push(datum);
            }
          }
        } else {
          columns = [];
          for (_i = 0, _len = rowKeys.length; _i < _len; _i++) {
            rowKey = rowKeys[_i];
            rowHeader = rowKey.join("-");
            row = [rowHeader === "" ? pivotData.aggregatorName : rowHeader];
            for (_j = 0, _len1 = colKeys.length; _j < _len1; _j++) {
              colKey = colKeys[_j];
              agg = pivotData.getAggregator(rowKey, colKey);
              if (agg.value() != null) {
                row.push(agg.value());
              } else {
                row.push(null);
              }
            }
            columns.push(row);
          }
          vAxisTitle = pivotData.aggregatorName + (pivotData.valAttrs.length ? "(" + (pivotData.valAttrs.join(", ")) + ")" : "");
          hAxisTitle = pivotData.colAttrs.join("-");
        }
        params = {
          size: {
            height: $(window).height() / 1.4,
            width: $(window).width() / 1.4
          },
          axis: {
            y: {
              label: vAxisTitle
            },
            x: {
              label: hAxisTitle
            }
          },
          data: {
            type: chartOpts.type
          },
          tooltip: {
            grouped: false
          }
        };
        if (chartOpts.type === "scatter") {
          params.data.x = hAxisTitle;
          params.axis.x.tick = {
            fit: false
          };
          params.data.json = dataArray;
          params.data.keys = {
            value: [hAxisTitle, vAxisTitle]
          };
          params.legend = {
            show: false
          };
          params.tooltip.format = {
            title: function() {
              return fullAggName;
            },
            name: function() {
              return "";
            },
            value: function(a, b, c, d) {
              return dataArray[d].tooltip;
            }
          };
        } else {
          params.axis.x.type = 'category';
          params.axis.x.categories = headers;
          params.data.columns = columns;
        }
        if (chartOpts.stacked != null) {
          params.data.groups = [
            (function() {
              var _k, _len2, _results;
              _results = [];
              for (_k = 0, _len2 = rowKeys.length; _k < _len2; _k++) {
                x = rowKeys[_k];
                _results.push(x.join("-"));
              }
              return _results;
            })()
          ];
        }
        renderArea = $("<div>", {
          style: "display:none;"
        }).appendTo($("body"));
        result = $("<div>").appendTo(renderArea);
        params.bindto = result[0];
        c3.generate(params);
        result.detach();
        renderArea.remove();
        return result;
      };
    };
    return $.pivotUtilities.c3_renderers = {
      "Line Chart": makeC3Chart(),
      "Bar Chart": makeC3Chart({
        type: "bar"
      }),
      "Stacked Bar Chart": makeC3Chart({
        type: "bar",
        stacked: true
      }),
      "Area Chart": makeC3Chart({
        type: "area",
        stacked: true
      }),
      "Scatter Chart": makeC3Chart({
        type: "scatter"
      })
    };
  });

}).call(this);

//# sourceMappingURL=c3_renderers.js.map