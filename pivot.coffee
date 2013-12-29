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

numberFormat = (sigfig=3, scaler=1, thousandsSep=",", decimalSep=".") ->
    (x) ->
        if x==0 or isNaN(x) or not isFinite(x) then ""
        else addSeparators (scaler*x).toFixed(sigfig), thousandsSep, decimalSep

#technically these are aggregator constructor generator generators (!)
aggregatorTemplates =
    sum: (sigfig=3, scaler=1) -> ([attr...]) -> ->
        sum: 0
        push: (record,idx) -> @sum += parseFloat(record[attr[idx]]) if not isNaN parseFloat(record[attr[idx]])
        value: -> @sum
        format: numberFormat(sigfig, scaler)
        label: "Sum of #{attr}"

    average:  (sigfig=3, scaler=1) -> ([attr...]) -> ->
        sum: 0
        len: 0
        push: (record,idx) ->
            if not isNaN parseFloat(record[attr[idx]])
                @sum += parseFloat(record[attr[idx]])
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

    fractionOf: (wrapped, type="total") -> (x...) -> (data, rowKey, colKey) ->
        selector: {total:[[],[]],row:[rowKey,[]],col:[[],colKey]}[type]
        inner: wrapped(x...)(data, rowKey, colKey)
        push: (record,idx) -> @inner.push record,idx
        format: (v) -> numberFormat(2)(100*v)+"%"
        label: wrapped(x...)(data, rowKey, colKey).label+" % of "+type
        value: (idx)-> 
            params=@selector
            params.push idx
            @inner.value() / data.getAggregator(params...).inner.value()

    l10nWrapper: ( wrapped, formatter, labelFn) -> (x...) -> (data, rowKey, colKey) ->
        inner: wrapped(x...)(data, rowKey, colKey)
        push: (record) -> @inner.push record
        format: formatter
        label: labelFn(data)
        value: -> @inner.value()

    compareWith: () -> ([attr...]) -> ->
        sumSource:0
        sumWith:0
        push: (record,idx,valAttribs) -> 
            # here idx not work
            idxs=valAttribs.split('->')
            @sumSource += parseFloat(record[idxs[0]]) if not isNaN parseFloat(record[idxs[0]])
            @sumWith += parseFloat(record[idxs[1]]) if not isNaN parseFloat(record[idxs[1]])
        format: (v) -> numberFormat(2)(100*v)+"%"
        label: "% of #{attr}"
        value: ()-> @sumSource / @sumWith

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

    listUnique: ([attr]) ->  ->
        uniq: []
        push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
        value: -> @uniq.join ", "
        format: (x) -> x
        label: "List Unique #{attr}"

    intSum: aggregatorTemplates.sum(0)
    sum: aggregatorTemplates.sum(3)
    average: aggregatorTemplates.average(3)
    compareWith: aggregatorTemplates.compareWith()
    sumOverSum: aggregatorTemplates.sumOverSum(3)
    ub80: aggregatorTemplates.sumOverSumBound80(3, 1, true)
    lb80: aggregatorTemplates.sumOverSumBound80(3, 1, false)

aggregators.sumAsFractionOfTotal= aggregatorTemplates.fractionOf(aggregators.sum)
aggregators.sumAsFractionOfRow= aggregatorTemplates.fractionOf(aggregators.sum, "row")
aggregators.sumAsFractionOfCol= aggregatorTemplates.fractionOf(aggregators.sum, "col")
aggregators.countAsFractionOfTotal= aggregatorTemplates.fractionOf(aggregators.count)
aggregators.countAsFractionOfRow= aggregatorTemplates.fractionOf(aggregators.count, "row")
aggregators.countAsFractionOfCol= aggregatorTemplates.fractionOf(aggregators.count, "col")


renderers =
    "Table": (pvtData, opts) -> pivotTableRenderer(pvtData, opts)
    "Table Barchart": (pvtData, opts) -> pivotTableRenderer(pvtData, opts).barchart()
    "Heatmap":      (pvtData, opts) -> pivotTableRenderer(pvtData, opts).heatmap()
    "Row Heatmap":  (pvtData, opts) -> pivotTableRenderer(pvtData, opts).heatmap("rowheatmap")
    "Col Heatmap":  (pvtData, opts) -> pivotTableRenderer(pvtData, opts).heatmap("colheatmap")

mthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
zeroPad = (number) -> ("0"+number).substr(-2,2)

derivers =
    bin: (col, binWidth) -> (record) -> record[col] - record[col] % binWidth
    dateFormat: (col, formatString) ->
        #thanks http://stackoverflow.com/a/12213072/112871
        (record) ->
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

naturalSort = (as, bs) => #from http://stackoverflow.com/a/4373421/112871
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


$.pivotUtilities = {aggregatorTemplates, aggregators, renderers, derivers, naturalSort, numberFormat}

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
convertToArray = (input) ->
    result = []
    forEachRecord input, {}, (record) -> result.push record
    return result

class PivotData
    constructor: (@aggregator, @colAttrs, @rowAttrs,  @valAttrs, @aggregatorKeys) ->
        @tree  = [@aggregatorKeys.length]#{}        
        @rowKeys = []
        @colKeys = []
        @flatRowKeys = []
        @flatColKeys = []
        @rowTotals = [@aggregatorKeys.length]#{}
        @colTotals = [@aggregatorKeys.length]#{}
        @allTotal=[@aggregatorKeys.length]
        @sorted = false

        
        if @aggregatorKeys.length==0
            @allTotal[0] = @aggregator[0](this, [], [])
            @rowTotals[0] = {}
            @colTotals[0] = {}
            @tree[0]  = {}
        else
            i=0
            while i < @aggregatorKeys.length
                @allTotal[i] = @aggregator[i](this, [], [])
                @rowTotals[i] = {}
                @colTotals[i] = {}
                @tree[i]  = {}
                i++
    

    natSort: (as, bs) => naturalSort(as, bs)

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

    processRecord: (record,aggregatorKeys) ->
        colKey = (record[x] for x in @colAttrs)
        rowKey = (record[x] for x in @rowAttrs)

        flatRowKey = @flattenKey rowKey
        flatColKey = @flattenKey colKey
        
        i=0
        while i<aggregatorKeys.length
            @allTotal[i].push record,i,@valAttrs[i]
            i++

        if rowKey.length != 0
            if flatRowKey not in @flatRowKeys
                @rowKeys.push rowKey
                @flatRowKeys.push flatRowKey
            
            i=0
            while i<aggregatorKeys.length
                if not @rowTotals[i][flatRowKey]
                    @rowTotals[i][flatRowKey] = @aggregator[i](this, rowKey, [])
                @rowTotals[i][flatRowKey].push record,i,@valAttrs[i]
                i++

        if colKey.length != 0
            if flatColKey not in @flatColKeys
                @colKeys.push colKey
                @flatColKeys.push flatColKey
            
            i=0
            while i<aggregatorKeys.length
                if not @colTotals[i][flatColKey]
                    @colTotals[i][flatColKey] = @aggregator[i](this, [], colKey)
                @colTotals[i][flatColKey].push record,i,@valAttrs[i]
                i++

        if colKey.length != 0 and rowKey.length != 0
            i=0
            while i<aggregatorKeys.length
                if flatRowKey not of @tree[i]
                    @tree[i][flatRowKey] = {}
                if flatColKey not of @tree[i][flatRowKey]
                    @tree[i][flatRowKey][flatColKey] = @aggregator[i](this, rowKey, colKey)
                @tree[i][flatRowKey][flatColKey].push record,i,@valAttrs[i]
                i++

    getAggregator: (rowKey, colKey,idx) =>
        flatRowKey = @flattenKey rowKey
        flatColKey = @flattenKey colKey
        if rowKey.length == 0 and colKey.length == 0
            agg = @allTotal[idx]
        else if rowKey.length == 0
            agg = @colTotals[idx][flatColKey]
        else if colKey.length == 0
            agg = @rowTotals[idx][flatRowKey]
        else
            agg = @tree[idx][flatRowKey][flatColKey]
        return agg ? {value: (-> null), format: -> ""}

