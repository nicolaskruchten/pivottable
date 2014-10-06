sumAsFraction =
  "Sum as Fraction of Total": $.pivotUtilities.aggregatorTemplates.fractionOf($.pivotUtilities.aggregatorTemplates.Sum(), 'total')
  "Sum as Fraction of Rows": $.pivotUtilities.aggregatorTemplates.fractionOf($.pivotUtilities.aggregatorTemplates.Sum(), 'row')
  "Sum as Fraction of Columns": $.pivotUtilities.aggregatorTemplates.fractionOf($.pivotUtilities.aggregatorTemplates.Sum(), 'col')

$.extend $.pivotUtilities.aggregators, sumAsFraction