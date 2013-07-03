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
    sum: (sigfig=3, scaler=1) -> ([field]) -> ->
        sum: 0
        push: (row) -> @sum += parseFloat(row[field]) if not isNaN parseFloat(row[field])
        value: -> @sum
        format: numberFormat(sigfig, scaler)

    average:  (sigfig=3, scaler=1) -> ([field]) -> ->
        sum: 0
        len: 0
        push: (row) ->
            if not isNaN parseFloat(row[field])
                @sum += parseFloat(row[field])
                @len++
        value: -> @sum/@len
        format: numberFormat(sigfig, scaler)

    sumOverSum: (sigfig=3, scaler=1) -> ([num, denom]) -> ->
        sumNum: 0
        sumDenom: 0
        push: (row) ->
            @sumNum   += parseFloat(row[num])   if not isNaN parseFloat(row[num])
            @sumDenom += parseFloat(row[denom]) if not isNaN parseFloat(row[denom])
        value: -> @sumNum/@sumDenom
        format: numberFormat(sigfig, scaler)

    sumOverSumBound80: (sigfig=3, scaler=1, upper=true) -> ([num, denom]) -> ->
        sumNum: 0
        sumDenom: 0
        push: (row) ->
            @sumNum   += parseFloat(row[num])   if not isNaN parseFloat(row[num])
            @sumDenom += parseFloat(row[denom]) if not isNaN parseFloat(row[denom])
        value: ->
            sign = if upper then 1 else -1
            (0.821187207574908/@sumDenom + @sumNum/@sumDenom + 1.2815515655446004*sign*
                Math.sqrt(0.410593603787454/ (@sumDenom*@sumDenom) + (@sumNum*(1 - @sumNum/ @sumDenom))/ (@sumDenom*@sumDenom)))/
                (1 + 1.642374415149816/@sumDenom)
        format: numberFormat(sigfig, scaler)

#technically these are aggregator constructor generators (!)
aggregators =
    count: -> ->
        count: 0
        push:  -> @count++
        value: -> @count
        format: numberFormat(0)

    countUnique: ([field]) -> ->
        uniq: []
        push: (row) -> @uniq.push(row[field]) if row[field] not in @uniq
        value: -> @uniq.length
        format: numberFormat(0)

    listUnique: ([field]) -> ->
        uniq: []
        push: (row) -> @uniq.push(row[field]) if row[field] not in @uniq
        value: -> @uniq.join ", "
        format: (x) -> x

    intSum: aggregatorTemplates.sum(0)
    sum: aggregatorTemplates.sum(3)
    average: aggregatorTemplates.average(3)
    sumOverSum: aggregatorTemplates.sumOverSum(3)
    ub80: aggregatorTemplates.sumOverSumBound80(3, 1, true)
    lb80: aggregatorTemplates.sumOverSumBound80(3, 1, false)


effects =
    "Row Barchart": (x) -> x.barchart()
    "Heatmap": (x) -> x.heatmap()
    "Row Heatmap": (x) -> x.heatmap("rowheatmap")
    "Col Heatmap": (x) -> x.heatmap("colheatmap")

derivers =
    bin: (selector, binWidth) ->
        if "string" == typeof selector
            select = (x) -> x[selector]
        else
            select = selector
        (row) -> "#{select(row) - select(row) % binWidth}"


$.pivotUtilities = {aggregatorTemplates, aggregators, effects, derivers}

###
functions for accessing input
###

deriveAttributes = (row, derivedAttributes, f) ->
    row[k] = v(row) ? row[k] for k, v of derivedAttributes
    row[k] ?= "null" for own k of row
    f(row)

#can handle arrays or jQuery selections of tables
forEachRow = (input, derivedAttributes, f) ->
    addRow = (row) -> deriveAttributes(row, derivedAttributes, f)
    #if it's a function, have it call us back
    if Object.prototype.toString.call(input) == '[object Function]'
        input(addRow)
    else if Array.isArray(input)
        if Array.isArray(input[0]) #array of arrays
            for own i, compactRow of input when i > 0
                row = {}
                row[k] = compactRow[j] for own j, k of input[0]
                addRow(row)
        else #array of objects
            addRow(row) for row in input
    else #assume a jQuery reference to a table
        tblCols = []
        $("thead > tr > th", input).each (i) -> tblCols.push $(this).text()
        $("tbody > tr", input).each (i) ->
            row = {}
            $("td", this).each (j) -> row[tblCols[j]] = $(this).text()
            addRow(row)

