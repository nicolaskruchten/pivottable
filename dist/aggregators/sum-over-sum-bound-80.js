(function() {
  var SumOverSumBound80, sumOverSumBound80;

  SumOverSumBound80 = function(formatter, upper) {
    if (upper == null) {
      upper = true;
    }
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
            var sign;
            sign = upper ? 1 : -1;
            return (0.821187207574908 / this.sumDenom + this.sumNum / this.sumDenom + 1.2815515655446004 * sign * Math.sqrt(0.410593603787454 / (this.sumDenom * this.sumDenom) + (this.sumNum * (1 - this.sumNum / this.sumDenom)) / (this.sumDenom * this.sumDenom))) / (1 + 1.642374415149816 / this.sumDenom);
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 2
        };
      };
    };
  };

  sumOverSumBound80 = {
    "80% Upper Bound": SumOverSumBound80($.pivotUtilities.numberFormat()),
    "80% Lower Bound": SumOverSumBound80($.pivotUtilities.numberFormat(), false)
  };

  $.extend($.pivotUtilities.aggregators, sumOverSumBound80);

}).call(this);
