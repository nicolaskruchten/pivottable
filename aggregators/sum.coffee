Sum = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  sum: 0
  push: (record) -> @sum += parseFloat(record[attr]) if not isNaN parseFloat(record[attr])
  value: -> @sum
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 1



sum =
  "Sum": Sum($.pivotUtilities.numberFormat())
  "Integer Sum": Sum($.pivotUtilities.numberFormat(digitsAfterDecimal: 0))

$.extend $.pivotUtilities.aggregators, sum

$.pivotUtilities.aggregatorTemplates?.Sum = Sum
