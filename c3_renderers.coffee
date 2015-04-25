callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->

    makeC3Chart = (chartOpts = {}) -> (pivotData, opts) ->
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

        vAxisTitle = pivotData.aggregatorName+ 
            if pivotData.valAttrs.length then "(#{pivotData.valAttrs.join(", ")})" else ""
        hAxisTitle = pivotData.colAttrs.join("-")

        params = 
            size:
                height: ($(window).height() / 1.4),
                width: ($(window).width() / 1.4)
            axis: 
                y: 
                    label: vAxisTitle
                x: 
                    label: hAxisTitle
                    type: 'category',
                    categories: headers
            data: 
                columns: columns
        if chartOpts.type?
            params.data.type = chartOpts.type
        if chartOpts.stacked?
            params.data.groups = [x.join("-") for x in rowKeys]

        renderArea = $("<div>", style: "display:none;").appendTo $("body")
        result = $("<div>").appendTo renderArea
        params.bindto = result[0]
        c3.generate params
        result.detach()
        renderArea.remove()
        return result

    $.pivotUtilities.c3_renderers = 
        "Line Chart": makeC3Chart()
        "Bar Chart": makeC3Chart(type: "bar")
        "Stacked Bar Chart": makeC3Chart(type: "bar", stacked: true)
        "Area Chart": makeC3Chart(type: "area", stacked: true)
