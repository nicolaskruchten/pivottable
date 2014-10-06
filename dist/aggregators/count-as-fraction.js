(function() {
  var countAsFraction;

  countAsFraction = {
    "Count as Fraction of Total": $.pivotUtilities.aggregatorTemplates.fractionOf($.pivotUtilities.aggregatorTemplates.Count(), 'total'),
    "Count as Fraction of Rows": $.pivotUtilities.aggregatorTemplates.fractionOf($.pivotUtilities.aggregatorTemplates.Count(), 'row'),
    "Count as Fraction of Columns": $.pivotUtilities.aggregatorTemplates.fractionOf($.pivotUtilities.aggregatorTemplates.Count(), 'col')
  };

  $.extend($.pivotUtilities.aggregators, countAsFraction);

}).call(this);
