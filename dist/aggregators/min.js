(function() {
  var Min, min, _ref;

  Min = function(formatter) {
    return function(_arg) {
      var attr;
      attr = _arg[0];
      return function(data, rowKey, colKey) {
        return {
          smallest: null,
          push: function(record) {
            if (!isNaN(parseFloat(record[attr]))) {
              if (parseFloat(record[attr]) < this.smallest || this.smallest === null) {
                return this.smallest = parseFloat(record[attr]);
              }
            }
          },
          value: function() {
            return this.smallest;
          },
          format: formatter || $.pivotUtilities.formatterTemplates["default"],
          numInputs: 1
        };
      };
    };
  };

  min = {
    "Min": Min()
  };

  $.extend($.pivotUtilities.aggregators, min);

  if ((_ref = $.pivotUtilities.aggregatorTemplates) != null) {
    _ref.Min = Min;
  }

}).call(this);
