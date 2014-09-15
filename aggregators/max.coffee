Max = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  largest: null
  push: (record) ->
    if not isNaN parseFloat(record[attr])
        @largest = parseFloat(record[attr]) if parseFloat(record[attr]) > @largest or @largest is null
  value: -> @largest
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 1



max =
  "Max": Max()

$.extend $.pivotUtilities.aggregators, max

$.pivotUtilities.aggregatorTemplates?.Max = Max
