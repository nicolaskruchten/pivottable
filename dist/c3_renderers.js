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
        var agg, colKey, colKeys, columns, defaults, h, headers, params, result, row, rowHeader, rowKey, rowKeys, _i, _j, _len, _len1;
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
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = colKeys.length; _i < _len; _i++) {
            h = colKeys[_i];
            _results.push(h.join("-"));
          }
          return _results;
        })();
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