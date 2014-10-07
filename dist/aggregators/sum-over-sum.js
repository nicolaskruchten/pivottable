(function() {
  var SumOverSum, sumOverSum;

  SumOverSum = function(formatter) {
    return function(_arg) {
      var denom, num;
      num = _arg[0], denom = _arg[1];
      return function(data, rowKey, colKey) {
        return {
          sumNum: 0,
          sumDenom: 0,
          push: function(record) {
            if (!isNaN(parseFloat(record[num]))) {
              this.sumNum += parseFloat(record[num]);
            }
            if (!isNaN(parseFloat(record[denom]))) {
              return this.sumDenom += parseFloat(record[denom]);
            }
          },
          value: function() {
            return this.sumNum / this.sumDenom;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 2
        };
      };
    };
  };

  sumOverSum = {
    "Sum over Sum": SumOverSum($.pivotUtilities.numberFormat())
  };

  $.extend($.pivotUtilities.aggregators, sumOverSum);

}).call(this);
