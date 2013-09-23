$ = jQuery

###
Utilities
###

addCommas = (nStr) ->
    nStr += ''
    x = nStr.split('.')
    x1 = x[0]
    x2 = if x.length > 1 then  '.' + x[1] else ''
    rgx = /(\d+)(\d{3})/
    x1 = x1.replace(rgx, '$1' + ',' + '$2') while rgx.test(x1)
    return x1 + x2

numberFormat = (sigfig=3, scaler=1) ->
    (x) ->
        if x==0 or isNaN(x) or not isFinite(x) then ""
        else addCommas (scaler*x).toFixed(sigfig)

#technically these are aggregator constructor generator generators (!)
aggregatorTemplates =
    sum: (sigfig=3, scaler=1) -> ([attr]) -> ->
        sum: 0
        push: (record) -> @sum += parseFloat(record[attr]) if not isNaN parseFloat(record[attr])
        value: -> @sum
        format: numberFormat(sigfig, scaler)
        label: "Sum of #{attr}"

    average:  (sigfig=3, scaler=1) -> ([attr]) -> ->
        sum: 0
        len: 0
        push: (record) ->
            if not isNaN parseFloat(record[attr])
                @sum += parseFloat(record[attr])
                @len++
        value: -> @sum/@len
        format: numberFormat(sigfig, scaler)
        label: "Average of #{attr}"

    sumOverSum: (sigfig=3, scaler=1) -> ([num, denom]) -> ->
        sumNum: 0
        sumDenom: 0
        push: (record) ->
            @sumNum   += parseFloat(record[num])   if not isNaN parseFloat(record[num])
            @sumDenom += parseFloat(record[denom]) if not isNaN parseFloat(record[denom])
        value: -> @sumNum/@sumDenom
        format: numberFormat(sigfig, scaler)
        label: "#{num}/#{denom}"

    sumOverSumBound80: (sigfig=3, scaler=1, upper=true) -> ([num, denom]) -> ->
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
        format: numberFormat(sigfig, scaler)
        label: "#{if upper then "Upper" else "Lower"} Bound of #{num}/#{denom}"

#technically these are aggregator constructor generators (!)
aggregators =
    count: -> ->
        count: 0
        push:  -> @count++
        value: -> @count
        format: numberFormat(0)
        label: "Count"

    countUnique: ([attr]) -> ->
        uniq: []
        push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
        value: -> @uniq.length
        format: numberFormat(0)
        label: "Count Unique #{attr}"

    listUnique: ([attr]) -> ->
        uniq: []
        push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
        value: -> @uniq.join ", "
        format: (x) -> x
        label: "List Unique #{attr}"

    intSum: aggregatorTemplates.sum(0)
    sum: aggregatorTemplates.sum(3)
    average: aggregatorTemplates.average(3)
    sumOverSum: aggregatorTemplates.sumOverSum(3)
    ub80: aggregatorTemplates.sumOverSumBound80(3, 1, true)
    lb80: aggregatorTemplates.sumOverSumBound80(3, 1, false)


renderers =
    "Table": (pvtData) -> pivotTableRenderer(pvtData)
    "Table Barchart": (pvtData) -> pivotTableRenderer(pvtData).barchart()
    "Heatmap":      (pvtData) -> pivotTableRenderer(pvtData).heatmap()
    "Row Heatmap":  (pvtData) -> pivotTableRenderer(pvtData).heatmap("rowheatmap")
    "Col Heatmap":  (pvtData) -> pivotTableRenderer(pvtData).heatmap("colheatmap")

mthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
zeroPad = (number) -> ("0"+number).substr(-2,2)

derivers =
    bin: (col, binWidth) -> (record) -> record[col] - record[col] % binWidth
    dateFormat: (col, formatString) ->
        #thanks http://stackoverflow.com/a/12213072/112871
        (record) ->
            date = new Date(Date.parse(record[col]))
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

$.pivotUtilities = {aggregatorTemplates, aggregators, renderers, derivers}

###
functions for accessing input
###

deriveAttributes = (record, derivedAttributes, f) ->
    record[k] = v(record) ? record[k] for k, v of derivedAttributes
    record[k] ?= "null" for own k of record
    f(record)

#can handle arrays or jQuery selections of tables
forEachRecord = (input, derivedAttributes, f) ->
    addRecord = (record) -> deriveAttributes(record, derivedAttributes, f)
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
    else #assume a jQuery reference to a table
        tblCols = []
        $("thead > tr > th", input).each (i) -> tblCols.push $(this).text()
        $("tbody > tr", input).each (i) ->
            record = {}
            $("td", this).each (j) -> record[tblCols[j]] = $(this).text()
            addRecord(record)

