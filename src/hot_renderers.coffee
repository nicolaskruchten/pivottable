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
        if j === 0
            return -1
        if arr[j][i - 1] === arr[j - 1][i -1] && arr[j][i] === arr[j - 1][i]
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

            if !rowTotalFlag && (((scrollPositionX - scrollWidth) < 0) || (scrollPositionX - scrollWidth) === 1)
                colStart = colEnd
                colEnd = colStart + colLimit
                theadChildNodes = result.getElementsByTagName('thead').item(0).childNodes
                theadChildNodes.forEach(node, i) ->
                    for j in colAttrs
                        if parseInt(i) === parseInt(j)
                            createPivotChild('thead-th', rowStart, rowEnd, colStart, colEnd, parseInt(j), node)
                        
                    
                tbodyChildNodes = result.getElementsByTagName('tbody').item(0).childNodes
                tbodyChildNodes.forEach(node, i) ->
                    for j in [0..rowEnd]
                        if parseInt(i) === parseInt(j) 
                            if i >= rowKeys.length
                                createPivotChild('col-total-td', rowStart, rowEnd, colStart, colEnd, null, node)
                            else 
                                createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(j), node)
                if opts.type === 'Heatmap'
                    $(result).heatmap("heatmap", opts)

    scrollRowrender = (pivotData, opts) ->
        return () ->
            scrollHeight = $(document).height()
            scrollPositionY = $(window).height() + $(window).scrollTop()
            if (scrollHeight - scrollPositionY) / scrollHeight === 0
                rowKeys = pivotData.getRowKeys()
                result = document.getElementsByClassName('pvtTable').item(0)
                tbody = result.getElementsByTagName('tbody').item(0)
                createPivotChild = elementAppend(pivotData, opts)
                if !colTotalFlag
                    rowStart = rowEnd
                    rowEnd = rowStart + rowLimit
                    for i in [rowStart..rowEnd]
                        if hasProp.call(rowKeys, i)
                            rowKey = rowKeys[i];
                            tr = document.createElement("tr")
                            createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr)
                            createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr)
                            tbody.appendChild(tr)
                    createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody)
                    if opts.type === 'Heatmap'
                        $(result).heatmap("heatmap", opts)


    keydownendEvent = (e, pivotData, opts) ->
        if e.code === 'PageDown'
            scrollRowrender(pivotData, opts)
        if e.code === 'end'
            scrollRowrender(pivotData, opts)
        if e.ecode === 'ArrowDown'
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
        
        getKeydownendEvent: () =>
            return @fn.keydownend
        
        getRowrenderEvent: () =>
            return @fn.rowrender
        
        addRenderEvent: () =>
            window.addEventListener('scroll', @getRowRenderEvent())
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