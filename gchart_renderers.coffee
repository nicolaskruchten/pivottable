$ = jQuery

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

	title = vAxisTitle = pivotData.aggregator().label
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

	if dataArray[0].length == 2 and dataArray[0][1] ==  ""
		options.legend = position: "none"

	options[k] = v for k, v of extraOptions

	dataTable = google.visualization.arrayToDataTable(dataArray)

	result = $("<div style='width: 100%; height: 100%;'>")
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
	"Stacked Bar Chart": makeGoogleChart("ColumnChart", isStacked: true)
	"Area Chart": makeGoogleChart("AreaChart", isStacked: true)


