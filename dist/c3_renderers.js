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
        var agg, colKey, colKeys, columns, dataArray, datum, defaults, fullAggName, h, hAxisTitle, headers, i, j, len, len1, params, ref, renderArea, result, row, rowHeader, rowKey, rowKeys, tree2, vAxisTitle, val, x, y;
        defaults = {
          localeStrings: {
            vs: "vs",
            by: "by"
          },
          c3: {
            width: function() {
              return window.innerWidth / 1.4;
            },
            height: function() {
              return window.innerHeight / 1.4;
            }
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
          var i, len, results;
          results = [];
          for (i = 0, len = colKeys.length; i < len; i++) {
            h = colKeys[i];
            results.push(h.join("-"));
          }
          return results;
        })();
        fullAggName = pivotData.aggregatorName;
        if (pivotData.valAttrs.length) {
          fullAggName += "(" + (pivotData.valAttrs.join(", ")) + ")";
        }
        if (chartOpts.type === "scatter") {
          dataArray = [];
          hAxisTitle = pivotData.colAttrs.join("-");
          vAxisTitle = pivotData.rowAttrs.join("-");
          ref = pivotData.tree;
          for (y in ref) {
            tree2 = ref[y];
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
          for (i = 0, len = rowKeys.length; i < len; i++) {
            rowKey = rowKeys[i];
            rowHeader = rowKey.join("-");
            row = [rowHeader === "" ? pivotData.aggregatorName : rowHeader];
            for (j = 0, len1 = colKeys.length; j < len1; j++) {
              colKey = colKeys[j];
              agg = pivotData.getAggregator(rowKey, colKey);
              if (agg.value() != null) {
                val = agg.value();
                if ($.isNumeric(val)) {
                  if (val < 1) {
                    row.push(parseFloat(val.toPrecision(3)));
                  } else {
                    row.push(parseFloat(val.toFixed(3)));
                  }
                } else {
                  row.push(val);
                }
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
            height: opts.c3.height(),
            width: opts.c3.width()
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
              var k, len2, results;
              results = [];
              for (k = 0, len2 = rowKeys.length; k < len2; k++) {
                x = rowKeys[k];
                results.push(x.join("-"));
              }
              return results;
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