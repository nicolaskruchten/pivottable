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
            c3: {}

        opts = $.extend true, defaults, opts
        opts.c3.size ?= {}
        opts.c3.size.width ?= window.innerWidth / 1.4
        opts.c3.size.height ?= window.innerHeight / 1.4 - 50
        chartOpts.type ?= "line"

        rowKeys = pivotData.getRowKeys()
        rowKeys.push [] if rowKeys.length == 0
        colKeys = pivotData.getColKeys()
        colKeys.push [] if colKeys.length == 0

        headers = (h.join("-") for h in colKeys)
        rotationAngle = 0

        fullAggName = pivotData.aggregatorName 
        if pivotData.valAttrs.length
            fullAggName += "(#{pivotData.valAttrs.join(", ")})"

        if chartOpts.type == "scatter"
            dataArray = []
            hAxisTitle = pivotData.colAttrs.join("-")
            vAxisTitle = pivotData.rowAttrs.join("-")
            for y, tree2 of pivotData.tree
                for x, agg of tree2
                    datum = {}
                    datum[hAxisTitle] = parseFloat(x)
                    datum[vAxisTitle] = parseFloat(y)
                    datum["tooltip"] = agg.format(agg.value())
                    dataArray.push datum
        else
            numCharsInHAxis = 0
            for x in headers
                numCharsInHAxis += x.length
            if numCharsInHAxis > 50
                rotationAngle = 45

            columns = []
            for rowKey in rowKeys
                rowHeader = rowKey.join("-")
                row = [if rowHeader == "" then pivotData.aggregatorName else rowHeader]
                for colKey in colKeys
                    agg = pivotData.getAggregator(rowKey, colKey)
                    if agg.value()?
                        val = agg.value()
                        if $.isNumeric val
                            if val < 1
                                row.push parseFloat(val.toPrecision(3))
                            else
                                row.push parseFloat(val.toFixed(3))
                        else
                            row.push val

                    else row.push null
                columns.push row

            vAxisTitle = pivotData.aggregatorName+ 
                if pivotData.valAttrs.length then "(#{pivotData.valAttrs.join(", ")})" else ""
            hAxisTitle = pivotData.colAttrs.join("-")

        titleText = fullAggName
        titleText += " #{opts.localeStrings.vs} #{hAxisTitle}" if hAxisTitle != ""
        groupByTitle = pivotData.rowAttrs.join("-")
        titleText += " #{opts.localeStrings.by} #{groupByTitle}" if groupByTitle != ""
        title = $("<p>", {style: "text-align: center; font-weight: bold"})
        title.text(titleText)

        params = 
            axis: 
                y:
                    label: vAxisTitle
                x:
                    label: hAxisTitle
                    tick:
                        rotate: rotationAngle
                        multiline: false
            data: 
                type: chartOpts.type
            tooltip:
                grouped: false
            color: 
                pattern: [ "#3366cc", "#dc3912", "#ff9900", "#109618",
                           "#990099", "#0099c6", "#dd4477", "#66aa00",
                           "#b82e2e", "#316395", "#994499", "#22aa99",
                           "#aaaa11", "#6633cc", "#e67300", "#8b0707",
                           "#651067", "#329262", "#5574a6", "#3b3eac" ]


        $.extend params, opts.c3

        if chartOpts.type == "scatter"
            params.data.x = hAxisTitle
            params.axis.x.tick = fit: false
            params.data.json = dataArray
            params.data.keys = value: [hAxisTitle,vAxisTitle]
            params.legend = show: false 
            params.tooltip.format =  
                title: -> fullAggName
                name: -> ""
                value: (a,b,c,d) -> dataArray[d].tooltip
        else
            params.axis.x.type= 'category'
            params.axis.x.categories = headers
            params.data.columns = columns


        if chartOpts.stacked?
            params.data.groups = [x.join("-") for x in rowKeys]
        renderArea = $("<div>", style: "display:none;").appendTo $("body")
        result = $("<div>").appendTo renderArea
        params.bindto = result[0]
        c3.generate params
        result.detach()
        renderArea.remove()
        return $("<div>").append title, result

    $.pivotUtilities.c3_renderers = 
        "Line Chart": makeC3Chart()
        "Bar Chart": makeC3Chart(type: "bar")
        "Stacked Bar Chart": makeC3Chart(type: "bar", stacked: true)
        "Area Chart": makeC3Chart(type: "area", stacked: true)
        "Scatter Chart": makeC3Chart(type: "scatter")
