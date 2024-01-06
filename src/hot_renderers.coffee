callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery

callWithJQuery ($) ->
    hasProp = {}.hasOwnProperty
    colLimit = 99
    rowLimit = 99
    rowStart = 0
    colStart = 0
    colEnd = colStart + colLimit
    rowEnd = rowStart + rowLimit
    scrollDown = false
    grandTotalFlag = false
    colTotalFlag = false
    rowTotalFlag = false

    isOverlap = (arr, i, j) ->
        if j == 0
            return -1
        if arr[j][i-1] == arr[j-1][i-1] && arr[j][i] == arr[j-1][i]
            return 1
        return -1 
    

    scrollColrender = (pivotData, opts) ->
        return () ->
            scrollWidth = this.scrollWidth;
            scrollPositionX = this.scrollLeft + this.offsetWidth
            colAttrs = pivotData.colAttrs
            rowKeys = pivotData.getRowKeys()
            result = document.getElementsByClassName('pvtTable').item(0)
            createPivotChild = elementAppend(pivotData, opts)

            if !rowTotalFlag && (((scrollPositionX - scrollWidth) < 0) || (scrollPositionX - scrollWidth) == 1)
                colStart = colEnd
                colEnd = colStart + colLimit
                theadChildNodes = result.getElementsByTagName('thead').item(0).childNodes
                theadChildNodes.forEach(node, i) ->
                    for own j, colAttr of colAttrs
                        if parseInt(i) == parseInt(j)
                            createPivotChild('thead-th', rowStart, rowEnd, colStart, colEnd, parseInt(j), node)
                        
                    
                tbodyChildNodes = result.getElementsByTagName('tbody').item(0).childNodes
                tbodyChildNodes.forEach(node, i) ->
                    for j in [0..rowEnd]
                        if parseInt(i) == parseInt(j) 
                            if i >= rowKeys.length
                                createPivotChild('col-total-td', rowStart, rowEnd, colStart, colEnd, null, node)
                            else 
                                createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(j), node)
                if opts.type == 'Heatmap'
                    $(result).heatmap("heatmap", opts)

    scrollRowrender = (pivotData, opts) ->
        return () ->
            scrollHeight = $(document).height()
            scrollPositionY = $(window).height() + $(window).scrollTop()
            if (scrollHeight - scrollPositionY) / scrollHeight == 0
                rowKeys = pivotData.getRowKeys()
                result = document.getElementsByClassName('pvtTable').item(0)
                tbody = result.getElementsByTagName('tbody').item(0)
                createPivotChild = elementAppend(pivotData, opts)
                if !colTotalFlag
                    rowStart = rowEnd
                    rowEnd = rowStart + rowLimit
                    for own i, rowKey of rowKeys.slice(rowStart, rowEnd)
                        tr = document.createElement("tr")
                        createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr)
                        createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr)
                        tbody.appendChild(tr)
                    createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody)
                    if opts.type == 'Heatmap'
                        $(result).heatmap("heatmap", opts)


    keydownendEvent = (e, pivotData, opts) ->
        if e.code == 'PageDown'
            scrollRowrender(pivotData, opts)
        if e.code == 'end'
            scrollRowrender(pivotData, opts)
        if e.ecode == 'ArrowDown'
            scrollRowrender(pivotData, opts)        

    
    ###
    Scroll Event Class
    ###
    
    class ScrollEvent
        constructor: (pivotData, opts = {}) ->
            @fn = 
                rowrender: scrollRowrender(pivotData, opts)
                colrender: scrollColrender(pivotData, opts)
                keydownend: (event) ->
                    return keydownendEvent(event, pivotData, opts)

            @getKeydownendEvent = () ->
                return @fn.keydownend
            
            @getRowrenderEvent = () ->
                return @fn.rowrender
        
            @getColRenderEvent = () =>
                return @fn.colrender
        addRenderEvent: () =>
            window.addEventListener('scroll', @getRowrenderEvent())
            window.addEventListener('keydown', @getKeydownendEvent())
            document.getElementById('output').addEventListener('scroll', @getColRenderEvent())
        removeRenderEvent: () =>
            window.removeEventListener('scroll', @getRowRenderEvent())
            window.removeEventListener('keydown', @getKeydownendEvent())
            document.getElementById('output').removeEventListener('scroll', @getColRenderEvent())


    elementAppend = (pivotData, opts) ->
        colAttrs = pivotData.colAttrs
        rowAttrs = pivotData.rowAttrs
        rowKeys = pivotData.getRowKeys()
        colKeys = pivotData.getColKeys()
        getClickHandler = makeClickHandler(opts)
        return (element, rowStart, rowEnd, colStart, colEnd, i, target) ->
            fn = 
                'thead-th': () ->
                    for own j, colKey  of colKeys.slice(colStart, colEnd)
                        x = isOverlap(colKeys, parseInt(i), parseInt(j))
                        th = document.createElement("th")
                        th.className = "pvtColLabel"
                        if x == -1
                            th.textContent = colKey[i]
                            th.setAttribute('style', 'border-right:none;')
                        else
                            th.setAttribute('style', 'border-left:none;border-right:none;')
                        
                        if (parseInt(i) == colAttrs.length-1 && rowAttrs.length != 0)
                            th.setAttribute("rowspan", 2)
                        target.appendChild th

                        if (parseInt(j) == colKeys.length-1 && !rowTotalFlag)
                            if parseInt(i) == 0 && opts.table.rowTotals
                                th = document.createElement("th")
                                th.className = "pvtTotalLabel pvtRowTotalLabel"
                                th.innerHTML = opts.localeStrings.totals
                                th.setAttribute("rowspan", colAttrs.length + (if rowAttrs.length == 0 then 0 else 1))
                                target.appendChild th
                    return target
                'thead-th-total': () ->
                    # pvtAxisLabel
                    if rowAttrs.length != 0
                        tr = document.createElement("tr")
                        for own i, r of rowAttrs
                            # r = rowAttrs[i]
                            th = document.createElement("th")
                            th.className = "pvtAxisLabel"
                            th.textContent = r
                            tr.appendChild th
                        th = document.createElement("th")
                        if colAttrs.length == 0
                            # th.setAttribute("rowspan", 2)
                            th.className = "pvtTotalLabel pvtRowTotalLabel"
                            th.innerHTML = opts.localeStrings.totals
                        tr.appendChild th
                        target.appendChild tr
                    return target
                'tbody-th':  () ->
                    rowKey = rowKeys[i]
                    # tbody tr th
                    for own j, txt of rowKey
                        th = document.createElement("th")
                        th.className = "pvtRowLabel"
                        x = isOverlap(rowKeys, parseInt(j), parseInt(i))
                        if x == -1
                            th.textContent = txt
                            th.setAttribute('style', 'border-bottom:none;')
                        else
                            th.setAttribute('style', 'border-bottom:none;border-top:none;')
                        if parseInt(j) == rowAttrs.length-1 && colAttrs.length != 0
                            th.setAttribute("colspan", 2)
                        target.appendChild th
                    return target
                'tbody-td': () -> 
                    # tbody tr td
                    rowKey = rowKeys[i]
                    for own j, colKey  of colKeys.slice(colStart, colEnd)
                        colKey = colKeys[j]
                        aggregator = pivotData.getAggregator(rowKey, colKey)
                        val = aggregator.value()
                        td = document.createElement("td")
                        td.className = "pvtVal row" + i + " col" + j
                        td.textContent = aggregator.format(val)
                        td.setAttribute("data-value", val)
                        if getClickHandler?
                            td.onclick = getClickHandler(val, rowKey, colKey)
                        target.appendChild td
                    this['row-total-td']()
                    return target
                'row-total-td': () ->
                    # col Total
                    rowKey = rowKeys[i]
                    if colEnd >= colKeys.length
                        if (opts.table.rowTotals || colAttrs.length == 0)
                            rowTotalFlag = true
                            totalAggregator = pivotData.getAggregator(rowKey, [])
                            val = totalAggregator.value()
                            td = document.createElement("td")
                            td.className = "pvtTotal rowTotal"
                            td.textContent = totalAggregator.format(val)
                            td.setAttribute("data-value", val)
                            if getClickHandler?
                                td.onclick = getClickHandler(val, rowKey, [])
                            td.setAttribute("data-for", "row" + i)
                            target.appendChild td
                    return target
                'col-total-th': (tr) ->
                    tr = tr || document.createElement("tr")
                    if rowEnd > rowKeys.length && !colTotalFlag
                        if opts.table.colTotals || rowAttrs.length == 0
                            colTotalFlag = true
                            th = document.createElement("th")
                            th.className = "pvtTotalLabel pvtColTotalLabel"
                            th.innerHTML = opts.localeStrings.totals
                            th.setAttribute("colspan", rowAttrs.length + (if colAttrs.length == 0 then 0 else 1))
                            tr.appendChild th
                            this['col-total-td'](tr)
                            target.appendChild tr
                    return target
                'col-total-td': (tr) ->
                    tr = tr || target
                    if colAttrs.length == 0 
                        this['grand-total-td'](tr)
                    for j in [colStart..colEnd]
                        if hasProp.call(colKeys, j)
                            colKey = colKeys[j]
                            totalAggregator = pivotData.getAggregator([], colKey)
                            val = totalAggregator.value()
                            td = document.createElement("td")
                            td.className = "pvtTotal colTotal"
                            td.textContent = totalAggregator.format(val)
                            td.setAttribute("data-value", val)
                            if getClickHandler?
                                td.onclick = getClickHandler(val, [], colKey)
                            td.setAttribute("data-for", "col" + j)
                            tr.appendChild td
                            if colKeys.length - 1 == j
                                this['grand-total-td'](tr)
                    return tr
                'grand-total-td': (tr) ->
                    if ((opts.table.rowTotals || colAttrs.length == 0) || !grandTotalFlag)
                        grandTotalFlag = true
                        totalAggregator = pivotData.getAggregator([], [])
                        val = totalAggregator.value()
                        td = document.createElement("td")
                        td.className = "pvtGrandTotal"
                        td.textContent = totalAggregator.format(val)
                        td.setAttribute("data-value", val)
                        if getClickHandler?
                            td.onclick = getClickHandler(val, [], [])
                        tr.appendChild td
                    return tr
            return fn[element]()


    makeClickHandler = (opts) ->
        if opts.table.clickCallback
            getClickHandler = (value, rowValues, colValues) ->
                filters = {}
                for own i, attr of colAttrs
                    if colValues[i]?
                        filters[attr] = colValues[i]
                for own j , attr of rowAttrs
                    if rowValues[j]?
                        filters[attr] = rowValues[j]
                return (e) ->
                    return opts.table.clickCallback(e, value, filters, pivotData)
        return getClickHandler

    getExtendedOpts = (opts, type) ->
        defaults =
            table:
                clickCallback: null
                rowTotals: true
                colTotals: true
            localeStrings: 
                totals: "Totals"
            type: type
        return $.extend(true, {}, defaults, opts)


    pivotTableRenderer = (pivotData, opts) ->
        colAttrs = pivotData.colAttrs
        rowAttrs = pivotData.rowAttrs    
        rowKeys = pivotData.getRowKeys()
        colKeys = pivotData.getColKeys()
        rowLimit = if pivotData.getRowLimit() > 0 then pivotData.getRowLimit() else rowKeys.length
        colLimit = if pivotData.getColLimit() > 0 then pivotData.getColLimit() else colKeys.length
        rowStart = 0
        colStart = 0
        colEnd = colStart + colLimit
        rowEnd = rowStart + rowLimit
        grandTotalFlag = false
        colTotalFlag = false
        rowTotalFlag = false
        result = document.createElement("table")
        result.className = "pvtTable"
        result.setAttribute("data-numrows", colEnd)
        result.setAttribute("data-numcols", rowEnd)
        createPivotChild = elementAppend(pivotData, opts)
        scrollevent = new ScrollEvent(pivotData, opts)
        scrollevent.addRenderEvent()

        # thead
        thead = document.createElement("thead")
        for own j, c of colAttrs
            tr = document.createElement("tr")
            if (parseInt(j) == 0 && rowAttrs.length != 0)
                th = document.createElement("th")
                th.setAttribute("colspan", rowAttrs.length)
                th.setAttribute("rowspan", colAttrs.length)
                tr.appendChild(th)
            th = document.createElement("th")
            th.className = "pvtAxisLabel"
            th.textContent = c
            tr.appendChild th
            createPivotChild('thead-th', rowStart, rowEnd, colStart, colEnd, parseInt(j), tr)
            thead.appendChild tr

        createPivotChild('thead-th-total', rowStart, rowEnd, colStart, colEnd, null, thead)
        result.appendChild thead

        # tbody
        tbody = document.createElement("tbody")
        for own i, rowKey of rowKeys.slice(rowStart, rowEnd)
            tr = document.createElement("tr")
            createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr)
            createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr)
            tbody.appendChild tr
        createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody)
        result.appendChild tbody

        return result

    $.pivotUtilities.hot_renderes =
        renderer:
            'Table': (data, opts) ->
                extendedOpts = getExtendedOpts(opts, 'Table')
                return pivotTableRenderer(data, extendedOpts)
            'Heatmap': (data, opts) ->
                extendedOpts = getExtendedOpts(opts, 'Heatmap')
                return $(pivotTableRenderer(data, extendedOpts)).heatmap("heatmap", extendedOpts)
        removeScrollevent: () ->
            if scrollevent
                return scrollevent.removeRenderEvent()
