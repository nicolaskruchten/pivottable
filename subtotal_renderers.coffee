callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->

    SubtotalRenderer = (pivotData, opts) ->
        defaults =
            localeStrings:
                totals: "Totals"

        opts = $.extend defaults, opts

        plus = "\u25B6"
        minus = "\u25E2"
        colAttrs = pivotData.colAttrs
        rowAttrs = pivotData.rowAttrs
        rowKeys = pivotData.getRowKeys()
        colKeys = pivotData.getColKeys()
        tree = pivotData.tree
        rowTotals = pivotData.rowTotals
        colTotals = pivotData.colTotals
        allTotal =pivotData.allTotal
        
        createCell = (cellType, className, textContent, attributes) ->
            th = document.createElement(cellType)
            if className then th.className = className
            if textContent isnt null and textContent isnt undefined then th.textContent = textContent
            if attributes then th.setAttribute(attr, val) for own attr, val of attributes
            return th

        processKeys = (keysArr, className) ->
            lastRow = keysArr.length - 1
            lastCol = keysArr[0].length - 1
            rMark = []
            headers = []
            th = createCell("th", className, keysArr[0][0])
            flatKey = keysArr[0][0]
            nodePos = 0
            node = {"node": nodePos, "row": 0, "col": 0, "th": th, "parent": null, "children": [], "descendants": lastCol, "leaves": 1, "flatKey": flatKey}
            headers[0] = node 
            rMark[0] = node
            c = 1
            while c <= lastCol
                th = createCell("th", className, keysArr[0][c])
                flatKey = flatKey + String.fromCharCode(0) + keysArr[0][c]
                ++nodePos
                node =  {"node": nodePos, "row": 0, "col": c, "th": th, "parent": rMark[c-1], "children": [], "descendants": lastCol-c, "leaves": 1, "flatKey": flatKey}
                rMark[c] = node
                rMark[c-1].children.push(node)
                ++c
            rMark[lastCol].leaves = 0
            r = 1
            while r <= lastRow
                repeats = true
                flatKey = ""
                c = 0
                while c <= lastCol
                    flatKey = if c is 0 then keysArr[r][c] else flatKey + String.fromCharCode(0) + keysArr[r][c]
                    if ((keysArr[r][c] is keysArr[rMark[c].row][c]) and (c isnt lastCol)  and (repeats))
                        repeats = true
                        ++c
                        continue
                    th = createCell("th", className, keysArr[r][c])
                    ++nodePos
                    header = {"node": nodePos, "row": r, "col": c, "th": th, "parent": null, "children": [], "descendants": 0, "leaves": 1, "flatKey": flatKey}
                    if c is 0
                        headers.push header
                    else
                        header.parent = rMark[c-1]
                        rMark[c-1].children.push header
                        x = 0
                        while x <= c-1
                            rMark[x].descendants = rMark[x].descendants + 1
                            ++x
                    rMark[c] = header
                    repeats = false
                    ++c
                c = 0
                while c <= lastCol
                    rMark[c].leaves = rMark[c].leaves + 1
                    ++c
                rMark[lastCol].leaves = 0
                ++r
            return headers

        buildColHeaderHeaders = (result, colHeaderRowsArr, rowAttrs) ->
            tr = document.createElement("tr")
            if rowAttrs.length != 0
                tr.appendChild createCell("th", null, null, {"colspan": rowAttrs.length, "rowspan": colAttrs.length});
            tr.appendChild createCell("th", "pvtAxisLabel", colAttrs[0])
            colHeaderRowsArr[0] = tr
            result.appendChild(tr)
            for c in [1..colAttrs.length] when c < colAttrs.length
                tr = document.createElement("tr")
                th = createCell("th", "pvtAxisLabel", colAttrs[c])
                tr.appendChild th
                colHeaderRowsArr[c] = tr
                result.appendChild(tr)
                ++c

        buildColHeaders = (colHeaderRowsArr, colHeaderColsArr, colHeader, parent, colAttrs, rowAttrs) ->
            # DF Recurse
            for h in colHeader.children
                buildColHeaders(colHeaderRowsArr, colHeaderColsArr, h, colHeader, colAttrs, rowAttrs)
            # Process
            tr = colHeaderRowsArr[colHeader.col]
            th = colHeader.th
            if colHeader.col == colAttrs.length-1 and rowAttrs.length != 0
                th.setAttribute("rowspan", 2)
            if colHeader.children.length !=0
                th.setAttribute("colspan", colHeader.descendants)
            tr.appendChild(th)
            if colHeader.children.length !=0
                rowspan = colAttrs.length-colHeader.col + if rowAttrs.length != 0 then 1 else 0
                th = createCell("th", "pvtColLabel", '', {"rowspan": rowspan})
                tr.appendChild(th)
            colHeader.tr = tr
            colHeaderColsArr.push(colHeader)

        buildRowHeaderHeaders = (result, rowHeaderHeaders, rowAttrs, colAttrs) ->
            tr = document.createElement("tr")
            for rowAttr in rowAttrs
                th = createCell("th", "pvtAxisLabel", rowAttr)
                tr.appendChild th
            if colAttrs.length != 0
                th = createCell("th")
                tr.appendChild th
            result.appendChild tr
            rowHeaderHeaders.tr = tr

        buildRowTotalsHeader = (tr, colAttrs, rowAttrs) ->
            rowspan = 1
            if colAttrs.length != 0
                rowspan = colAttrs.length + (if rowAttrs.length ==0 then 0 else 1)
            th = createCell("th", "pvtTotalLabel", opts.localeStrings.totals, {"rowspan": rowspan})
            tr.appendChild th

        buildRowHeaders = (result, rowHeaderRowsArr, rowHeader, rowAttrs, colAttrs) ->
            tr = document.createElement("tr")
            th = rowHeader.th
            th.setAttribute("rowspan", rowHeader.descendants+1)
            if rowHeader.col == rowAttrs.length-1 and colAttrs.length != 0
                th.setAttribute("colspan", 2)
            th.setAttribute("data-node", rowHeaderRowsArr.length)
            tr.appendChild(th)
            if rowHeader.children.length != 0
                th.onclick = (event) ->
                    event = event || window.event
                    toggleRow(rowHeaderRowsArr, parseInt(event.target.getAttribute("data-node")))
                colspan = rowAttrs.length-(rowHeader.col+1) + if colAttrs.length != 0 then 1 else 0
                th = createCell("th", "pvtRowLabel", '', {"colspan": colspan})
                tr.appendChild(th)
            rowHeader.clickStatus = "expanded"
            rowHeader.th.textContent = " " + minus + " " + rowHeader.th.textContent
            rowHeader.tr = tr
            rowHeaderRowsArr.push(rowHeader)
            result.appendChild(tr)
            for h in rowHeader.children
                buildRowHeaders(result, rowHeaderRowsArr, h, rowAttrs, colAttrs)

        buildValues = (rowHeaderRowsArr, colHeaderColsArr) ->
            for rowHeader in rowHeaderRowsArr
                tr = rowHeader.tr
                flatRowKey = rowHeader.flatKey
                for colHeader in colHeaderColsArr
                    flatColKey = colHeader.flatKey
                    aggregator = tree[flatRowKey][flatColKey] ? {value: (-> null), format: -> ""}
                    val = aggregator.value()
                    style = "pvtVal"
                    style = if (colHeader.children.length != 0) then  style +  " pvtSubtotal" else style
                    style = style + " row"+rowHeader.row+" col"+colHeader.col
                    td = createCell("td", style, aggregator.format(val), {"data-value": val})
                    tr.appendChild td
                # buildRowTotal
                totalAggregator = rowTotals[flatRowKey]
                val = totalAggregator.value()
                td = createCell("td", "pvtTotal rowTotal", totalAggregator.format(val), {"data-value": val, "data-row": "row"+rowHeader.row, "data-col": "col"+rowHeader.col})
                tr.appendChild td

        buildColTotalsHeader = (rowAttrs, colAttrs) ->
            tr = document.createElement("tr")
            colspan = rowAttrs.length + (if colAttrs.length == 0 then 0 else 1)
            th = createCell("th", "pvtTotalLabel", opts.localeStrings.totals, {"colspan": colspan})
            tr.appendChild(th)
            return tr

        buildColTotals = (tr, colHeaderColsArr) ->
            for h in colHeaderColsArr
                totalAggregator = colTotals[h.flatKey]
                val = totalAggregator.value()
                td = createCell("td", "pvtTotal colTotal", totalAggregator.format(val), {"data-value": val, "data-for": "col"+h.col})
                tr.appendChild td

        buildGrandTotal = (result, tr) ->
            totalAggregator = allTotal
            val = totalAggregator.value()
            td = createCell("td", "pvtGrandTotal", totalAggregator.format(val), {"data-value": val})
            tr.appendChild td
            result.appendChild tr
       
        collapseRow = (rowHeaderRows, r) ->
            if not rowHeaderRows[r]
                return
            h = rowHeaderRows[r]
            rowspan = 0
            for i in [1..h.descendants] when h.descendants != 0
                d = rowHeaderRows[r+i]
                if d.descendants != 0
                    str = d.th.textContent
                    d.th.textContent = str.substr(0, 1) + plus + str.substr(1+minus.length);
                d.clickStatus = "collapsed"
                d.th.setAttribute("rowspan", 1)
                if d.tr.style.display isnt "none"
                    ++rowspan
                    d.tr.style.display = "none"
            p = h.parent
            while p isnt null
                p.th.setAttribute("rowspan", parseInt(p.th.getAttribute("rowspan"))-rowspan)
                p = p.parent
            if h.descendants != 0
                str = h.th.textContent
                h.th.textContent = str.substr(0, 1) + plus + str.substr(1+plus.length);
            h.clickStatus = "collapsed"
            h.th.setAttribute("rowspan", 1)
            h.tr.style.display = ""
            
        expandRow = (rowHeaderRows, r) ->
            if not rowHeaderRows[r]
                return
            rowspan = 0
            h = rowHeaderRows[r]
            for i in [1..h.descendants] when h.descendants != 0
                d = rowHeaderRows[r+i]
                if d.descendants != 0
                    str = d.th.textContent
                    d.th.textContent = str.substr(0, 1) + plus + str.substr(1+minus.length);
                d.clickStatus = "collapsed"
                d.th.setAttribute("rowspan", 1)
                if d.tr.style.display isnt "none"
                    --rowspan
                    d.tr.style.display = "none"
            for c in h.children
                if c.tr.style.display is "none"
                    ++rowspan
                    c.tr.style.display = ""
            h.th.setAttribute("rowspan", h.children.length+1)
            if h.descendants != 0
                str = h.th.textContent
                h.th.textContent = str.substr(0, 1) + minus + str.substr(1+minus.length);
            h.clickStatus = "expanded"
            h.tr.style.display = ""
            p = h.parent
            while p isnt null
                p.th.setAttribute("rowspan", (rowspan + parseInt(p.th.getAttribute("rowspan"))))
                p = p.parent

        toggleRow = (rowHeaderRows, r) ->
            if not rowHeaderRows[r]
                return
            if rowHeaderRows[r].clickStatus is "collapsed"
                expandRow(rowHeaderRows, r)
            else
                collapseRow(rowHeaderRows, r)

        collapseRowsAt = (rowHeaderRows, col) ->
            i = 0
            nRows = rowHeaderRows.length
            while i < nRows
                h = rowHeaderRows[i]
                if h.col is col
                    collapseRow(rowHeaderRows, h.node)
                    i = i + h.descendants + 1
                else
                    ++i

        main = (rowAttrs, rowKeys, colAttrs, colKeys) ->
            rowHeaders = []
            colHeaders = []
            rowHeaderHeaders = {}
            rowHeaderRows = []
            colHeaderRows = []
            colHeaderCols = []

            if rowAttrs.length != 0
                rowHeaders = processKeys(rowKeys, "pvtRowLabel")
            if colAttrs.length != 0
                sTime = Date.now()
                colHeaders = processKeys(colKeys, "pvtColLabel")
            result = document.createElement("table")
            result.className = "pvtTable"
            if colAttrs.length != 0
                buildColHeaderHeaders(result, colHeaderRows, rowAttrs)
                for h in colHeaders
                    buildColHeaders(colHeaderRows, colHeaderCols, h, null, colAttrs, rowAttrs)
            if rowAttrs.length != 0
                buildRowHeaderHeaders(result, rowHeaderHeaders, rowAttrs, colAttrs)
                if colAttrs.length == 0
                    buildRowTotalsHeader(rowHeaderHeaders.tr, colAttrs, rowAttrs)
            if colAttrs.length != 0
                sTime = Date.now()
                buildRowTotalsHeader(colHeaderRows[0], colAttrs, rowAttrs)
            if rowAttrs.length != 0
                for h in rowHeaders
                    buildRowHeaders result, rowHeaderRows, h, rowAttrs, colAttrs
            buildValues(rowHeaderRows, colHeaderCols)
            tr = buildColTotalsHeader(rowAttrs, colAttrs)
            if colAttrs.length != 0
                buildColTotals(tr, colHeaderCols)
            buildGrandTotal(result, tr)
            result.setAttribute("data-numrows", rowKeys.length)
            result.setAttribute("data-numcols", colKeys.length)
            idx = rowAttrs.indexOf(opts.collapseRowsAt)
            if idx != -1 and idx != rowAttrs.length-1
                collapseRowsAt(rowHeaderRows, idx)
            return result

        return main(rowAttrs, rowKeys, colAttrs, colKeys)
        
    $.pivotUtilities.subtotal_renderers =
        "Table With Subtotal":  (pvtData, opts) -> SubtotalRenderer(pvtData, opts)
        "Table With Subtotal Bar Chart":   (pvtData, opts) -> $(SubtotalRenderer(pvtData, opts)).barchart()
        "Table With Subtotal Heatmap":   (pvtData, opts) -> $(SubtotalRenderer(pvtData, opts)).heatmap()
        "Table With Subtotal Row Heatmap":   (pvtData, opts) -> $(SubtotalRenderer(pvtData, opts)).heatmap("rowheatmap")
        "Table With Subtotal Col Heatmap":  (pvtData, opts) -> $(SubtotalRenderer(pvtData, opts)).heatmap("colheatmap")