getPivotData = (input, cols, rows, vals, aggregator, aggregatorKeys, filter, derivedAttributes) ->
    # iterate through input, accumulating data for cells
    pivotData = new PivotData(aggregator, cols, rows, vals, aggregatorKeys)
    forEachRecord input, derivedAttributes, (record) ->
        pivotData.processRecord(record,aggregatorKeys) if filter(record)
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

pivotTableRenderer = (pivotData, opts) ->

    defaults =
        localeStrings:
            totals: "Totals"

    opts = $.extend defaults, opts
    
    valAttrs = pivotData.valAttrs
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

        #\/ADD JAVG
        col_colspan = pivotData.aggregatorKeys.length
        col_rowspan = 1
        
        valsCount = col_colspan; #count of fields in aggregates
        #/\ADD JAVG

        for own i, colKey of colKeys
            x = spanSize(colKeys, parseInt(i), parseInt(j))
            if x != -1
                th = $("<th class='pvtColLabel'>").append(colKey[j]).attr("colspan", x * valsCount) #ADD JAVG
                if parseInt(j) == colAttrs.length-1 and rowAttrs.length != 0
                    th.attr("rowspan", col_rowspan)
                tr.append th
        if parseInt(j) == 0
            tr.append $("<th class='pvtTotalLabel'>").text(opts.localeStrings.totals)
                .attr("colspan", col_colspan)
                .attr("rowspan", col_rowspan)
        result.append tr

    #then a row for row header headers
    if rowAttrs.length !=0
        tr = $("<tr>")
        for own i, r of rowAttrs
            tr.append $("<th class='pvtAxisLabel'>").text(r)
         
         #\/ADD JAVG
        if colAttrs.length > 0
            th = $("<th>")
            tr.append(th)
            
        val = pivotData.valAttrs
                
        for own i, colKey of colKeys
            for own v, vKey of val
                tr.append($("<th class='pvtColLabel'>").append(vKey).data("value", vKey))

        for own v, vKey of val
            tr.append($("<th class='pvtColLabel'>").append(vKey).data("value", vKey))
        #/\ADD JAVG
        
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
            #\/MODIFIED JAVG
            xx=0
            while xx < pivotData.aggregatorKeys.length
                aggregator = pivotData.getAggregator(rowKey, colKey, xx)
                val = aggregator.value(xx)
                tr.append $("<td class='pvtVal row#{i} col#{j}'>")
                    .html(aggregator.format val)
                    .data("value", val)
                xx++
            
        xx=0
        while xx < pivotData.aggregatorKeys.length     
            totalAggregator = pivotData.getAggregator(rowKey, [],xx)
            val = totalAggregator.value(xx)
            tr.append $("<td class='pvtTotal rowTotal'>")
                .html(totalAggregator.format val)
                .data("value", val)
                .data("for", "row"+i)
            xx++
        #/\ADD JAVG    
        

        result.append tr

    #finally, the row for col totals, and a grand total
    tr = $("<tr>")
    th = $("<th class='pvtTotalLabel'>").text(opts.localeStrings.totals)
    th.attr("colspan", rowAttrs.length + (if colAttrs.length == 0 then 0 else 1))
    tr.append th
    #/\MODIFIED JAVG   
    for own j, colKey of colKeys
        xx=0
        while xx < pivotData.aggregatorKeys.length
            totalAggregator = pivotData.getAggregator([], colKey,xx)
            val = totalAggregator.value(xx)
            tr.append $("<td class='pvtTotal colTotal'>")
                .html(totalAggregator.format val)
                .data("value", val)
                .data("for", "col"+j)
            xx++
    xx=0
    while xx < pivotData.aggregatorKeys.length
        totalAggregator = pivotData.getAggregator([], [], xx) 

              
        val = totalAggregator.value(xx)
        tr.append $("<td class='pvtGrandTotal'>")
            .html(totalAggregator.format val)
            .data("value", val)
        xx++
    #/\MODIFIED JAVG
   
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
        vals:[]
        aggregatorKeys:[]
        filter: -> true
        aggregator: []#aggregators.count()
        derivedAttributes: {},
        renderer: pivotTableRenderer
        rendererOptions: null
        localeStrings:
            renderError: "An error occurred rendering the PivotTable results."
            computeError: "An error occurred computing the PivotTable results."

    opts = $.extend defaults, opts

    result = null
    try
        if opts.aggregatorKeys.length<=0
            opts.aggregator[0] = aggregators.count()

        pivotData = getPivotData(input, opts.cols, opts.rows, opts.vals
                                    opts.aggregator, opts.aggregatorKeys, opts.filter,
                                    opts.derivedAttributes)
        try
            result = opts.renderer(pivotData, opts.rendererOptions)
        catch e
            console.error(e.stack) if console?
            result = opts.localeStrings.renderError
    catch e
        console.error(e.stack) if console?
        result = opts.localeStrings.computeError

    @html result
    return this


