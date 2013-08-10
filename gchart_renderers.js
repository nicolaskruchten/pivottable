(function() {
  var $, makeGoogleChart;
  $ = jQuery;
  makeGoogleChart = function(chartType, extraOptions) {
    return function(pivotData) {
      var chart, colKey, colKeys, data, dataArray, h, headers, k, options, result, row, rowKey, rowKeys, v, _i, _j, _len, _len2;
      rowKeys = pivotData.getRowKeys();
      if (rowKeys.length === 0) {
        rowKeys.push([]);
      }
      colKeys = pivotData.getColKeys();
      if (colKeys.length === 0) {
        colKeys.push([]);
      }
      headers = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = rowKeys.length; _i < _len; _i++) {
          h = rowKeys[_i];
          _results.push(h.join("-"));
        }
        return _results;
      })();
      headers.unshift("");
      dataArray = [headers];
      for (_i = 0, _len = colKeys.length; _i < _len; _i++) {
        colKey = colKeys[_i];
        row = [colKey.join("-")];
        for (_j = 0, _len2 = rowKeys.length; _j < _len2; _j++) {
          rowKey = rowKeys[_j];
          row.push(pivotData.getAggregator(rowKey, colKey).value());
        }
        dataArray.push(row);
      }
      options = {
        width: $(window).width() / 1.5,
        height: $(window).height() / 1.5
      };
      if (dataArray[0].length === 2 && dataArray[0][1] === "") {
        options.legend = {
          position: "none"
        };
      }
      for (k in extraOptions) {
        v = extraOptions[k];
        options[k] = v;
      }
      data = google.visualization.arrayToDataTable(dataArray);
      result = $("<div style='width: 100%; height: 100%;'>");
      chart = new google.visualization[chartType](result[0]);
      chart.draw(data, options);
      return result;
    };
  };
  $.pivotUtilities.gchart_renderers = {
    "Line Chart": makeGoogleChart("LineChart"),
    "Column Chart": makeGoogleChart("ColumnChart"),
    "Bar Chart": makeGoogleChart("BarChart"),
    "Area Chart": makeGoogleChart("AreaChart", {
      isStacked: true
    })
  };
}).call(this);
