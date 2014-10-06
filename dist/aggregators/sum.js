(function() {
  var Sum, sum, _ref;

  Sum = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          sum: 0,
          push: function(record) {
            if (!isNaN(parseFloat(record[attr]))) {
              return this.sum += parseFloat(record[attr]);
            }
          },
          value: function() {
            return this.sum;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 1
        };
      };
    };
  };

  sum = {
    "Sum": Sum($.pivotUtilities.numberFormat()),
    "Integer Sum": Sum($.pivotUtilities.numberFormat({
      digitsAfterDecimal: 0
    }))
  };

  $.extend($.pivotUtilities.aggregators, sum);

  if ((_ref = $.pivotUtilities.aggregatorTemplates) != null) {
    _ref.Sum = Sum;
  }

}).call(this);
