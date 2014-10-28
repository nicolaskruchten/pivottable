(function() {
  var Average, average, _ref;

  Average = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          sum: 0,
          len: 0,
          push: function(record) {
            if (!isNaN(parseFloat(record[attr]))) {
              this.sum += parseFloat(record[attr]);
              return this.len++;
            }
          },
          value: function() {
            return this.sum / this.len;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 1
        };
      };
    };
  };

  average = {
    "Average": Average($.pivotUtilities.numberFormat())
  };

  $.extend($.pivotUtilities.aggregators, average);

  if ((_ref = $.pivotUtilities.aggregatorTemplates) != null) {
    _ref.Average = Average;
  }

}).call(this);
