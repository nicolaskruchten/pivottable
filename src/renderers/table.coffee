###
Default Renderer for hierarchical table layout
###

TableRenderer = (pivotData, opts) ->

  defaults =
    localeStrings:
      totals: "Totals"

  opts = $.extend defaults, opts

  colAttrs = pivotData.colAttrs
  rowAttrs = pivotData.rowAttrs
  rowKeys = pivotData.getRowKeys()
  colKeys = pivotData.getColKeys()

  #now actually build the output
  result = document.createElement("table")
  result.className = "pvtTable"

  #helper function for setting row/col-span in TableRenderer
  spanSize = (arr, i, j) ->
    if i != 0
      noDraw = true
      for x in [0..j]
        if arr[i-1][x] != arr[i][x]
          noDraw = false
      if noDraw
        return -1 #do not draw cell
    len = 0
    while i+len < arr.length
      stop = false
      for x in [0..j]
        stop = true if arr[i][x] != arr[i+len][x]
      break if stop
      len++
    return len

  #the first few rows are for col headers
  for own j, c of colAttrs
    tr = document.createElement("tr")
    if parseInt(j) == 0 and rowAttrs.length != 0
      th = document.createElement("th")
      th.setAttribute("colspan", rowAttrs.length)
      th.setAttribute("rowspan", colAttrs.length)
      tr.appendChild th
    th = document.createElement("th")
    th.className = "pvtAxisLabel"
    th.textContent = c
    tr.appendChild th
    for own i, colKey of colKeys
      x = spanSize(colKeys, parseInt(i), parseInt(j))
      if x != -1
        th = document.createElement("th")
        th.className = "pvtColLabel"
        th.textContent = colKey[j]
        th.setAttribute("colspan", x)
        if parseInt(j) == colAttrs.length-1 and rowAttrs.length != 0
          th.setAttribute("rowspan", 2)
        tr.appendChild th
    if parseInt(j) == 0
      th = document.createElement("th")
      th.className = "pvtTotalLabel"
      th.innerHTML = opts.localeStrings.totals
      th.setAttribute("rowspan", colAttrs.length + (if rowAttrs.length ==0 then 0 else 1))
      tr.appendChild th
    result.appendChild tr

  #then a row for row header headers
  if rowAttrs.length !=0
    tr = document.createElement("tr")
    for own i, r of rowAttrs
      th = document.createElement("th")
      th.className = "pvtAxisLabel"
      th.textContent = r
      tr.appendChild th
    th = document.createElement("th")
    if colAttrs.length ==0
      th.className = "pvtTotalLabel"
      th.innerHTML = opts.localeStrings.totals
    tr.appendChild th
    result.appendChild tr

  #now the actual data rows, with their row headers and totals
  for own i, rowKey of rowKeys
    tr = document.createElement("tr")
    for own j, txt of rowKey
      x = spanSize(rowKeys, parseInt(i), parseInt(j))
      if x != -1
        th = document.createElement("th")
        th.className = "pvtRowLabel"
        th.textContent = txt
        th.setAttribute("rowspan", x)
        if parseInt(j) == rowAttrs.length-1 and colAttrs.length !=0
          th.setAttribute("colspan",2)
        tr.appendChild th
    for own j, colKey of colKeys #this is the tight loop
      aggregator = pivotData.getAggregator(rowKey, colKey)
      val = aggregator.value()
      td = document.createElement("td")
      td.className = "pvtVal row#{i} col#{j}"
      td.innerHTML = aggregator.format(val)
      td.setAttribute("data-value", val)
      tr.appendChild td

    totalAggregator = pivotData.getAggregator(rowKey, [])
    val = totalAggregator.value()
    td = document.createElement("td")
    td.className = "pvtTotal rowTotal"
    td.innerHTML = totalAggregator.format(val)
    td.setAttribute("data-value", val)
    td.setAttribute("data-for", "row"+i)
    tr.appendChild td
    result.appendChild tr

  #finally, the row for col totals, and a grand total
  tr = document.createElement("tr")
  th = document.createElement("th")
  th.className = "pvtTotalLabel"
  th.innerHTML = opts.localeStrings.totals
  th.setAttribute("colspan", rowAttrs.length + (if colAttrs.length == 0 then 0 else 1))
  tr.appendChild th
  for own j, colKey of colKeys
    totalAggregator = pivotData.getAggregator([], colKey)
    val = totalAggregator.value()
    td = document.createElement("td")
    td.className = "pvtTotal colTotal"
    td.innerHTML = totalAggregator.format(val)
    td.setAttribute("data-value", val)
    td.setAttribute("data-for", "col"+j)
    tr.appendChild td
  totalAggregator = pivotData.getAggregator([], [])
  val = totalAggregator.value()
  td = document.createElement("td")
  td.className = "pvtGrandTotal"
  td.innerHTML = totalAggregator.format(val)
  td.setAttribute("data-value", val)
  tr.appendChild td
  result.appendChild tr

  #squirrel this away for later
  result.setAttribute("data-numrows", rowKeys.length)
  result.setAttribute("data-numcols", colKeys.length)

  return result


