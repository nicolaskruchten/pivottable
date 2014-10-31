$ = jQuery

###
Utilities
###

addSeparators = (nStr, thousandsSep, decimalSep) ->
  nStr += ''
  x = nStr.split('.')
  x1 = x[0]
  x2 = if x.length > 1 then  decimalSep + x[1] else ''
  rgx = /(\d+)(\d{3})/
  x1 = x1.replace(rgx, '$1' + thousandsSep + '$2') while rgx.test(x1)
  return x1 + x2

numberFormat = (opts) ->
  defaults =
    digitsAfterDecimal: 2, scaler: 1,
    thousandsSep: ",", decimalSep: "."
    prefix: "", suffix: ""
    showZero: false
  opts = $.extend defaults, opts
  (x) ->
    return "" if isNaN(x) or not isFinite(x)
    return "" if x == 0 and not opts.showZero
    result = addSeparators (opts.scaler*x).toFixed(opts.digitsAfterDecimal), opts.thousandsSep, opts.decimalSep
    return ""+opts.prefix+result+opts.suffix

formatterTemplates =
  default: (x) -> x
  percentFormat: numberFormat(digitsAfterDecimal:1, scaler: 100, suffix: "%")

#aggregator templates default to US number formatting but this is overrideable
aggregatorTemplates =
  fractionOf: (wrapped, type="total", formatter=formatterTemplates.percentFormat) -> (x...) -> (data, rowKey, colKey) ->
    name: "fractionOf"
    selector: {total:[[],[]],row:[rowKey,[]],col:[[],colKey]}[type]
    inner: wrapped(x...)(data, rowKey, colKey)
    push: (record) -> @inner.push record
    format: formatter
    value: -> @inner.value() / data.getAggregator(@selector...).getWrappedAggregator("fractionOf").inner.value()
    numInputs: wrapped(x...)().numInputs

#default aggregators & renderers use US naming and number formatting
aggregators = {}
renderers = {}

locales =
  en:
    aggregators: aggregators
    renderers: renderers
    localeStrings:
      renderError: "An error occurred rendering the PivotTable results."
      computeError: "An error occurred computing the PivotTable results."
      uiRenderError: "An error occurred rendering the PivotTable UI."
      selectAll: "Select All"
      selectNone: "Select None"
      tooMany: "(too many to list)"
      filterResults: "Filter results"
      totals: "Totals" #for table renderer
      vs: "vs" #for gchart renderer
      by: "by" #for gchart renderer

#dateFormat deriver l10n requires month and day names to be passed in directly
mthNamesEn = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
dayNamesEn = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
zeroPad = (number) -> ("0"+number).substr(-2,2)

derivers =
  bin: (col, binWidth) -> (record) -> record[col] - record[col] % binWidth
  dateFormat: (col, formatString, mthNames=mthNamesEn, dayNames=dayNamesEn) ->
    (record) -> #thanks http://stackoverflow.com/a/12213072/112871
      date = new Date(Date.parse(record[col]))
      if isNaN(date) then return ""
      formatString.replace /%(.)/g, (m, p) ->
        switch p
          when "y" then date.getFullYear()
          when "m" then zeroPad(date.getMonth()+1)
          when "n" then mthNames[date.getMonth()]
          when "d" then zeroPad(date.getDate())
          when "w" then dayNames[date.getDay()]
          when "x" then date.getDay()
          when "H" then zeroPad(date.getHours())
          when "M" then zeroPad(date.getMinutes())
          when "S" then zeroPad(date.getSeconds())
          else "%" + p

naturalSort = (as, bs) -> #thanks http://stackoverflow.com/a/4373421/112871
  rx = /(\d+)|(\D+)/g
  rd = /\d/
  rz = /^0/
  if typeof as is "number" or typeof bs is "number"
    return 1  if isNaN(as)
    return -1  if isNaN(bs)
    return as - bs
  a = String(as).toLowerCase()
  b = String(bs).toLowerCase()
  return 0  if a is b
  return (if a > b then 1 else -1)  unless rd.test(a) and rd.test(b)
  a = a.match(rx)
  b = b.match(rx)
  while a.length and b.length
    a1 = a.shift()
    b1 = b.shift()
    if a1 isnt b1
      if rd.test(a1) and rd.test(b1)
        return a1.replace(rz, ".0") - b1.replace(rz, ".0")
      else
        return (if a1 > b1 then 1 else -1)
  a.length - b.length

