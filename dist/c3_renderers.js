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
    makeC3Chart = function(chartType) {
      return function(pivotData, opts) {
        var agg, colKey, colKeys, columns, defaults, h, headers, i, j, len, len1, params, result, row, rowHeader, rowKey, rowKeys;
        defaults = {
          localeStrings: {
            vs: "vs",
            by: "by"
          }
        };
        opts = $.extend(defaults, opts);
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
        columns = [];
        for (i = 0, len = rowKeys.length; i < len; i++) {
          rowKey = rowKeys[i];
          rowHeader = rowKey.join("-");
          row = [rowHeader === "" ? pivotData.aggregatorName : rowHeader];
          for (j = 0, len1 = colKeys.length; j < len1; j++) {
            colKey = colKeys[j];
            agg = pivotData.getAggregator(rowKey, colKey);
            if (agg.value() != null) {
              row.push(agg.value());
            } else {
              row.push(null);
            }
          }
          columns.push(row);
        }
        result = $("<div>");
        params = {
          bindto: result[0],
          size: {
            height: $(window).height() / 1.4,
            width: $(window).width() / 1.4
          },
          axis: {
            x: {
              type: 'category',
              categories: headers
            }
          },
          data: {
            columns: columns
          }
        };
        if (chartType != null) {
          params.data.type = chartType;
        }
        c3.generate(params);
        return result;
      };
    };
    return $.pivotUtilities.c3_renderers = {
      "Line Chart C3": makeC3Chart(),
      "Bar Chart C3": makeC3Chart("bar")
    };
  });

}).call(this);

//# sourceMappingURL=c3_renderers.js.map