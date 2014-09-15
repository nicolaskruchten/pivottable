CountUnique = (formatter) -> ([attr]) -> (data, rowKey, colKey) ->
  uniq: []
  push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
  value: -> @uniq.length
  format: formatter or $.pivotUtilities.formatterTemplates.default
  numInputs: 1


countUnique =
  	"Count Unique": CountUnique($.pivotUtilities.numberFormat(digitsAfterDecimal: 0))

$.extend $.pivotUtilities.aggregators, countUnique
