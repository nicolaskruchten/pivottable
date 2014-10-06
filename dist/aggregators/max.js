(function() {
  var Max, max, _ref;

  Max = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          largest: null,
          push: function(record) {
            if (!isNaN(parseFloat(record[attr]))) {
              if (parseFloat(record[attr]) > this.largest || this.largest === null) {
                return this.largest = parseFloat(record[attr]);
              }
            }
          },
          value: function() {
            return this.largest;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 1
        };
      };
    };
  };

  max = {
    "Max": Max()
  };

  $.extend($.pivotUtilities.aggregators, max);

  if ((_ref = $.pivotUtilities.aggregatorTemplates) != null) {
    _ref.Max = Max;
  }

}).call(this);
