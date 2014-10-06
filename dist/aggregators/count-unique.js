(function() {
  var CountUnique, countUnique,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  CountUnique = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          uniq: [],
          push: function(record) {
            var _ref;
            if (_ref = record[attr], __indexOf.call(this.uniq, _ref) < 0) {
              return this.uniq.push(record[attr]);
            }
          },
          value: function() {
            return this.uniq.length;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 1
        };
      };
    };
  };

  countUnique = {
    "Count Unique": CountUnique($.pivotUtilities.numberFormat({
      digitsAfterDecimal: 0
    }))
  };

  $.extend($.pivotUtilities.aggregators, countUnique);

}).call(this);
