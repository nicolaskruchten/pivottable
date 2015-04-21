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
    return $.pivotUtilities.export_renderers = {
      "TSV Export": function(pivotData, opts) {
        var agg, colAttrs, colKey, colKeys, defaults, r, result, row, rowAttr, rowAttrs, rowKey, rowKeys, text, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n;
        defaults = {
          localeStrings: {}
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
        rowAttrs = pivotData.rowAttrs;
        colAttrs = pivotData.colAttrs;
        result = [];
        row = [];
        for (_i = 0, _len = rowAttrs.length; _i < _len; _i++) {
          rowAttr = rowAttrs[_i];
          row.push(rowAttr);
        }
        if (colKeys.length === 1 && colKeys[0].length === 0) {
          row.push(pivotData.aggregatorName);
        } else {
          for (_j = 0, _len1 = colKeys.length; _j < _len1; _j++) {
            colKey = colKeys[_j];
            row.push(colKey.join("-"));
          }
        }
        result.push(row);
        for (_k = 0, _len2 = rowKeys.length; _k < _len2; _k++) {
          rowKey = rowKeys[_k];
          row = [];
          for (_l = 0, _len3 = rowKey.length; _l < _len3; _l++) {
            r = rowKey[_l];
            row.push(r);
          }
          for (_m = 0, _len4 = colKeys.length; _m < _len4; _m++) {
            colKey = colKeys[_m];
            agg = pivotData.getAggregator(rowKey, colKey);
            if (agg.value() != null) {
              row.push(agg.value());
            } else {
              row.push("");
            }
          }
          result.push(row);
        }
        text = "";
        for (_n = 0, _len5 = result.length; _n < _len5; _n++) {
          r = result[_n];
          text += r.join("\t") + "\n";
        }
        return $("<textarea>").text(text).css({
          width: ($(window).width() / 2) + "px",
          height: ($(window).height() / 2) + "px"
        });
      }
    };
  });

}).call(this);

//# sourceMappingURL=export_renderers.js.map