###
Heatmap post-processing
###

$.fn.heatmap = (scope = "heatmap") ->
  numRows = @data "numrows"
  numCols = @data "numcols"

  colorGen = (color, min, max) ->
    hexGen = switch color
      when "red"   then (hex) -> "ff#{hex}#{hex}"
      when "green" then (hex) -> "#{hex}ff#{hex}"
      when "blue"  then (hex) -> "#{hex}#{hex}ff"

    return (x) ->
      intensity = 255 - Math.round 255*(x-min)/(max-min)
      hex = intensity.toString(16).split(".")[0]
      hex = 0+hex if hex.length == 1
      return hexGen(hex)

  heatmapper = (scope, color) =>
    forEachCell = (f) =>
      @find(scope).each ->
        x = $(this).data("value")
        f(x, $(this)) if x? and isFinite(x)

    values = []
    forEachCell (x) -> values.push x
    colorFor = colorGen color, Math.min(values...), Math.max(values...)
    forEachCell (x, elem) -> elem.css "background-color", "#" + colorFor(x)

  switch scope
    when "heatmap"
      heatmapper ".pvtVal", "red"
    when "rowheatmap"
      heatmapper ".pvtVal.row#{i}", "red" for i in [0...numRows]
    when "colheatmap"
      heatmapper ".pvtVal.col#{j}", "red" for j in [0...numCols]

  heatmapper ".pvtTotal.rowTotal", "red"
  heatmapper ".pvtTotal.colTotal", "red"

  return this

###
Barchart post-processing
###

$.fn.barchart =  ->
  numRows = @data "numrows"
  numCols = @data "numcols"

  barcharter = (scope) =>
    forEachCell = (f) =>
      @find(scope).each ->
        x = $(this).data("value")
        f(x, $(this)) if x? and isFinite(x)

    values = []
    forEachCell (x) -> values.push x
    max = Math.max(values...)
    scaler = (x) -> 100*x/(1.4*max)
    forEachCell (x, elem) ->
      text = elem.text()
      wrapper = $("<div>").css
        "position": "relative"
        "height": "55px"
      wrapper.append $("<div>").css
        "position": "absolute"
        "bottom": 0
        "left": 0
        "right": 0
        "height": scaler(x) + "%"
        "background-color": "gray"
      wrapper.append $("<div>").text(text).css
        "position":"relative"
        "padding-left":"5px"
        "padding-right":"5px"

      elem.css("padding": 0,"padding-top": "5px", "text-align": "center").html wrapper

  barcharter ".pvtVal.row#{i}" for i in [0...numRows]
  barcharter ".pvtTotal.colTotal"

  return this




table_renderer =
  "Table": (pvtData, opts) -> TableRenderer(pvtData, opts)
  "Table Barchart": (pvtData, opts) -> $(TableRenderer(pvtData, opts)).barchart()
  "Heatmap": (pvtData, opts) -> $(TableRenderer(pvtData, opts)).heatmap()
  "Row Heatmap": (pvtData, opts) -> $(TableRenderer(pvtData, opts)).heatmap("rowheatmap")
  "Col Heatmap": (pvtData, opts) -> $(TableRenderer(pvtData, opts)).heatmap("colheatmap")

$.extend $.pivotUtilities.renderers, table_renderer