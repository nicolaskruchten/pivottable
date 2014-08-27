ListUnique = () -> ([attr]) -> (data, rowKey, colKey) ->
  uniq: []
  push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
  value: -> @uniq.join ", "
  format: (x) -> x
  numInputs: 1



listUnique =
  "List Unique": ListUnique()

$.extend $.pivotUtilities.aggregators, listUnique