#converts to [{attr:val, attr:val},{attr:val, attr:val}] using method above
convertToArray = (input) ->
    result = []
    forEachRecord input, {}, (record) -> result.push record
    return result

class PivotData
    constructor: (@aggregator, @colAttrs, @rowAttrs) ->
        @tree = {}
        @rowKeys = []
        @colKeys = []
        @flatRowKeys = []
        @flatColKeys = []
        @rowTotals = {}
        @colTotals = {}
        @allTotal = @aggregator()
        @sorted = false
    
    natSort: (as, bs) => #from http://stackoverflow.com/a/4373421/112871
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

    arrSort: (a,b) => @natSort a.join(), b.join()

    sortKeys: () =>
        if not @sorted
            @rowKeys.sort @arrSort
            @colKeys.sort @arrSort
        @sorted = true

    getColKeys: () =>
        @sortKeys()
        return @colKeys

    getRowKeys: () =>
        @sortKeys()
        return @rowKeys

    flattenKey: (x) => x.join(String.fromCharCode(0))

    processRecord: (record) ->
        colKey = (record[x] for x in @colAttrs)
        rowKey = (record[x] for x in @rowAttrs)

        flatRowKey = @flattenKey rowKey
        flatColKey = @flattenKey colKey

        @allTotal.push record

        if rowKey.length != 0
            if flatRowKey not in @flatRowKeys
                @rowKeys.push rowKey
                @flatRowKeys.push flatRowKey
            if not @rowTotals[flatRowKey]
                @rowTotals[flatRowKey] = @aggregator() 
            @rowTotals[flatRowKey].push record

        if colKey.length != 0
            if flatColKey not in @flatColKeys
                @colKeys.push colKey
                @flatColKeys.push flatColKey
            if not @colTotals[flatColKey]
                @colTotals[flatColKey] = @aggregator()
            @colTotals[flatColKey].push record

        if colKey.length != 0 and rowKey.length != 0
            if flatRowKey not of @tree
                @tree[flatRowKey] = {}
            if flatColKey not of @tree[flatRowKey]
                @tree[flatRowKey][flatColKey] = @aggregator() 
            @tree[flatRowKey][flatColKey].push record

    getAggregator: (rowKey, colKey) =>
        flatRowKey = @flattenKey rowKey
        flatColKey = @flattenKey colKey
        if rowKey.length == 0 and colKey.length == 0
            agg = @allTotal
        else if rowKey.length == 0
            agg = @colTotals[flatColKey]
        else if colKey.length == 0 
            agg = @rowTotals[flatRowKey]
        else
            agg = @tree[flatRowKey][flatColKey]
        return agg ? {value: (-> null), format: -> ""}

getPivotData = (input, cols, rows, aggregator, filter, derivedAttributes) ->
    # iterate through input, accumulating data for cells
    pivotData = new PivotData(aggregator, cols, rows)
    forEachRecord input, derivedAttributes, (record) ->
        pivotData.processRecord(record) if filter(record)
    return pivotData

#helper function for setting row/col-span
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

