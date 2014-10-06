SumOverSumBound80 = (formatter, upper=true) -> ([num, denom]) -> (data, rowKey, colKey) ->
  sumNum: 0
  sumDenom: 0
  push: (record) ->
      @sumNum   += parseFloat(record[num])   if not isNaN parseFloat(record[num])
      @sumDenom += parseFloat(record[denom]) if not isNaN parseFloat(record[denom])
  value: ->
      sign = if upper then 1 else -1
      (0.821187207574908/@sumDenom + @sumNum/@sumDenom + 1.2815515655446004*sign*
          Math.sqrt(0.410593603787454/ (@sumDenom*@sumDenom) + (@sumNum*(1 - @sumNum/ @sumDenom))/ (@sumDenom*@sumDenom)))/
          (1 + 1.642374415149816/@sumDenom)
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 2



sumOverSumBound80 =
  "80% Upper Bound": SumOverSumBound80($.pivotUtilities.numberFormat())
  "80% Lower Bound": SumOverSumBound80($.pivotUtilities.numberFormat(), false)

$.extend $.pivotUtilities.aggregators, sumOverSumBound80
