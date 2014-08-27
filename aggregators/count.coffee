Count = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  count: 0
  push:  -> @count++
  value: -> @count
  format: formatter



count =
  "Count": Count($.pivotUtilities.numberFormat(digitsAfterDecimal: 0))

$.extend $.pivotUtilities.aggregators, count

$.pivotUtilities.aggregatorTemplates?.Count = Count