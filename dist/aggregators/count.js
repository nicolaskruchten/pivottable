(function() {
  var Count, count, _ref;

  Count = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          count: 0,
          push: function() {
            return this.count++;
          },
          value: function() {
            return this.count;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"]
        };
      };
    };
  };

  count = {
    "Count": Count($.pivotUtilities.numberFormat({
      digitsAfterDecimal: 0
    }))
  };

  $.extend($.pivotUtilities.aggregators, count);

  if ((_ref = $.pivotUtilities.aggregatorTemplates) != null) {
    _ref.Count = Count;
  }

}).call(this);
