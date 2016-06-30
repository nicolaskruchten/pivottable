callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->

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

    #aggregator templates default to US number formatting but this is overrideable
    usFmt = numberFormat()
    usFmtInt = numberFormat(digitsAfterDecimal: 0)
    usFmtPct = numberFormat(digitsAfterDecimal:1, scaler: 100, suffix: "%")

    aggregatorTemplates =
        count: (formatter=usFmtInt) -> () -> (data, rowKey, colKey) ->
            count: 0
            push:  -> @count++
            value: -> @count
            format: formatter

        countUnique: (formatter=usFmtInt) -> ([attr]) -> (data, rowKey, colKey) ->
            uniq: []
            push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
            value: -> @uniq.length
            format: formatter
            numInputs: if attr? then 0 else 1

        listUnique: (sep) -> ([attr]) -> (data, rowKey, colKey)  ->
            uniq: []
            push: (record) -> @uniq.push(record[attr]) if record[attr] not in @uniq
            value: -> @uniq.join sep
            format: (x) -> x
            numInputs: if attr? then 0 else 1

        sum: (formatter=usFmt) -> ([attr]) -> (data, rowKey, colKey) ->
            sum: 0
            push: (record) -> @sum += parseFloat(record[attr]) if not isNaN parseFloat(record[attr])
            value: -> @sum
            format: formatter
            numInputs: if attr? then 0 else 1

        min: (formatter=usFmt) -> ([attr]) -> (data, rowKey, colKey) ->
            val: null
            push: (record) ->
                x = parseFloat(record[attr])
                if not isNaN x then @val = Math.min(x, @val ? x)
            value: -> @val
            format: formatter
            numInputs: if attr? then 0 else 1

        max: (formatter=usFmt) -> ([attr]) -> (data, rowKey, colKey) ->
            val: null
            push: (record) -> 
                x = parseFloat(record[attr])
                if not isNaN x then @val = Math.max(x, @val ? x)
            value: -> @val
            format: formatter
            numInputs: if attr? then 0 else 1

        average:  (formatter=usFmt) -> ([attr]) -> (data, rowKey, colKey) ->
            sum: 0
            len: 0
            push: (record) ->
                if not isNaN parseFloat(record[attr])
                    @sum += parseFloat(record[attr])
                    @len++
            value: -> @sum/@len
            format: formatter
            numInputs: if attr? then 0 else 1

        sumOverSum: (formatter=usFmt) -> ([num, denom]) -> (data, rowKey, colKey) ->
            sumNum: 0
            sumDenom: 0
            push: (record) ->
                @sumNum   += parseFloat(record[num])   if not isNaN parseFloat(record[num])
                @sumDenom += parseFloat(record[denom]) if not isNaN parseFloat(record[denom])
            value: -> @sumNum/@sumDenom
            format: formatter
            numInputs: if num? and denom? then 0 else 2

        sumOverSumBound80: (upper=true, formatter=usFmt) -> ([num, denom]) -> (data, rowKey, colKey) ->
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
            format: formatter
            numInputs: if num? and denom? then 0 else 2

        fractionOf: (wrapped, type="total", formatter=usFmtPct) -> (x...) -> (data, rowKey, colKey) ->
            selector: {total:[[],[]],row:[rowKey,[]],col:[[],colKey]}[type]
            inner: wrapped(x...)(data, rowKey, colKey)
            push: (record) -> @inner.push record
            format: formatter
            value: -> @inner.value() / data.getAggregator(@selector...).inner.value()
            numInputs: wrapped(x...)().numInputs

    #default aggregators & renderers use US naming and number formatting
    aggregators = do (tpl = aggregatorTemplates) -> 
        "Count":                tpl.count(usFmtInt)
        "Count Unique Values":  tpl.countUnique(usFmtInt)
        "List Unique Values":   tpl.listUnique(", ")
        "Sum":                  tpl.sum(usFmt)
        "Integer Sum":          tpl.sum(usFmtInt)
        "Average":              tpl.average(usFmt)
        "Minimum":              tpl.min(usFmt)
        "Maximum":              tpl.max(usFmt)
        "Sum over Sum":         tpl.sumOverSum(usFmt)
        "80% Upper Bound":      tpl.sumOverSumBound80(true, usFmt)
        "80% Lower Bound":      tpl.sumOverSumBound80(false, usFmt)
        "Sum as Fraction of Total":     tpl.fractionOf(tpl.sum(),   "total", usFmtPct)
        "Sum as Fraction of Rows":      tpl.fractionOf(tpl.sum(),   "row",   usFmtPct)
        "Sum as Fraction of Columns":   tpl.fractionOf(tpl.sum(),   "col",   usFmtPct)
        "Count as Fraction of Total":   tpl.fractionOf(tpl.count(), "total", usFmtPct)
        "Count as Fraction of Rows":    tpl.fractionOf(tpl.count(), "row",   usFmtPct)
        "Count as Fraction of Columns": tpl.fractionOf(tpl.count(), "col",   usFmtPct)

    renderers =
        "Table":          (data, opts) ->   pivotTableRenderer(data, opts)
        "Table Barchart": (data, opts) -> $(pivotTableRenderer(data, opts)).barchart()
        "Heatmap":        (data, opts) -> $(pivotTableRenderer(data, opts)).heatmap("heatmap",    opts)
        "Row Heatmap":    (data, opts) -> $(pivotTableRenderer(data, opts)).heatmap("rowheatmap", opts)
        "Col Heatmap":    (data, opts) -> $(pivotTableRenderer(data, opts)).heatmap("colheatmap", opts)

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
        dateFormat: (col, formatString, utcOutput=false, mthNames=mthNamesEn, dayNames=dayNamesEn) ->
            utc = if utcOutput then "UTC" else ""
            (record) -> #thanks http://stackoverflow.com/a/12213072/112871
                date = new Date(Date.parse(record[col]))
                if isNaN(date) then return ""
                formatString.replace /%(.)/g, (m, p) ->
                    switch p
                        when "y" then date["get#{utc}FullYear"]()
                        when "m" then zeroPad(date["get#{utc}Month"]()+1)
                        when "n" then mthNames[date["get#{utc}Month"]()]
                        when "d" then zeroPad(date["get#{utc}Date"]())
                        when "w" then dayNames[date["get#{utc}Day"]()]
                        when "x" then date["get#{utc}Day"]()
                        when "H" then zeroPad(date["get#{utc}Hours"]())
                        when "M" then zeroPad(date["get#{utc}Minutes"]())
                        when "S" then zeroPad(date["get#{utc}Seconds"]())
                        else "%" + p

    naturalSort = (as, bs) => #thanks http://stackoverflow.com/a/4373421/112871
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

    sortAs = (order) -> 
        mapping = {}
        for i, x of order
            mapping[x] = i
        (a, b) ->
            if mapping[a]? and mapping[b]?
                return mapping[a] - mapping[b]
            else if mapping[a]?
                return -1
            else if mapping[b]?
                return 1
            else
                return naturalSort(a,b)

    getSort = (sorters, attr) ->
        sort = sorters(attr)
        if $.isFunction(sort)
            return sort 
        else
            return naturalSort

    ###
    Data Model class
    ###

    class PivotData
        constructor: (input, opts) ->
            @aggregator = opts.aggregator
            @aggregatorName = opts.aggregatorName
            @colAttrs = opts.cols
            @rowAttrs = opts.rows
            @valAttrs = opts.vals
            @sorters = opts.sorters
            @tree = {}
            @rowKeys = []
            @colKeys = []
            @rowTotals = {}
            @colTotals = {}
            @allTotal = @aggregator(this, [], [])
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

        arrSort: (attrs) => 
            sortersArr = (getSort(@sorters, a) for a in attrs)
            (a,b) -> 
                for own i, sorter of sortersArr
                    comparison = sorter(a[i], b[i])
                    return comparison if comparison != 0
                return 0

        sortKeys: () =>
            if not @sorted
                @sorted = true
                @rowKeys.sort @arrSort(@rowAttrs)
                @colKeys.sort @arrSort(@colAttrs)

        getColKeys: () =>
            @sortKeys()
            return @colKeys

        getRowKeys: () =>
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
                    @rowTotals[flatRowKey] = @aggregator(this, rowKey, [])
                @rowTotals[flatRowKey].push record

            if colKey.length != 0
                if not @colTotals[flatColKey]
                    @colKeys.push colKey
                    @colTotals[flatColKey] = @aggregator(this, [], colKey)
                @colTotals[flatColKey].push record

            if colKey.length != 0 and rowKey.length != 0
                if not @tree[flatRowKey]
                    @tree[flatRowKey] = {}
                if not @tree[flatRowKey][flatColKey]
                    @tree[flatRowKey][flatColKey] = @aggregator(this, rowKey, colKey)
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

    #expose these to the outside world
    $.pivotUtilities = {aggregatorTemplates, aggregators, renderers, derivers, locales,
        naturalSort, numberFormat, sortAs, PivotData}

    ###
    Default Renderer for hierarchical table layout
    ###

    pivotTableRenderer = (pivotData, opts) ->

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

        #helper function for setting row/col-span in pivotTableRenderer
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
        thead = document.createElement("thead")
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
            thead.appendChild tr

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
            thead.appendChild tr
        result.appendChild thead

        #now the actual data rows, with their row headers and totals
        tbody = document.createElement("tbody")
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
                td.textContent = aggregator.format(val)
                td.setAttribute("data-value", val)
                tr.appendChild td

            totalAggregator = pivotData.getAggregator(rowKey, [])
            val = totalAggregator.value()
            td = document.createElement("td")
            td.className = "pvtTotal rowTotal"
            td.textContent = totalAggregator.format(val)
            td.setAttribute("data-value", val)
            td.setAttribute("data-for", "row"+i)
            tr.appendChild td
            tbody.appendChild tr

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
            td.textContent = totalAggregator.format(val)
            td.setAttribute("data-value", val)
            td.setAttribute("data-for", "col"+j)
            tr.appendChild td
        totalAggregator = pivotData.getAggregator([], [])
        val = totalAggregator.value()
        td = document.createElement("td")
        td.className = "pvtGrandTotal"
        td.textContent = totalAggregator.format(val)
        td.setAttribute("data-value", val)
        tr.appendChild td
        tbody.appendChild tr
        result.appendChild tbody

        #squirrel this away for later
        result.setAttribute("data-numrows", rowKeys.length)
        result.setAttribute("data-numcols", colKeys.length)

        return result

    ###
    Pivot Table core: create PivotData object and call Renderer on it
    ###

    $.fn.pivot = (input, opts) ->
        defaults =
            cols : []
            rows: []
            vals: []
            dataClass: PivotData
            filter: -> true
            aggregator: aggregatorTemplates.count()()
            aggregatorName: "Count"
            sorters: -> 
            derivedAttributes: {},
            renderer: pivotTableRenderer
            rendererOptions: null
            localeStrings: locales.en.localeStrings

        opts = $.extend defaults, opts

        result = null
        try
            pivotData = new opts.dataClass(input, opts)
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


    ###
    Pivot Table UI: calls Pivot Table core above with options set by user
    ###

    $.fn.pivotUI = (input, inputOpts, overwrite = false, locale="en") ->
        if not locales[locale]?
            locale = "en"
        defaults =
            derivedAttributes: {}
            aggregators: locales[locale].aggregators
            renderers: locales[locale].renderers
            hiddenAttributes: []
            menuLimit: 200
            cols: [], rows: [], vals: []
            dataClass: PivotData
            exclusions: {}
            inclusions: {}
            unusedAttrsVertical: 85
            autoSortUnusedAttrs: false
            rendererOptions: localeStrings: locales[locale].localeStrings
            onRefresh: null
            filter: -> true
            sorters: -> 
            localeStrings: locales[locale].localeStrings

        existingOpts = @data "pivotUIOptions"
        if not existingOpts? or overwrite
            opts = $.extend defaults, inputOpts
        else
            opts = existingOpts

        try
            #cache the input in some useful form
            input = PivotData.convertToArray(input)
            tblCols = (k for own k of input[0])
            tblCols.push c for own c of opts.derivedAttributes when (c not in tblCols)

            #figure out the cardinality and some stats
            axisValues = {}
            axisValues[x] = {} for x in tblCols

            PivotData.forEachRecord input, opts.derivedAttributes, (record) ->
                for own k, v of record when opts.filter(record)
                    v ?= "null"
                    axisValues[k][v] ?= 0
                    axisValues[k][v]++

            #start building the output
            uiTable = $("<table>", "class": "pvtUi").attr("cellpadding", 5)

            #renderer control
            rendererControl = $("<td>")

            renderer = $("<select>")
                .addClass('pvtRenderer')
                .appendTo(rendererControl)
                .bind "change", -> refresh() #capture reference
            for own x of opts.renderers
                $("<option>").val(x).html(x).appendTo(renderer)


            #axis list, including the double-click menu
            colList = $("<td>").addClass('pvtAxisContainer pvtUnused')
            shownAttributes = (c for c in tblCols when c not in opts.hiddenAttributes)

            unusedAttrsVerticalAutoOverride = false
            if opts.unusedAttrsVertical == "auto"
                unusedAttrsVerticalAutoCutoff = 120 # legacy support
            else
                unusedAttrsVerticalAutoCutoff = parseInt opts.unusedAttrsVertical

            if not isNaN(unusedAttrsVerticalAutoCutoff)
                attrLength = 0
                attrLength += a.length for a in shownAttributes
                unusedAttrsVerticalAutoOverride = attrLength > unusedAttrsVerticalAutoCutoff

            if opts.unusedAttrsVertical == true or unusedAttrsVerticalAutoOverride
                colList.addClass('pvtVertList')
            else
                colList.addClass('pvtHorizList')

            for own i, c of shownAttributes
                do (c) ->
                    keys = (k for k of axisValues[c])
                    hasExcludedItem = false
                    valueList = $("<div>").addClass('pvtFilterBox').hide()

                    valueList.append $("<h4>").text("#{c} (#{keys.length})")
                    if keys.length > opts.menuLimit
                        valueList.append $("<p>").html(opts.localeStrings.tooMany)
                    else
                        btns = $("<p>").appendTo(valueList)
                        btns.append $("<button>", {type:"button"}).html(opts.localeStrings.selectAll).bind "click", ->
                            valueList.find("input:visible").prop "checked", true
                        btns.append $("<button>", {type:"button"}).html(opts.localeStrings.selectNone).bind "click", ->
                            valueList.find("input:visible").prop "checked", false
                        btns.append $("<br>")
                        btns.append $("<input>", {type: "text", placeholder: opts.localeStrings.filterResults, class: "pvtSearch"}).bind "keyup", ->
                            filter = $(this).val().toLowerCase()
                            valueList.find('.pvtCheckContainer p').each ->
                                testString = $(this).text().toLowerCase().indexOf(filter)
                                if testString isnt -1
                                    $(this).show()
                                else
                                    $(this).hide()

                        checkContainer = $("<div>").addClass("pvtCheckContainer").appendTo(valueList)

                        for k in keys.sort(getSort(opts.sorters, c))
                             v = axisValues[c][k]
                             filterItem = $("<label>")
                             filterItemExcluded = false
                             if opts.inclusions[c]
                                filterItemExcluded = (k not in opts.inclusions[c])
                             else if opts.exclusions[c]
                                filterItemExcluded = (k in opts.exclusions[c])
                             hasExcludedItem ||= filterItemExcluded
                             $("<input>")
                                .attr("type", "checkbox").addClass('pvtFilter')
                                .attr("checked", !filterItemExcluded).data("filter", [c,k])
                                .appendTo filterItem
                             filterItem.append $("<span>").text k
                             filterItem.append $("<span>").text " ("+v+")"
                             checkContainer.append $("<p>").append(filterItem)

                    updateFilter = ->
                        unselectedCount = valueList.find("[type='checkbox']").length -
                                          valueList.find("[type='checkbox']:checked").length
                        if unselectedCount > 0
                            attrElem.addClass "pvtFilteredAttribute"
                        else
                            attrElem.removeClass "pvtFilteredAttribute"
                        if keys.length > opts.menuLimit
                            valueList.toggle()
                        else
                            valueList.toggle(0, refresh)

                    $("<p>").appendTo(valueList)
                        .append $("<button>", {type:"button"}).text("OK").bind "click", updateFilter

                    showFilterList = (e) ->
                        {left: clickLeft, top: clickTop, } = $(e.currentTarget).position()
                        valueList.css(left: clickLeft+10, top: clickTop+10).toggle()
                        valueList.find('.pvtSearch').val('')
                        valueList.find('.pvtCheckContainer p').show()

                    triangleLink = $("<span>").addClass('pvtTriangle').html(" &#x25BE;")
                        .bind "click", showFilterList

                    attrElem = $("<li>").addClass("axis_#{i}")
                        .append $("<span>").addClass('pvtAttr').text(c).data("attrName", c).append(triangleLink)
                    attrElem.addClass('pvtFilteredAttribute') if hasExcludedItem
                    colList.append(attrElem).append(valueList)

                    attrElem.bind "dblclick", showFilterList

            tr1 = $("<tr>").appendTo(uiTable)

            #aggregator menu and value area

            aggregator = $("<select>").addClass('pvtAggregator')
                .bind "change", -> refresh() #capture reference
            for own x of opts.aggregators
                aggregator.append $("<option>").val(x).html(x)

            $("<td>").addClass('pvtVals')
              .appendTo(tr1)
              .append(aggregator)
              .append($("<br>"))

            #column axes
            $("<td>").addClass('pvtAxisContainer pvtHorizList pvtCols').appendTo(tr1)

            tr2 = $("<tr>").appendTo(uiTable)

            #row axes
            tr2.append $("<td>").addClass('pvtAxisContainer pvtRows').attr("valign", "top")

            #the actual pivot table container
            pivotTable = $("<td>")
                .attr("valign", "top")
                .addClass('pvtRendererArea')
                .appendTo(tr2)

            #finally the renderer dropdown and unused attribs are inserted at the requested location
            if opts.unusedAttrsVertical == true or unusedAttrsVerticalAutoOverride
                uiTable.find('tr:nth-child(1)').prepend rendererControl
                uiTable.find('tr:nth-child(2)').prepend colList
            else
                uiTable.prepend $("<tr>").append(rendererControl).append(colList)

            #render the UI in its default state
            @html uiTable

            #set up the UI initial state as requested by moving elements around

            for x in opts.cols
                @find(".pvtCols").append @find(".axis_#{$.inArray(x, shownAttributes)}")
            for x in opts.rows
                @find(".pvtRows").append @find(".axis_#{$.inArray(x, shownAttributes)}")
            if opts.aggregatorName?
                @find(".pvtAggregator").val opts.aggregatorName
            if opts.rendererName?
                @find(".pvtRenderer").val opts.rendererName

            initialRender = true

            #set up for refreshing
            refreshDelayed = =>
                subopts =
                    derivedAttributes: opts.derivedAttributes
                    localeStrings: opts.localeStrings
                    rendererOptions: opts.rendererOptions
                    sorters: opts.sorters
                    cols: [], rows: []
                    dataClass: opts.dataClass

                numInputsToProcess = opts.aggregators[aggregator.val()]([])().numInputs ? 0
                vals = []
                @find(".pvtRows li span.pvtAttr").each -> subopts.rows.push $(this).data("attrName")
                @find(".pvtCols li span.pvtAttr").each -> subopts.cols.push $(this).data("attrName")
                @find(".pvtVals select.pvtAttrDropdown").each ->
                    if numInputsToProcess == 0
                        $(this).remove()
                    else
                        numInputsToProcess--
                        vals.push $(this).val() if $(this).val() != ""

                if numInputsToProcess != 0
                    pvtVals = @find(".pvtVals")
                    for x in [0...numInputsToProcess]
                        newDropdown = $("<select>")
                            .addClass('pvtAttrDropdown')
                            .append($("<option>"))
                            .bind "change", -> refresh()
                        for attr in shownAttributes
                            newDropdown.append($("<option>").val(attr).text(attr))
                        pvtVals.append(newDropdown)

                if initialRender
                    vals = opts.vals
                    i = 0
                    @find(".pvtVals select.pvtAttrDropdown").each ->
                        $(this).val vals[i]
                        i++
                    initialRender = false

                subopts.aggregatorName = aggregator.val()
                subopts.vals = vals
                subopts.aggregator = opts.aggregators[aggregator.val()](vals)
                subopts.renderer = opts.renderers[renderer.val()]

                #construct filter here
                exclusions = {}
                @find('input.pvtFilter').not(':checked').each ->
                    filter = $(this).data("filter")
                    if exclusions[filter[0]]?
                        exclusions[filter[0]].push( filter[1] )
                    else
                        exclusions[filter[0]] = [ filter[1] ]
                #include inclusions when exclusions present
                inclusions = {}
                @find('input.pvtFilter:checked').each ->
                    filter = $(this).data("filter")
                    if exclusions[filter[0]]?
                        if inclusions[filter[0]]?
                            inclusions[filter[0]].push( filter[1] )
                        else
                            inclusions[filter[0]] = [ filter[1] ]

                subopts.filter = (record) ->
                    return false if not opts.filter(record)
                    for k,excludedItems of exclusions
                        return false if ""+record[k] in excludedItems
                    return true

                pivotTable.pivot(input,subopts)
                pivotUIOptions = $.extend opts,
                    cols: subopts.cols
                    rows: subopts.rows
                    vals: vals
                    exclusions: exclusions
                    inclusions: inclusions
                    inclusionsInfo: inclusions #duplicated for backwards-compatibility
                    aggregatorName: aggregator.val()
                    rendererName: renderer.val()

                @data "pivotUIOptions", pivotUIOptions

                # if requested make sure unused columns are in alphabetical order
                if opts.autoSortUnusedAttrs
                    unusedAttrsContainer = @find("td.pvtUnused.pvtAxisContainer")
                    $(unusedAttrsContainer).children("li")
                        .sort((a, b) => naturalSort($(a).text(), $(b).text()))
                        .appendTo unusedAttrsContainer

                pivotTable.css("opacity", 1)
                opts.onRefresh(pivotUIOptions) if opts.onRefresh?

            refresh = =>
                pivotTable.css("opacity", 0.5)
                setTimeout refreshDelayed, 10

            #the very first refresh will actually display the table
            refresh()

            @find(".pvtAxisContainer").sortable
                    update: (e, ui) -> refresh() if not ui.sender?
                    connectWith: @find(".pvtAxisContainer")
                    items: 'li'
                    placeholder: 'pvtPlaceholder'
        catch e
            console.error(e.stack) if console?
            @html opts.localeStrings.uiRenderError
        return this

    ###
    Heatmap post-processing
    ###

    $.fn.heatmap = (scope = "heatmap", opts) ->
        numRows = @data "numrows"
        numCols = @data "numcols"

        # given a series of values
        # must return a function to map a given value to a CSS color
        colorScaleGenerator = opts?.heatmap?.colorScaleGenerator
        colorScaleGenerator ?= (values) ->
            min = Math.min(values...)
            max = Math.max(values...)
            return (x) ->
                nonRed = 255 - Math.round 255*(x-min)/(max-min)
                return "rgb(255,#{nonRed},#{nonRed})"

        heatmapper = (scope) =>
            forEachCell = (f) =>
                @find(scope).each ->
                    x = $(this).data("value")
                    f(x, $(this)) if x? and isFinite(x)

            values = []
            forEachCell (x) -> values.push x
            colorScale = colorScaleGenerator(values)
            forEachCell (x, elem) -> elem.css "background-color", colorScale(x)

        switch scope
            when "heatmap"    then heatmapper ".pvtVal"
            when "rowheatmap" then heatmapper ".pvtVal.row#{i}" for i in [0...numRows]
            when "colheatmap" then heatmapper ".pvtVal.col#{j}" for j in [0...numCols]

        heatmapper ".pvtTotal.rowTotal"
        heatmapper ".pvtTotal.colTotal"

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


