(function() {
  var callWithJQuery;

  callWithJQuery = function(pivotModule) {
    if (typeof exports === "object" && typeof module === "object") {
      return pivotModule(require("jquery"));
    } else if (typeof define === "function" && define.amd) {
      return define(["jquery"], pivotModule);
    } else {
      return pivotModule(jQuery);
    }
  };

  callWithJQuery(function($) {
    var makeGoogleChart;
    makeGoogleChart = function(chartType, extraOptions) {
      return function(pivotData, opts) {
        var agg, colKey, colKeys, dataArray, dataTable, defaults, fullAggName, groupByTitle, h, hAxisTitle, headers, k, numCharsInHAxis, options, result, row, rowKey, rowKeys, title, tree2, v, vAxisTitle, wrapper, x, y, _i, _j, _len, _len1, _ref;
        defaults = {
          localeStrings: {
            vs: "vs",
            by: "by"
          }
        };
        opts = $.extend(defaults, opts);
        rowKeys = pivotData.getRowKeys();
        if (rowKeys.length === 0) {
          rowKeys.push([]);
        }
        colKeys = pivotData.getColKeys();
        if (colKeys.length === 0) {
          colKeys.push([]);
        }
        fullAggName = pivotData.aggregatorName;
        if (pivotData.valAttrs.length) {
          fullAggName += "(" + (pivotData.valAttrs.join(", ")) + ")";
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
        numCharsInHAxis = 0;
        if (chartType === "ScatterChart") {
          dataArray = [];
          _ref = pivotData.tree;
          for (y in _ref) {
            tree2 = _ref[y];
            for (x in tree2) {
              agg = tree2[x];
              dataArray.push([parseFloat(x), parseFloat(y), fullAggName + ": \n" + agg.format(agg.value())]);
            }
          }
          console.log(dataArray);
          dataTable = new google.visualization.DataTable();
          dataTable.addColumn('number', pivotData.colAttrs.join("-"));
          dataTable.addColumn('number', pivotData.rowAttrs.join("-"));
          dataTable.addColumn({
            type: "string",
            role: "tooltip"
          });
          dataTable.addRows(dataArray);
          hAxisTitle = pivotData.colAttrs.join("-");
          vAxisTitle = pivotData.rowAttrs.join("-");
          title = "";
        } else {
          dataArray = [headers];
          for (_i = 0, _len = colKeys.length; _i < _len; _i++) {
            colKey = colKeys[_i];
            row = [colKey.join("-")];
            numCharsInHAxis += row[0].length;
            for (_j = 0, _len1 = rowKeys.length; _j < _len1; _j++) {
              rowKey = rowKeys[_j];
              agg = pivotData.getAggregator(rowKey, colKey);
              if (agg.value() != null) {
                row.push(agg.value());
              } else {
                row.push(null);
              }
            }
            dataArray.push(row);
          }
          dataTable = google.visualization.arrayToDataTable(dataArray);
          title = vAxisTitle = fullAggName;
          hAxisTitle = pivotData.colAttrs.join("-");
          if (hAxisTitle !== "") {
            title += " " + opts.localeStrings.vs + " " + hAxisTitle;
          }
          groupByTitle = pivotData.rowAttrs.join("-");
          if (groupByTitle !== "") {
            title += " " + opts.localeStrings.by + " " + groupByTitle;
          }
        }
        options = {
          width: $(window).width() / 1.4,
          height: $(window).height() / 1.4,
          title: title,
          hAxis: {
            title: hAxisTitle,
            slantedText: numCharsInHAxis > 50
          },
          vAxis: {
            title: vAxisTitle
          },
          tooltip: {
            textStyle: {
              fontName: 'Arial',
              fontSize: 12
            }
          }
        };
        if (chartType === "ScatterChart") {
          options.legend = {
            position: "none"
          };
          options.chartArea = {
            'width': '80%',
            'height': '80%'
          };
        } else if (dataArray[0].length === 2 && dataArray[0][1] === "") {
          options.legend = {
            position: "none"
          };
        }
        for (k in extraOptions) {
          v = extraOptions[k];
          options[k] = v;
        }
        result = $("<div>").css({
          width: "100%",
          height: "100%"
        });
        wrapper = new google.visualization.ChartWrapper({
          dataTable: dataTable,
          chartType: chartType,
          options: options
        });
        wrapper.draw(result[0]);
        result.bind("dblclick", function() {
          var editor;
          editor = new google.visualization.ChartEditor();
          google.visualization.events.addListener(editor, 'ok', function() {
            return editor.getChartWrapper().draw(result[0]);
          });
          return editor.openDialog(wrapper);
        });
        return result;
      };
    };
    return $.pivotUtilities.gchart_renderers = {
      "Line Chart": makeGoogleChart("LineChart"),
      "Bar Chart": makeGoogleChart("ColumnChart"),
      "Stacked Bar Chart": makeGoogleChart("ColumnChart", {
        isStacked: true
      }),
      "Area Chart": makeGoogleChart("AreaChart", {
        isStacked: true
      }),
      "Scatter Chart": makeGoogleChart("ScatterChart")
    };
  });

}).call(this);

//# sourceMappingURL=gchart_renderers.js.map