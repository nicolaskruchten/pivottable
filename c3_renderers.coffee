callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->

    makeC3Chart = (chartType) -> (pivotData, opts) ->
        defaults =
            localeStrings:
                vs: "vs"
                by: "by"

        opts = $.extend defaults, opts

        rowKeys = pivotData.getRowKeys()
        rowKeys.push [] if rowKeys.length == 0
        colKeys = pivotData.getColKeys()
        colKeys.push [] if colKeys.length == 0

        headers = (h.join("-") for h in colKeys)

        columns = []
        for rowKey in rowKeys
            rowHeader = rowKey.join("-")
            row = [if rowHeader == "" then pivotData.aggregatorName else rowHeader]
            for colKey in colKeys
                agg = pivotData.getAggregator(rowKey, colKey)
                if agg.value()?
                    row.push agg.value()
                else row.push null
            columns.push row

        result = $("<div>")
        params = 
            bindto: result[0]
            size:
                height: ($(window).height() / 1.4),
                width: ($(window).width() / 1.4)
            axis: x: 
                type: 'category',
                categories: headers
            data: 
                columns: columns
        if chartType?
            params.data.type = chartType
        c3.generate params
        return result

    $.pivotUtilities.c3_renderers = 
        "Line Chart C3": makeC3Chart()
        "Bar Chart C3": makeC3Chart("bar")