###
Data Model class
###
class PivotData
  constructor: (input, opts) ->
    @aggregators = opts.aggregators
    @aggregatorName = opts.aggregatorName
    @colAttrs = opts.cols
    @rowAttrs = opts.rows
    @valAttrs = opts.vals
    @tree = {}
    @rowKeys = []
    @colKeys = []
    @rowTotals = {}
    @colTotals = {}
    @allTotal = @wrapAggregator(this, [], [])
    @sorted = false

    # iterate through input, accumulating data for cells
    PivotData.forEachRecord input, opts.derivedAttributes, (record) =>
      @processRecord(record) if opts.filter(record)

  #can handle arrays or jQuery selections of tables
  @forEachRecord = (input, derivedAttributes, f) ->
    if $.isEmptyObject derivedAttributes
      addRecord = f
    else
      addRecord = (record) ->
        record[k] = v(record) ? record[k] for k, v of derivedAttributes
        f(record)

    #if it's a function, have it call us back
    if $.isFunction(input)
      input(addRecord)
    else if $.isArray(input)
      if $.isArray(input[0]) #array of arrays
        for own i, compactRecord of input when i > 0
          record = {}
          record[k] = compactRecord[j] for own j, k of input[0]
          addRecord(record)
      else #array of objects
        addRecord(record) for record in input
    else if input instanceof jQuery
      tblCols = []
      $("thead > tr > th", input).each (i) -> tblCols.push $(this).text()
      $("tbody > tr", input).each (i) ->
        record = {}
        $("td", this).each (j) -> record[tblCols[j]] = $(this).text()
        addRecord(record)
    else
      throw new Error("unknown input format")

  #converts to [{attr:val, attr:val},{attr:val, attr:val}] using method above
  @convertToArray = (input) ->
    result = []
    PivotData.forEachRecord input, {}, (record) -> result.push record
    return result

  natSort: (as, bs) -> naturalSort(as, bs)

  arrSort: (a,b) => @natSort a.join(), b.join()

  sortKeys: =>
    if not @sorted
      @rowKeys.sort @arrSort
      @colKeys.sort @arrSort
    @sorted = true

  getColKeys: =>
    @sortKeys()
    return @colKeys

  getRowKeys: =>
    @sortKeys()
    return @rowKeys

  processRecord: (record) -> #this code is called in a tight loop
    colKey = []
    rowKey = []
    colKey.push record[x] ? "null" for x in @colAttrs
    rowKey.push record[x] ? "null" for x in @rowAttrs
    flatRowKey = rowKey.join(String.fromCharCode(0))
    flatColKey = colKey.join(String.fromCharCode(0))

    @allTotal.push record

    if rowKey.length != 0
      if not @rowTotals[flatRowKey]
        @rowKeys.push rowKey
        @rowTotals[flatRowKey] = @wrapAggregator(this, rowKey, [])
      @rowTotals[flatRowKey].push record

    if colKey.length != 0
      if not @colTotals[flatColKey]
        @colKeys.push colKey
        @colTotals[flatColKey] = @wrapAggregator(this, [], colKey)
      @colTotals[flatColKey].push record

    if colKey.length != 0 and rowKey.length != 0
      if not @tree[flatRowKey]
        @tree[flatRowKey] = {}
      if not @tree[flatRowKey][flatColKey]
        @tree[flatRowKey][flatColKey] = @wrapAggregator(this, rowKey, colKey)
      @tree[flatRowKey][flatColKey].push record

  getAggregator: (rowKey, colKey) =>
    flatRowKey = rowKey.join(String.fromCharCode(0))
    flatColKey = colKey.join(String.fromCharCode(0))
    if rowKey.length == 0 and colKey.length == 0
      agg = @allTotal
    else if rowKey.length == 0
      agg = @colTotals[flatColKey]
    else if colKey.length == 0
      agg = @rowTotals[flatRowKey]
    else
      agg = @tree[flatRowKey][flatColKey]
    return agg ? {value: (-> null), format: -> ""}

  wrapAggregator: (pivotData, rowKey=[], colKey=[]) ->
    wrappedAggregators = []
    aggregatorMap = {}

    # Generate a map between the aggregator name and index in the
    # wrappedAggregators array
    @aggregators.forEach (aggregator, index) ->
      initAgg = aggregator(pivotData, rowKey, colKey)
      aggregatorMap[initAgg.name] = index if initAgg.name?
      wrappedAggregators.push initAgg

    wrappedAggregators: wrappedAggregators
    aggregatorMap: aggregatorMap
    value: -> @wrappedAggregators.map (aggregator) -> aggregator.value()
    format: (value=[]) -> value.map (value, i) => @wrappedAggregators[i].format(value)
    push: (record) -> @wrappedAggregators.forEach (aggregator) -> aggregator.push(record)
    getWrappedAggregator: (name) -> @wrappedAggregators[@aggregatorMap[name]]

###
Pivot Table core: create PivotData object and call Renderer on it
###
$.fn.pivot = (input, opts) ->
  defaults =
    cols : []
    rows: []
    filter: -> true
    aggregators: []
    aggregatorName: ""
    derivedAttributes: {},
    renderer: ""
    rendererOptions: null
    localeStrings: locales.en.localeStrings

  opts = $.extend defaults, opts

  result = null
  try
    pivotData = new PivotData(input, opts)
    try
      result = opts.renderer(pivotData, opts.rendererOptions)
    catch e
      console.error(e.stack) if console?
      result = $("<span>").html opts.localeStrings.renderError
  catch e
    console.error(e.stack) if console?
    result = $("<span>").html opts.localeStrings.computeError

  x = this[0]
  x.removeChild(x.lastChild) while x.hasChildNodes()
  return @append result

#expose these to the outside world
$.pivotUtilities = {aggregatorTemplates, aggregators, renderers, derivers, locales,
  naturalSort, numberFormat, formatterTemplates, PivotData}