pivotTableRenderer = (pivotData) ->
    colAttrs = pivotData.colAttrs
    rowAttrs = pivotData.rowAttrs
    rowKeys = pivotData.getRowKeys()
    colKeys = pivotData.getColKeys()

    #now actually build the output
    result = $("<table class='table table-bordered pvtTable'>")

    #the first few rows are for col headers
    for own j, c of colAttrs
        tr = $("<tr>")
        if parseInt(j) == 0 and rowAttrs.length != 0
            tr.append $("<th>")
                .attr("colspan", rowAttrs.length)
                .attr("rowspan", colAttrs.length)
        tr.append $("<th class='pvtAxisLabel'>").text(c)
        for own i, colKey of colKeys
            x = spanSize(colKeys, parseInt(i), parseInt(j))
            if x != -1
                th = $("<th class='pvtColLabel'>").text(colKey[j]).attr("colspan", x)
                if parseInt(j) == colAttrs.length-1 and rowAttrs.length != 0
                    th.attr("rowspan", 2)
                tr.append th
        if parseInt(j) == 0
            tr.append $("<th class='pvtTotalLabel'>").text("Totals")
                .attr("rowspan", colAttrs.length + (if rowAttrs.length ==0 then 0 else 1))
        result.append tr

    #then a row for row header headers
    if rowAttrs.length !=0
        tr = $("<tr>")
        for own i, r of rowAttrs
            tr.append $("<th class='pvtAxisLabel'>").text(r)
        th = $("<th>")
        if colAttrs.length ==0
            th.addClass("pvtTotalLabel").text("Totals")
        tr.append th
        result.append tr

    #now the actual data rows, with their row headers and totals
    for own i, rowKey of rowKeys
        tr = $("<tr>")
        for own j, txt of rowKey
            x = spanSize(rowKeys, parseInt(i), parseInt(j))
            if x != -1
                th = $("<th class='pvtRowLabel'>").text(txt).attr("rowspan", x)
                if parseInt(j) == rowAttrs.length-1 and colAttrs.length !=0
                    th.attr("colspan",2)
                tr.append th
        for own j, colKey of colKeys
            aggregator = pivotData.getAggregator(rowKey, colKey)
            val = aggregator.value()
            tr.append $("<td class='pvtVal row#{i} col#{j}'>")
                .text(aggregator.format val)
                .data("value", val)

        totalAggregator = pivotData.getAggregator(rowKey, [])
        val = totalAggregator.value()
        tr.append $("<td class='pvtTotal rowTotal'>")
            .text(totalAggregator.format val)
            .data("value", val)
            .data("for", "row"+i)
        result.append tr

    #finally, the row for col totals, and a grand total
    tr = $("<tr>")
    th = $("<th class='pvtTotalLabel'>").text("Totals")
    th.attr("colspan", rowAttrs.length + (if colAttrs.length == 0 then 0 else 1))
    tr.append th
    for own j, colKey of colKeys
        totalAggregator = pivotData.getAggregator([], colKey)
        val = totalAggregator.value()
        tr.append $("<td class='pvtTotal colTotal'>")
            .text(totalAggregator.format val)
            .data("value", val)
            .data("for", "col"+j)
    totalAggregator = pivotData.getAggregator([], [])
    val = totalAggregator.value()
    tr.append $("<td class='pvtGrandTotal'>")
        .text(totalAggregator.format val)
        .data("value", val)
    result.append tr

    #squirrel this away for later
    result.data "dimensions", [rowKeys.length, colKeys.length]

    return result

###
Pivot Table
###

$.fn.pivot = (input, opts) ->
    defaults =
        cols : []
        rows: []
        filter: -> true
        aggregator: aggregators.count()
        derivedAttributes: {},
        renderer: pivotTableRenderer

    opts = $.extend defaults, opts

    # iterate through input, accumulating data for cells
    @html opts.renderer getPivotData(input, opts.cols, opts.rows, 
                                opts.aggregator, opts.filter, 
                                opts.derivedAttributes)

    return this

###
UI code, calls pivot table above
###

