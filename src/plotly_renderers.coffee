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
    
    makePlotlyPieChart = (traceOptions, layoutOptions, transpose) ->
      if traceOptions == null
        traceOptions = {}
      if layoutOptions == null
        layoutOptions = {}
      if transpose == null
        transpose = false
      (pivotData, opts) ->
        colKeys = undefined
        data = undefined
        datumKeys = undefined
        defaults = undefined
        fullAggName = undefined
        groupByTitle = undefined
        hAxisTitle = undefined
        layout = undefined
        result = undefined
        rowKeys = undefined
        titleText = undefined
        traceKeys = undefined
        defaults =
          localeStrings:
            vs: 'vs'
            by: 'by'
          plotly: {}
        opts = $.extend(true, {}, defaults, opts)
        rowKeys = pivotData.getRowKeys()
        colKeys = pivotData.getColKeys()
        traceKeys = if transpose then colKeys else rowKeys
        if traceKeys.length == 0
          traceKeys.push []
        datumKeys = if transpose then rowKeys else colKeys
        if datumKeys.length == 0
          datumKeys.push []
        fullAggName = pivotData.aggregatorName
        if pivotData.valAttrs.length
          fullAggName += '(' + pivotData.valAttrs.join(', ') + ')'
        rows = if traceKeys.length % 2 then Math.trunc(traceKeys.length / 2) + 1 else Math.trunc(traceKeys.length / 2)
        data = traceKeys.map((traceKey, index) ->
          datumKey = undefined
          i = undefined
          labels = undefined
          len = undefined
          trace = undefined
          val = undefined
          values = undefined
          values = []
          labels = []
          i = 0
          len = datumKeys.length
          while i < len
            datumKey = datumKeys[i]
            val = parseFloat(pivotData.getAggregator(if transpose then datumKey else traceKey, if transpose then traceKey else datumKey).value())
            values.push if isFinite(val) then val else null
            labels.push datumKey.join('-') or ' '
            i++
          trace = name: traceKey.join('-') or fullAggName
          column = index % 2
          row = Math.trunc(index / 2)
          trace.domain =
            row: row
            column: column
          trace.textinfo = 'label+percent'
          trace.insidetextfont = color: 'white'
          trace.hole = .4
          trace.labels = if transpose then values else labels
          trace.values = if transpose then labels else values
          $.extend trace, traceOptions
        )
        if transpose
          hAxisTitle = pivotData.rowAttrs.join('-')
          groupByTitle = pivotData.colAttrs.join('-')
        else
          hAxisTitle = pivotData.colAttrs.join('-')
          groupByTitle = pivotData.rowAttrs.join('-')
        titleText = fullAggName
        if hAxisTitle != ''
          titleText += ' ' + opts.localeStrings.vs + ' ' + hAxisTitle
        if groupByTitle != ''
          titleText += ' ' + opts.localeStrings.by + ' ' + groupByTitle
        layout =
          grid:
            rows: rows
            columns: if traceKeys.length <= 1 then 1 else 2
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
        result = $('<div>').appendTo($('body'))
        data = data.reverse()
        Plotly.newPlot result[0], data, $.extend(layout, layoutOptions, opts.plotly)
        result.detach()

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
            {barmode: 'relative'}, true)
        "Bar Chart": makePlotlyChart({type: 'bar'}, {barmode: 'group'})
        "Stacked Bar Chart": makePlotlyChart({type: 'bar'}, {barmode: 'relative'})
        "Line Chart": makePlotlyChart()
        "Scatter Chart": makePlotlyScatterChart()
        "Donut Chart": makePlotlyPieChart({type: 'pie'})