#converts to [{field:val, field:val},{field:val, field:val}] using method above
convertToArray = (input) ->
    result = []
    forEachRow input, {}, (row) -> result.push row
    return result

###
Pivot Table
###

$.fn.pivot = (input, opts) ->
    defaults =
        filter: -> true
        aggregator: aggregators.count()
        derivedAttributes: {},
        postProcessor: ->

    opts = $.extend defaults, opts

    # iterate through input, accumulating data for cells
    rows = []
    rowAs = []
    cols = []
    colAs = []
    tree = {}
    totals = {rows:{}, cols:{}, all: opts.aggregator()}
    forEachRow input, opts.derivedAttributes, (row) ->
        if opts.filter(row)
            cA = (row[x] for x in opts.cols)
            c = cA.join("-")
            rA = (row[x] for x in opts.rows)
            r = rA.join("-")
            totals.all.push row
            if r != ""
                if r not in rows
                    rowAs.push rA
                    rows.push r
                totals.rows[r] = opts.aggregator() if not totals.rows[r]
                totals.rows[r].push row
            if c != ""
                if c not in cols
                    colAs.push cA
                    cols.push c
                totals.cols[c] = opts.aggregator() if not totals.cols[c]
                totals.cols[c].push row
            if c != "" and r != ""
                tree[r] = {} if r not of tree
                tree[r][c] = opts.aggregator() if c not of tree[r]
                tree[r][c].push row

    #sort row/col axes for proper row/col-spanning

    strSort = (a,b) ->
        return  1 if a > b
        return -1 if a < b
        return  0

    arrSort = (a,b) -> strSort a.join(), b.join()

    rowAs = rowAs.sort arrSort
    colAs = colAs.sort arrSort

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

    #now actually build the output
    result = $("<table class='table table-bordered pvtTable'>")

    #the first few rows are for col headers
    for own j, c of opts.cols
        tr = $("<tr>")
        if parseInt(j) == 0 and opts.rows.length != 0
            tr.append $("<th>")
                .attr("colspan", opts.rows.length)
                .attr("rowspan", opts.cols.length)
        tr.append $("<th class='pvtAxisLabel'>").text(c)
        for own i, cA of colAs
            x = spanSize(colAs, parseInt(i), parseInt(j))
            if x != -1
                th = $("<th class='pvtColLabel'>").text(cA[j]).attr("colspan", x)
                if parseInt(j) == opts.cols.length-1 and opts.rows.length != 0
                    th.attr("rowspan", 2)
                tr.append th
        if parseInt(j) == 0
            tr.append $("<th class='pvtTotalLabel'>").text("Totals")
                .attr("rowspan", opts.cols.length + (if opts.rows.length ==0 then 0 else 1))
        result.append tr

    #then a row for row header headers
    if opts.rows.length !=0
        tr = $("<tr>")
        for own i, r of opts.rows
            tr.append $("<th class='pvtAxisLabel'>").text(r)
        th = $("<th>")
        if opts.cols.length ==0
            th.addClass("pvtTotalLabel").text("Totals")
        tr.append th
        result.append tr

    nullAggregator =
        value: -> null
        format: -> ""

    #now the actual data rows, with their row headers and totals
    for own i, rA of rowAs
        tr = $("<tr>")
        for own j, txt of rA
            x = spanSize(rowAs, parseInt(i), parseInt(j))
            if x != -1
                th = $("<th class='pvtRowLabel'>").text(txt).attr("rowspan", x)
                if parseInt(j) == opts.rows.length-1 and opts.cols.length !=0
                    th.attr("colspan",2)
                tr.append th
        for own j, cA of colAs
            aggregator = (tree[rA.join("-")][cA.join("-")] ? nullAggregator)
            val = aggregator.value()
            tr.append $("<td class='pvtVal row#{i} col#{j}'>")
                .text(aggregator.format val)
                .data("value", val)

        totalAggregator = (totals.rows[rA.join("-")] ? nullAggregator)
        val = totalAggregator.value()
        tr.append $("<td class='pvtTotal rowTotal'>")
            .text(totalAggregator.format val)
            .data("value", val)
            .data("for", "row"+i)
        result.append tr

    #finally, the row for col totals, and a grand total
    tr = $("<tr>")
    th = $("<th class='pvtTotalLabel'>").text("Totals")
    th.attr("colspan", opts.rows.length + (if opts.cols.length == 0 then 0 else 1))
    tr.append th
    for own j, ca of colAs
        totalAggregator = (totals.cols[ca.join("-")] ? nullAggregator)
        val = totalAggregator.value()
        tr.append $("<td class='pvtTotal colTotal'>")
            .text(totalAggregator.format val)
            .data("value", val)
            .data("for", "col"+j)
    val = totals.all.value()
    tr.append $("<td class='pvtGrandTotal'>")
        .text(totals.all.format val)
        .data("value", val)
    result.append tr

    #squirrel this away for later
    result.data "dimensions", [rowAs.length, colAs.length]
    @html(result)

    opts.postProcessor result

    return this