$.fn.pivotUI = (input, inputOpts, overwrite = false) ->
    defaults =
        derivedAttributes: {}
        aggregators: aggregators
        renderers: renderers
        hiddenAttributes: []
        cols: [], rows: [], vals: []

    existingOpts = @data "pivotUIOptions"
    if not existingOpts? or overwrite
        opts = $.extend defaults, inputOpts
    else
        opts = existingOpts 

    #cache the input in some useful form
    input = convertToArray(input)
    tblCols = (k for own k of input[0])
    tblCols.push c for own c of opts.derivedAttributes when (c not in tblCols)

    #figure out the cardinality and some stats
    axisValues = {}
    axisValues[x] = {} for x in tblCols

    forEachRecord input, opts.derivedAttributes, (record) ->
        for own k, v of record
            v ?= "null"
            axisValues[k][v] ?= 0
            axisValues[k][v]++

    #start building the output
    uiTable = $("<table class='table table-bordered' cellpadding='5'>")

    #renderer control
    rendererControl = $("<td>")

    renderer = $("<select id='renderer'>")
        .bind "change", -> refresh() #capture reference
    for own x of opts.renderers
        renderer.append $("<option>").val(x).text(x)
    rendererControl.append renderer


    #axis list, including the double-click menu

    colList = $("<td id='unused' class='pvtAxisContainer pvtHorizList'>")

    for c in tblCols when c not in opts.hiddenAttributes
        do (c) ->
            keys = (k for k of axisValues[c])
            colLabel = $("<nobr>").text(c)
            valueList = $("<div>")
                .css
                    "z-index": 100
                    "width": "280px"
                    "height": "350px"
                    "overflow": "scroll"
                    "border": "1px solid gray"
                    "background": "white"
                    "display": "none"
                    "position": "absolute"
                    "padding": "20px"
            valueList.append $("<strong>").text "#{keys.length} values for #{c}"
            if keys.length > 50
                valueList.append $("<p>").text "(too many to list)"
            else
                btns = $("<p>")
                btns.append $("<button>").text("Select All").bind "click", ->
                    valueList.find("input").attr "checked", true
                btns.append $("<button>").text("Select None").bind "click", ->
                    valueList.find("input").attr "checked", false
                valueList.append btns
                for k in keys.sort()
                     v = axisValues[c][k]
                     filterItem = $("<label>")
                     filterItem.append $("<input type='checkbox' class='pvtFilter'>")
                        .attr("checked", true).data("filter", [c,k])
                     filterItem.append $("<span>").text "#{k} (#{v})"
                     valueList.append $("<p>").append(filterItem)
            colLabel.bind "dblclick", (e) ->
                valueList.css(left: e.pageX, top: e.pageY).toggle()
                valueList.bind "click", (e) -> e.stopPropagation()
                $(document).one "click", ->
                    refresh()
                    valueList.toggle()
            colList.append $("<li class='label label-info' id='axis_#{c.replace(/\s/g, "")}'>").append(colLabel).append(valueList)


    uiTable.append $("<tr>").append(rendererControl).append(colList)

    tr1 = $("<tr>")

    #aggregator menu and value area

    aggregator = $("<select id='aggregator'>")
        .css("margin-bottom", "5px")
        .bind "change", -> refresh() #capture reference
    for own x of opts.aggregators
        aggregator.append $("<option>").val(x).text(x)

    tr1.append $("<td id='vals' class='pvtAxisContainer pvtHorizList'>")
      .css("text-align", "center")
      .append(aggregator).append($("<br>"))

    #column axes
    tr1.append $("<td id='cols' class='pvtAxisContainer pvtHorizList'>")

    uiTable.append tr1

    tr2 = $("<tr>")

    #row axes
    tr2.append $("<td valign='top' id='rows' class='pvtAxisContainer'>")

    #the actual pivot table container
    pivotTable = $("<td valign='top'>")
    tr2.append pivotTable

    uiTable.append tr2

    #render the UI in its default state
    @html uiTable

    #set up the UI initial state as requested by moving elements around

    for x in opts.cols
        @find("#cols").append @find("#axis_#{x.replace(/\s/g, "")}")
    for x in opts.rows
        @find("#rows").append @find("#axis_#{x.replace(/\s/g, "")}")
    for x in opts.vals
        @find("#vals").append @find("#axis_#{x.replace(/\s/g, "")}")
    if opts.aggregatorName?
        @find("#aggregator").val opts.aggregatorName
    if opts.rendererName?
        @find("#renderer").val opts.rendererName

    #set up for refreshing
    refresh = =>
        subopts = {derivedAttributes: opts.derivedAttributes}
        subopts.cols = []
        subopts.rows = []
        vals = []
        @find("#rows li nobr").each -> subopts.rows.push $(this).text()
        @find("#cols li nobr").each -> subopts.cols.push $(this).text()
        @find("#vals li nobr").each -> vals.push $(this).text()

        subopts.aggregator = opts.aggregators[aggregator.val()](vals)
        subopts.renderer = opts.renderers[renderer.val()]

        #construct filter here
        exclusions = []
        @find('input.pvtFilter').not(':checked').each ->
            exclusions.push $(this).data("filter")

        subopts.filter = (record) ->
            for [k,v] in exclusions
                return false if record[k] == v
            return true

        pivotTable.pivot(input,subopts)
        @data "pivotUIOptions",
            cols: subopts.cols
            rows: subopts.rows
            vals: vals
            hiddenAttributes: opts.hiddenAttributes
            renderers: opts.renderers
            aggregators: opts.aggregators
            derivedAttributes: opts.derivedAttributes
            aggregatorName: aggregator.val()
            rendererName: renderer.val()

    #the very first refresh will actually display the table
    refresh()

    @find(".pvtAxisContainer")
         .sortable({connectWith:".pvtAxisContainer", items: 'li'})
         .bind "sortstop", refresh

    return this

###
Heatmap post-processing
###

$.fn.heatmap = (scope = "heatmap") ->
    [numRows, numCols] = @data "dimensions"

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
    [numRows, numCols] = @data "dimensions"

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
