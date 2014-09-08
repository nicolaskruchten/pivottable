SumOverSum = (formatter) -> ([num, denom]) -> (data, rowKey, colKey) ->
  sumNum: 0
  sumDenom: 0
  push: (record) ->
      @sumNum   += parseFloat(record[num])   if not isNaN parseFloat(record[num])
      @sumDenom += parseFloat(record[denom]) if not isNaN parseFloat(record[denom])
  value: -> @sumNum/@sumDenom
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 2



sumOverSum =
  "Sum over Sum": SumOverSum($.pivotUtilities.numberFormat())

$.extend $.pivotUtilities.aggregators, sumOverSum