###
UI code, calls pivot table above
###

$.fn.pivotUI = (input, opts) ->
    defaults =
        derivedAttributes: {}
        aggregators: aggregators
        effects: effects
        hiddenAxes: []
        cols: [], rows: [], vals: []
    opts = $.extend defaults, opts

    #cache the input in some useful form
    input = convertToArray(input)
    tblCols = (k for own k of input[0])
    tblCols.push c for own c of opts.derivedAttributes when (c not in tblCols)

    #figure out the cardinality and some stats
    axisValues = {}
    axisValues[x] = {} for x in tblCols

    forEachRow input, opts.derivedAttributes, (row) ->
        for own k, v of row
            v ?= "null"
            axisValues[k][v] ?= 0
            axisValues[k][v]++

    #start building the output
    uiTable = $("<table class='table table-bordered' cellpadding='5'>")

    #effects controls, if desired

    effectNames = (x for own x, y of opts.effects)
    if effectNames.length != 0
        effectNames.unshift "None"
        controls = $("<td colspan='2' align='center'>")
        form = $("<form>").addClass("form-inline")
        controls.append form

        form.append $("<strong>").text("Effects:")
        for x in effectNames
            radio = $("<input type='radio' name='effects' id='effects_#{x.replace(/\s/g, "")}'>")
              .css("margin-left":"15px", "margin-right": "5px").val(x)
            radio.attr("checked", "checked") if x=="None"
            form.append(radio).append $("<label class='checkbox inline' for='effects_#{x.replace(/\s/g, "")}'>").text(x)

        uiTable.append $("<tr>").append controls

    #axis list, including the double-click menu

    colList = $("<td colspan='2' id='unused' class='pvtAxisContainer pvtHorizList'>")

    for c in tblCols when c not in opts.hiddenAxes
        do (c) ->
            numKeys = Object.keys(axisValues[c]).length
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
            valueList.append $("<strong>").text "#{numKeys} values for #{c}"
            if numKeys > 20
                valueList.append $("<p>").text "(too many to list)"
            else
                btns = $("<p>")
                btns.append $("<button>").text("Select All").bind "click", ->
                    valueList.find("input").attr "checked", true
                btns.append $("<button>").text("Select None").bind "click", ->
                    valueList.find("input").attr "checked", false
                valueList.append btns
                for k in Object.keys(axisValues[c]).sort()
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


    uiTable.append $("<tr>").append colList

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
        $("#cols").append $("#axis_#{x.replace(/\s/g, "")}")
    for x in opts.rows
        $("#rows").append $("#axis_#{x.replace(/\s/g, "")}")
    for x in opts.vals
        $("#vals").append $("#axis_#{x.replace(/\s/g, "")}")
    if opts.aggregatorName?
        $("#aggregator").val opts.aggregatorName
    if opts.effectsName?
        $("#effects_#{opts.effectsName.replace(/\s/g, "")}").attr('checked',true)

    #set up for refreshing
    refresh = ->
        subopts = {derivedAttributes: opts.derivedAttributes}
        subopts.cols = []
        subopts.rows = []
        vals = []
        $("#rows li nobr").each -> subopts.rows.push $(this).text()
        $("#cols li nobr").each -> subopts.cols.push $(this).text()
        $("#vals li nobr").each -> vals.push $(this).text()

        subopts.aggregator = opts.aggregators[aggregator.val()](vals)

        #construct filter here
        exclusions = []
        $('input.pvtFilter').not(':checked').each ->
            exclusions.push $(this).data("filter")

        subopts.filter = (row) ->
            for [k,v] in exclusions
                return false if row[k] == v
            return true

        if effectNames.length != 0
            effect = $('input[name=effects]:checked').val()
            if effect != "None"
                subopts.postProcessor = opts.effects[effect]

        pivotTable.pivot(input,subopts)

    #the very first refresh will actually display the table
    refresh()

    #finally we attach the event handlers
    $('input[name=effects]').bind "change", refresh
    $(".pvtAxisContainer")
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
