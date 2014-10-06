ListUnique = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  uniq: []
  push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
  value: -> @uniq.join ", "
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 1



listUnique =
  "List Unique": ListUnique()

$.extend $.pivotUtilities.aggregators, listUnique
