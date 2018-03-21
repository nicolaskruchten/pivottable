callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery"), require("plotly.js")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery", "plotly.js"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery, Plotly

callWithJQuery ($, Plotly) ->

    makePlotlyChart = (traceOptions = {}, layoutOptions = {}, transpose = false) ->
        (pivotData, opts) ->
            defaults =
                localeStrings: {vs: "vs", by: "by"}
                plotly: {}

            opts = $.extend(true, {}, defaults, opts)

            rowKeys = pivotData.getRowKeys()
            colKeys = pivotData.getColKeys()
            traceKeys = if transpose then colKeys else rowKeys
            traceKeys.push([]) if traceKeys.length == 0
            datumKeys = if transpose then rowKeys else colKeys
            datumKeys.push([]) if datumKeys.length == 0

            fullAggName = pivotData.aggregatorName
            if pivotData.valAttrs.length
                fullAggName += "(#{pivotData.valAttrs.join(", ")})"

            data = traceKeys.map (traceKey) ->
                values = []
                labels = []
                for datumKey in datumKeys
                    val = parseFloat(pivotData.getAggregator(
                        if transpose then datumKey else traceKey,
                        if transpose then traceKey else datumKey
                    ).value())
                    values.push(if isFinite(val) then val else null)
                    labels.push(datumKey.join('-') || ' ')

                trace = {name: traceKey.join('-') || fullAggName}
                trace.x = if transpose then values else labels
                trace.y = if transpose then labels else values
                return $.extend(trace, traceOptions)

            if transpose
                hAxisTitle = pivotData.rowAttrs.join("-")
                groupByTitle = pivotData.colAttrs.join("-")
            else
                hAxisTitle = pivotData.colAttrs.join("-")
                groupByTitle = pivotData.rowAttrs.join("-")
            titleText = fullAggName
            titleText += " #{opts.localeStrings.vs} #{hAxisTitle}" if hAxisTitle != ""
            titleText += " #{opts.localeStrings.by} #{groupByTitle}" if groupByTitle != ""

            layout = {
                title: titleText
                hovermode: 'closest'
                width: window.innerWidth / 1.4
                height: window.innerHeight / 1.4 - 50
                xaxis:
                    title: if transpose then fullAggName else null
                    automargin: true
                yaxis:
                    title: if transpose then null else fullAggName
                    automargin: true
            }

            result = $("<div>").appendTo $("body")
            Plotly.newPlot(result[0], data, $.extend(layout, layoutOptions, opts.plotly))
            return result.detach()

    makePlotlyScatterChart = -> (pivotData, opts) ->
        defaults =
            localeStrings: {vs: "vs", by: "by"}
            plotly: {}

        opts = $.extend(true, {}, defaults, opts)

        rowKeys = pivotData.getRowKeys()
        rowKeys.push [] if rowKeys.length == 0
        colKeys = pivotData.getColKeys()
        colKeys.push [] if colKeys.length == 0

        data = {x: [], y: [], text: [], type: 'scatter', mode: 'markers'}

        for rowKey in rowKeys
            for colKey in colKeys
                v = pivotData.getAggregator(rowKey, colKey).value()
                if v?
                    data.x.push(colKey.join('-'))
                    data.y.push(rowKey.join('-'))
                    data.text.push(v)

        layout = {
            title: pivotData.rowAttrs.join("-") + ' vs ' + pivotData.colAttrs.join("-")
            hovermode: 'closest',
            xaxis: {title: pivotData.colAttrs.join('-'), domain: [0.1, 1.0]},
            yaxis: {title: pivotData.rowAttrs.join('-')},
            width: window.innerWidth / 1.5,
            height: window.innerHeight / 1.4 - 50
        }

        renderArea = $("<div>", style: "display:none;").appendTo $("body")
        result = $("<div>").appendTo renderArea
        Plotly.plot(result[0], [data], $.extend(layout, opts.plotly))
        result.detach()
        renderArea.remove()
        return result

    $.pivotUtilities.plotly_renderers =
        "Horizontal Bar Chart": makePlotlyChart({type: 'bar', orientation: 'h'},
            {barmode: 'group'}, true)
        "Horizontal Stacked Bar Chart": makePlotlyChart({type: 'bar', orientation: 'h'},
            {barmode: 'stack'}, true)
        "Bar Chart": makePlotlyChart({type: 'bar'}, {barmode: 'group'})
        "Stacked Bar Chart": makePlotlyChart({type: 'bar'}, {barmode: 'stack'})
        "Line Chart": makePlotlyChart()
        "Scatter Chart": makePlotlyScatterChart()
