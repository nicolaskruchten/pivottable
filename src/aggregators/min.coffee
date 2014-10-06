Min = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  smallest: null
  push: (record) ->
    if not isNaN parseFloat(record[attr])
        @smallest = parseFloat(record[attr]) if parseFloat(record[attr]) < @smallest or @smallest is null
  value: -> @smallest
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 1



min =
  "Min": Min()

$.extend $.pivotUtilities.aggregators, min

$.pivotUtilities.aggregatorTemplates?.Min = Min
