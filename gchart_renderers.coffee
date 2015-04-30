callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->

    makeGoogleChart = (chartType, extraOptions) -> (pivotData, opts) ->
        defaults =
            localeStrings:
                vs: "vs"
                by: "by"

        opts = $.extend defaults, opts

        rowKeys = pivotData.getRowKeys()
        rowKeys.push [] if rowKeys.length == 0
        colKeys = pivotData.getColKeys()
        colKeys.push [] if colKeys.length == 0
        fullAggName = pivotData.aggregatorName+ 
                if pivotData.valAttrs.length then "(#{pivotData.valAttrs.join(", ")})" else ""
        headers = (h.join("-") for h in rowKeys)
        headers.unshift ""

        numCharsInHAxis = 0
        if chartType == "ScatterChart"
            dataArray = []
            for y, tree2 of pivotData.tree
                for x, agg of tree2
                     dataArray.push [
                        parseFloat(x),
                        parseFloat(y),
                        fullAggName+": \n"+agg.format(agg.value())
                        ]
            console.log dataArray
            dataTable = new google.visualization.DataTable()
            dataTable.addColumn 'number', pivotData.colAttrs.join("-")
            dataTable.addColumn 'number', pivotData.rowAttrs.join("-") 
            dataTable.addColumn type: "string", role: "tooltip"
            dataTable.addRows dataArray
            hAxisTitle = pivotData.colAttrs.join("-")
            vAxisTitle = pivotData.rowAttrs.join("-")
            title = ""
        else
            dataArray = [headers]
            for colKey in colKeys
                row = [colKey.join("-")]
                numCharsInHAxis += row[0].length
                for rowKey in rowKeys
                    agg = pivotData.getAggregator(rowKey, colKey)
                    if agg.value()?
                        row.push agg.value()
                    else row.push null
                dataArray.push row

            dataTable = google.visualization.arrayToDataTable(dataArray)

            title = vAxisTitle = fullAggName
            hAxisTitle = pivotData.colAttrs.join("-")
            title += " #{opts.localeStrings.vs} #{hAxisTitle}" if hAxisTitle != ""
            groupByTitle = pivotData.rowAttrs.join("-")
            title += " #{opts.localeStrings.by} #{groupByTitle}" if groupByTitle != ""

        options = 
            width: $(window).width() / 1.4
            height: $(window).height() / 1.4
            title: title
            hAxis: {title: hAxisTitle, slantedText: numCharsInHAxis > 50}
            vAxis: {title: vAxisTitle}
            tooltip: { textStyle: { fontName: 'Arial', fontSize: 12 } }

        if chartType == "ScatterChart"
            options.legend = position: "none"
            options.chartArea = {'width': '80%', 'height': '80%'}

        else if dataArray[0].length == 2 and dataArray[0][1] ==  ""
            options.legend = position: "none"

        options[k] = v for k, v of extraOptions

        result = $("<div>").css(width: "100%", height: "100%")
        wrapper = new google.visualization.ChartWrapper {dataTable, chartType, options}
        wrapper.draw(result[0])    
        result.bind "dblclick", -> 
            editor = new google.visualization.ChartEditor()
            google.visualization.events.addListener editor, 'ok', -> 
                editor.getChartWrapper().draw(result[0])
            editor.openDialog(wrapper)
        return result

    $.pivotUtilities.gchart_renderers = 
        "Line Chart": makeGoogleChart("LineChart")
        "Bar Chart": makeGoogleChart("ColumnChart")
        "Scatter Chart": makeGoogleChart("ScatterChart")
        "Stacked Bar Chart": makeGoogleChart("ColumnChart", isStacked: true)
        "Area Chart": makeGoogleChart("AreaChart", isStacked: true)