###
UI code, calls pivot table above
###

$.fn.pivotUI = (input, inputOpts, overwrite = false) ->
    defaults =
        derivedAttributes: {}
        aggregators: []
        renderers: renderers
        hiddenAttributes: []
        menuLimit: 200
        tblCols:[]
        cols: [], rows: [], vals: [],aggregatorKeys:[]
        unusedAttrsVertical: false
        autoSortUnusedAttrs: false
        rendererOptions: null
        onRefresh: null
        filter: -> true
        localeStrings:
            renderError: "An error occurred rendering the PivotTable results."
            computeError: "An error occurred computing the PivotTable results."
            uiRenderError: "An error occurred rendering the PivotTable UI."
            selectAll: "Select All"
            selectNone: "Select None"
            tooMany: "(too many to list)"


    existingOpts = @data "pivotUIOptions"
    if not existingOpts? or overwrite
        opts = $.extend defaults, inputOpts
    else
        opts = existingOpts

    try
        #cache the input in some useful form
        input = convertToArray(input)
        tblCols = (k for own k of input[0])
        tblCols.push c for own c of opts.derivedAttributes when (c not in tblCols)

        opts.tblCols=tblCols

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
        colList = $("<td id='unused' class='pvtAxisContainer'>")
        if opts.unusedAttrsVertical
            colList.addClass('pvtVertList')
        else
            colList.addClass('pvtHorizList')

        shownAttributes = (c for c in tblCols when c not in opts.hiddenAttributes)
        for i, c of shownAttributes
            do (c) ->
                keys = (k for k of axisValues[c])
                valueList = $("<div>")
                    .addClass('pvtFilterBox')
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
                valueList.append $("<div>")
                    .css("text-align": "center", "font-weight": "bold")
                    .text("#{c} (#{keys.length})")
                if keys.length > opts.menuLimit
                    valueList.append $("<p>")
                        .css("text-align": "center")
                        .text(opts.localeStrings.tooMany)
                else
                    btns = $("<p>").css("text-align": "center")
                    btns.append $("<button>").text(opts.localeStrings.selectAll).bind "click", ->
                        valueList.find("input").prop "checked", true
                    btns.append $("<button>").text(opts.localeStrings.selectNone).bind "click", ->
                        valueList.find("input").prop "checked", false
                    valueList.append btns
                    for k in keys.sort(naturalSort)
                         v = axisValues[c][k]
                         filterItem = $("<label>")
                         filterItem.append $("<input type='checkbox' class='pvtFilter'>")
                            .attr("checked", true).data("filter", [c,k])
                         filterItem.append $("<span>").text "#{k} (#{v})"
                         valueList.append $("<p>").append(filterItem)

                attrElem = $("<li class='label label-info' id='axis_#{i}'>")
                    .append $("<div id='div_axis_#{i}'>")
                    .append $("<nobr>").text(c)
                    
                colList.append(attrElem).append(valueList)

                attrElem.bind "dblclick", (e) ->
                    valueList.css(left: e.pageX, top: e.pageY).toggle()
                    valueList.bind "click", (e) -> e.stopPropagation()
                    $(document).one "click", ->
                        unselectedCount = $(valueList).find("[type='checkbox']").length -
                                          $(valueList).find("[type='checkbox']:checked").length
                        if unselectedCount > 0
                            attrElem.addClass "pvtFilteredAttribute"
                        else
                            attrElem.removeClass "pvtFilteredAttribute"
                        refresh()
                        valueList.toggle()

        #aggregator menu and value area
        #THIS isn't util, because each attr in vals has an aggregator
        aggregator = $("<select id='aggregator'>")
            .css("margin-bottom", "5px")
            .bind "change", -> refresh() #capture reference
        for own x of opts.aggregators
            aggregator.append $("<option>").val(x).text(x)
        
        #\/ADD JAVG
        #compare controls, aggregator
        #I put a way to compare two columns
        selectCompareControl= $("<td>")
        selectCompare1= $("<select id='toCompare1'>")
        selectCompare2= $("<select id='toCompare2'>")
        buttonCompare= $("<button id='toComparebtn'>")
            .text("Agregar")
            .bind "click", ->

                optionSelected1=$("#toCompare1 option:selected")
                optionSelected2=$("#toCompare2 option:selected")
                #add field to vals area
                cantidadCampos = $(".pvtAxisContainer").find("li").length
                ++cantidadCampos
                cuentaSelect = $(event.target).find("select").legth
                ++cuentaSelect

                selectCompare= $("<select id='aggregator" + (++cuentaSelect) + "'>")
                $.each opts.aggregators, (key, value) ->
                        if(key.toUpperCase().indexOf("COMPARE")>=0) #are not necesary all
                            selectCompare.append $("<option>").val(key).text(key)
                selectCompare.val("compareWith").attr("disabled", true)

                #aggregatorCompare.find(":selected")
                newVal = $("<li class='label label-info' id='axis_#{cantidadCampos}'>")
                    .append $("<div id='div_axis_#{cantidadCampos}'>")
                newVal.append $("<nobr>").text(optionSelected1.text() + "->" + optionSelected2.text())
                newVal.append selectCompare 
                $("#vals").append newVal

                #refresh
                refresh()

        for i, x of shownAttributes
            selectCompare1.append $("<option>").val(x).text(x)
            selectCompare2.append $("<option>").val(x).text(x)
        selectCompareControl.append($("<nobr>").text("Campo 1")).append(selectCompare1)
        selectCompareControl.append($("<nobr>").text("Campo 2")).append(selectCompare2)
        selectCompareControl.append buttonCompare


        tr2 = $("<tr>")
        tr2.append $("<td id='vals' class='pvtAxisContainer pvtHorizList'>")
          .css("text-align", "center")
        #/\ADD JAVG

        #column axes
        tr2.append $("<td id='cols' class='pvtAxisContainer pvtHorizList'>")
        uiTable.append tr2

        tr3 = $("<tr>")

        #row axes
        tr3.append $("<td valign='top' id='rows' class='pvtAxisContainer'>")

        #the actual pivot table container
        pivotTable = $("<td valign='top' class='pvtRendererArea'>")
        tr3.append pivotTable

        uiTable.append tr3

        #finally the renderer dropdown and unused attribs are inserted at the requested location
        if opts.unusedAttrsVertical
            uiTable.find('tr:nth-child(1)').prepend selectCompareControl
            uiTable.find('tr:nth-child(2)').prepend colList.css('vertical-align','top')
        else
            uiTable.prepend $("<tr>").append(selectCompareControl).append(colList)

        tr1 = $("<tr>")
        tr1.append rendererControl
        uiTable.prepend tr1
        #render the UI in its default state
        @html uiTable

        #set up the UI initial state as requested by moving elements around

        for x in opts.cols
            @find("#cols").append @find("#axis_#{shownAttributes.indexOf(x)}")
        for x in opts.rows
            @find("#rows").append @find("#axis_#{shownAttributes.indexOf(x)}")
        for x in opts.vals
            @find("#vals").append @find("#axis_#{shownAttributes.indexOf(x)}")
        if opts.aggregatorName?
            @find("#aggregator").val opts.aggregatorName
        if opts.rendererName?
            @find("#renderer").val opts.rendererName

        #set up for refreshing
        refresh = =>
            subopts =
                derivedAttributes: opts.derivedAttributes
                localeStrings: opts.localeStrings
                rendererOptions: opts.rendererOptions
                aggregator:[]
                cols: [], rows: [], vals: [], aggregatorKeys:[] #ADD JAVG

            @find("#rows li nobr").each -> subopts.rows.push $(this).text()
            @find("#cols li nobr").each -> subopts.cols.push $(this).text()
            @find("#vals li nobr").each -> subopts.vals.push $(this).text()
            @find("#vals li select option:selected").each -> subopts.aggregatorKeys.push $(this).text() #ADD JAVG
            
            #Ejecutar el array de aggregators
            i=0
            while i < subopts.aggregatorKeys.length
                subopts.aggregator[i] = opts.aggregators[subopts.aggregatorKeys[i]](subopts.vals,i)
                i++

            
            subopts.renderer = opts.renderers[renderer.val()]

            #construct filter here
            exclusions = []
            @find('input.pvtFilter').not(':checked').each ->
                exclusions.push $(this).data("filter")

            subopts.filter = (record) ->
                return false if not opts.filter(record)
                for [k,v] in exclusions
                    return false if "#{record[k]}" == v
                return true

            pivotTable.pivot(input,subopts)
            @data "pivotUIOptions",
                cols: subopts.cols
                rows: subopts.rows
                vals: subopts.vals
                hiddenAttributes: opts.hiddenAttributes
                renderers: opts.renderers
                aggregators: opts.aggregators
                derivedAttributes: opts.derivedAttributes
                aggregatorName: aggregator.val()
                rendererName: renderer.val()
                localeStrings: opts.localeStrings
                rendererOptions: opts.rendererOptions

            # if requested make sure unused columns are in alphabetical order
            if opts.autoSortUnusedAttrs
                natSort = $.pivotUtilities.naturalSort
                unusedAttrsContainer = $("td#unused.pvtAxisContainer")
                $(unusedAttrsContainer).children("li")
                    .sort((a, b) => natSort($(a).text(), $(b).text()))
                    .appendTo unusedAttrsContainer

            opts.onRefresh() if opts.onRefresh?

        #the very first refresh will actually display the table
        refresh()

        @find(".pvtAxisContainer")
             .sortable({connectWith:".pvtAxisContainer", items: 'li',
             #\/ADD JAVG
             #When an attribute is added to vals area, a <select> is created, so the user select its aggregator
             receive: (event, ui) ->
                #Remover primero todo lo sobrante, todos los selects
                ui.item.find("select").remove()
                #Remover los controles anexos
                i = 0
                ui.item.find("div").each ->
                    $(this).remove()  if i > 0
                    i++

                if event.target.id == "vals"
                    #Agregar el combo de modos de agregación
                    cuentaSelect = 0

                    $(event.target).find("select").each -> ++cuentaSelect
                    select = $("<select id='aggregator" + (++cuentaSelect) + "'>")
                        .bind "change", ->
                            if $(this).val()=="sum" || $(this).val()=="count"
                                newItemConSelect=$(this).parent().clone()
                                newSelect=newItemConSelect.children("select")
                                newSelect.find("option").remove()
                                newSelect.bind "change", ->
                                    refresh()

                                aggregatorSelected=$(this).val()
                                $.each opts.aggregators, (key, value) ->
                                    if (aggregatorSelected=="sum" && key.toUpperCase().indexOf("SUMASFRACTION")>=0) || (aggregatorSelected=="count" && key.toUpperCase().indexOf("COUNTASFRACTION")>=0)
                                        newSelect.append $("<option>").val(key).text(key)

                                newItemConSelect.appendTo($(this).parents("li").get(0))

                            refresh() #capture reference
                    $.each opts.aggregators, (key, value) ->
                        if(!(key.toUpperCase().indexOf("ASFRACTION")>0 || key.toUpperCase().indexOf("COMPARE")>0))
                            select.append $("<option>").val(key).text(key)
                    #for own x of opts.aggregators.filter(function (el) {  return el.price <= 1000 &&
                        
                    
                    $("#" + ui.item.attr("id") + " div").append(select) #Agregar al area de vals
            #/\ADD JAVG
            })
             .bind "sortstop", refresh
    catch e
        console.error(e.stack) if console?
        @html opts.localeStrings.uiRenderError
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
