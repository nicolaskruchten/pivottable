(function() {
  var StdDev, stddev, _ref;

  StdDev = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          avg: $.pivotUtilities.aggregatorTemplates.Average($.pivotUtilities.numberFormat())([attr])(data, rowKey, colKey),
          values: [],
          variance: 0,
          push: function(record) {
            this.avg.push(record);
            if (!isNaN(parseFloat(record[attr]))) {
              return this.values.push(parseFloat(record[attr]));
            }
          },
          value: function() {
            var s, value, _i, _len, _ref;
            s = 0;
            _ref = this.values;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              value = _ref[_i];
              s += Math.pow(value - this.avg.value(), 2);
            }
            this.variance = s / this.values.length;
            return Math.sqrt(this.variance);
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 1
        };
      };
    };
  };

  stddev = {
    "Standard Deviation": StdDev()
  };

  $.extend($.pivotUtilities.aggregators, stddev);

  if ((_ref = $.pivotUtilities.aggregatorTemplates) != null) {
    _ref.StdDev = StdDev;
  }

}).call(this);
