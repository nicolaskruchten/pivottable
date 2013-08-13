$ = jQuery

makeGoogleChart = (chartType, extraOptions) -> (pivotData) ->
	rowKeys = pivotData.getRowKeys()
	rowKeys.push [] if rowKeys.length == 0
	colKeys = pivotData.getColKeys()
	colKeys.push [] if colKeys.length == 0

	headers = (h.join("-") for h in rowKeys)
	headers.unshift ""

	dataArray = [headers]
	for colKey in colKeys
		row = [colKey.join("-")]
		for rowKey in rowKeys
			row.push pivotData.getAggregator(rowKey, colKey).value()
		dataArray.push row

	options = 
		width: $(window).width() / 1.5
		height: $(window).height() / 1.5
		hAxis: slantedText: true
	if dataArray[0].length == 2 and dataArray[0][1] ==  ""
		options.legend = position: "none"

	options[k] = v for k, v of extraOptions

	data = google.visualization.arrayToDataTable(dataArray)

	result = $("<div style='width: 100%; height: 100%;'>")
	chart = new google.visualization[chartType](result[0])
	chart.draw(data, options)
	return result

$.pivotUtilities.gchart_renderers = 
	"Line Chart": makeGoogleChart("LineChart")
	"Column Chart": makeGoogleChart("ColumnChart")
	"Bar Chart": makeGoogleChart("BarChart")
	"Area Chart": makeGoogleChart("AreaChart", isStacked: true)
