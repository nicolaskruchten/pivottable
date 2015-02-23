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

        headers = (h.join("-") for h in rowKeys)
        headers.unshift ""

        numCharsInHAxis = 0
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
        console.log dataArray

        result = $("<div>")
        c3.generate
            title: "blah"
            bindto: result[0]
            size:
                height: ($(window).height() / 1.4),
                width: ($(window).width() / 1.4)
            axis: x: 
                type: 'category',
                categories: dataArray.pop()
            data: columns: dataArray
        return result

    $.pivotUtilities.c3_renderers = 
        "Line Chart": makeGoogleChart("LineChart")
        "Bar Chart": makeGoogleChart("ColumnChart")
        "Stacked Bar Chart": makeGoogleChart("ColumnChart", isStacked: true)
        "Area Chart": makeGoogleChart("AreaChart", isStacked: true)
