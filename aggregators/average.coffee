Average = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  sum: 0
  len: 0
  push: (record) ->
      if not isNaN parseFloat(record[attr])
          @sum += parseFloat(record[attr])
          @len++
  value: -> @sum/@len
  format: formatter
  numInputs: 1



average =
  "Average": Average($.pivotUtilities.numberFormat())

$.extend $.pivotUtilities.aggregators, average