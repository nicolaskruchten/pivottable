
/*
Default Renderer for hierarchical table layout
 */

(function() {
  var TableRenderer, table_renderer,
    __hasProp = {}.hasOwnProperty;

  TableRenderer = function(pivotData, opts) {
    var aggregator, c, colAttrs, colKey, colKeys, defaults, i, j, r, result, rowAttrs, rowKey, rowKeys, spanSize, td, th, totalAggregator, tr, txt, val, x;
    defaults = {
      localeStrings: {
        totals: "Totals"
      }
    };
    opts = $.extend(defaults, opts);
    colAttrs = pivotData.colAttrs;
    rowAttrs = pivotData.rowAttrs;
    rowKeys = pivotData.getRowKeys();
    colKeys = pivotData.getColKeys();
    result = document.createElement("table");
    result.className = "pvtTable";
    spanSize = function(arr, i, j) {
      var len, noDraw, stop, x, _i, _j;
      if (i !== 0) {
        noDraw = true;
        for (x = _i = 0; 0 <= j ? _i <= j : _i >= j; x = 0 <= j ? ++_i : --_i) {
          if (arr[i - 1][x] !== arr[i][x]) {
            noDraw = false;
          }
        }
        if (noDraw) {
          return -1;
        }
      }
      len = 0;
      while (i + len < arr.length) {
        stop = false;
        for (x = _j = 0; 0 <= j ? _j <= j : _j >= j; x = 0 <= j ? ++_j : --_j) {
          if (arr[i][x] !== arr[i + len][x]) {
            stop = true;
          }
        }
        if (stop) {
          break;
        }
        len++;
      }
      return len;
    };
    for (j in colAttrs) {
      if (!__hasProp.call(colAttrs, j)) continue;
      c = colAttrs[j];
      tr = document.createElement("tr");
      if (parseInt(j) === 0 && rowAttrs.length !== 0) {
        th = document.createElement("th");
        th.setAttribute("colspan", rowAttrs.length);
        th.setAttribute("rowspan", colAttrs.length);
        tr.appendChild(th);
      }
      th = document.createElement("th");
      th.className = "pvtAxisLabel";
      th.textContent = c;
      tr.appendChild(th);
      for (i in colKeys) {
        if (!__hasProp.call(colKeys, i)) continue;
        colKey = colKeys[i];
        x = spanSize(colKeys, parseInt(i), parseInt(j));
        if (x !== -1) {
          th = document.createElement("th");
          th.className = "pvtColLabel";
          th.textContent = colKey[j];
          th.setAttribute("colspan", x);
          if (parseInt(j) === colAttrs.length - 1 && rowAttrs.length !== 0) {
            th.setAttribute("rowspan", 2);
          }
          tr.appendChild(th);
        }
      }
      if (parseInt(j) === 0) {
        th = document.createElement("th");
        th.className = "pvtTotalLabel";
        th.innerHTML = opts.localeStrings.totals;
        th.setAttribute("rowspan", colAttrs.length + (rowAttrs.length === 0 ? 0 : 1));
        tr.appendChild(th);
      }
      result.appendChild(tr);
    }
    if (rowAttrs.length !== 0) {
      tr = document.createElement("tr");
      for (i in rowAttrs) {
        if (!__hasProp.call(rowAttrs, i)) continue;
        r = rowAttrs[i];
        th = document.createElement("th");
        th.className = "pvtAxisLabel";
        th.textContent = r;
        tr.appendChild(th);
      }
      th = document.createElement("th");
      if (colAttrs.length === 0) {
        th.className = "pvtTotalLabel";
        th.innerHTML = opts.localeStrings.totals;
      }
      tr.appendChild(th);
      result.appendChild(tr);
    }
    for (i in rowKeys) {
      if (!__hasProp.call(rowKeys, i)) continue;
      rowKey = rowKeys[i];
      tr = document.createElement("tr");
      for (j in rowKey) {
        if (!__hasProp.call(rowKey, j)) continue;
        txt = rowKey[j];
        x = spanSize(rowKeys, parseInt(i), parseInt(j));
        if (x !== -1) {
          th = document.createElement("th");
          th.className = "pvtRowLabel";
          th.textContent = txt;
          th.setAttribute("rowspan", x);
          if (parseInt(j) === rowAttrs.length - 1 && colAttrs.length !== 0) {
            th.setAttribute("colspan", 2);
          }
          tr.appendChild(th);
        }
      }
      for (j in colKeys) {
        if (!__hasProp.call(colKeys, j)) continue;
        colKey = colKeys[j];
        aggregator = pivotData.getAggregator(rowKey, colKey);
        val = aggregator.value();
        td = document.createElement("td");
        td.className = "pvtVal row" + i + " col" + j;
        td.innerHTML = aggregator.format(val);
        td.setAttribute("data-value", val);
        tr.appendChild(td);
      }
      totalAggregator = pivotData.getAggregator(rowKey, []);
      val = totalAggregator.value();
      td = document.createElement("td");
      td.className = "pvtTotal rowTotal";
      td.innerHTML = totalAggregator.format(val);
      td.setAttribute("data-value", val);
      td.setAttribute("data-for", "row" + i);
      tr.appendChild(td);
      result.appendChild(tr);
    }
    tr = document.createElement("tr");
    th = document.createElement("th");
    th.className = "pvtTotalLabel";
    th.innerHTML = opts.localeStrings.totals;
    th.setAttribute("colspan", rowAttrs.length + (colAttrs.length === 0 ? 0 : 1));
    tr.appendChild(th);
    for (j in colKeys) {
      if (!__hasProp.call(colKeys, j)) continue;
      colKey = colKeys[j];
      totalAggregator = pivotData.getAggregator([], colKey);
      val = totalAggregator.value();
      td = document.createElement("td");
      td.className = "pvtTotal colTotal";
      td.innerHTML = totalAggregator.format(val);
      td.setAttribute("data-value", val);
      td.setAttribute("data-for", "col" + j);
      tr.appendChild(td);
    }
    totalAggregator = pivotData.getAggregator([], []);
    val = totalAggregator.value();
    td = document.createElement("td");
    td.className = "pvtGrandTotal";
    td.innerHTML = totalAggregator.format(val);
    td.setAttribute("data-value", val);
    tr.appendChild(td);
    result.appendChild(tr);
    result.setAttribute("data-numrows", rowKeys.length);
    result.setAttribute("data-numcols", colKeys.length);
    return result;
  };


  /*
  Heatmap post-processing
   */

  $.fn.heatmap = function(scope) {
    var colorGen, heatmapper, i, j, numCols, numRows, _i, _j;
    if (scope == null) {
      scope = "heatmap";
    }
    numRows = this.data("numrows");
    numCols = this.data("numcols");
    colorGen = function(color, min, max) {
      var hexGen;
      hexGen = (function() {
        switch (color) {
          case "red":
            return function(hex) {
              return "ff" + hex + hex;
            };
          case "green":
            return function(hex) {
              return "" + hex + "ff" + hex;
            };
          case "blue":
            return function(hex) {
              return "" + hex + hex + "ff";
            };
        }
      })();
      return function(x) {
        var hex, intensity;
        intensity = 255 - Math.round(255 * (x - min) / (max - min));
        hex = intensity.toString(16).split(".")[0];
        if (hex.length === 1) {
          hex = 0 + hex;
        }
        return hexGen(hex);
      };
    };
    heatmapper = (function(_this) {
      return function(scope, color) {
        var colorFor, forEachCell, values;
        forEachCell = function(f) {
          return _this.find(scope).each(function() {
            var x;
            x = $(this).data("value");
            if ((x != null) && isFinite(x)) {
              return f(x, $(this));
            }
          });
        };
        values = [];
        forEachCell(function(x) {
          return values.push(x);
        });
        colorFor = colorGen(color, Math.min.apply(Math, values), Math.max.apply(Math, values));
        return forEachCell(function(x, elem) {
          return elem.css("background-color", "#" + colorFor(x));
        });
      };
    })(this);
    switch (scope) {
      case "heatmap":
        heatmapper(".pvtVal", "red");
        break;
      case "rowheatmap":
        for (i = _i = 0; 0 <= numRows ? _i < numRows : _i > numRows; i = 0 <= numRows ? ++_i : --_i) {
          heatmapper(".pvtVal.row" + i, "red");
        }
        break;
      case "colheatmap":
        for (j = _j = 0; 0 <= numCols ? _j < numCols : _j > numCols; j = 0 <= numCols ? ++_j : --_j) {
          heatmapper(".pvtVal.col" + j, "red");
        }
    }
    heatmapper(".pvtTotal.rowTotal", "red");
    heatmapper(".pvtTotal.colTotal", "red");
    return this;
  };


  /*
  Barchart post-processing
   */

  $.fn.barchart = function() {
    var barcharter, i, numCols, numRows, _i;
    numRows = this.data("numrows");
    numCols = this.data("numcols");
    barcharter = (function(_this) {
      return function(scope) {
        var forEachCell, max, scaler, values;
        forEachCell = function(f) {
          return _this.find(scope).each(function() {
            var x;
            x = $(this).data("value");
            if ((x != null) && isFinite(x)) {
              return f(x, $(this));
            }
          });
        };
        values = [];
        forEachCell(function(x) {
          return values.push(x);
        });
        max = Math.max.apply(Math, values);
        scaler = function(x) {
          return 100 * x / (1.4 * max);
        };
        return forEachCell(function(x, elem) {
          var text, wrapper;
          text = elem.text();
          wrapper = $("<div>").css({
            "position": "relative",
            "height": "55px"
          });
          wrapper.append($("<div>").css({
            "position": "absolute",
            "bottom": 0,
            "left": 0,
            "right": 0,
            "height": scaler(x) + "%",
            "background-color": "gray"
          }));
          wrapper.append($("<div>").text(text).css({
            "position": "relative",
            "padding-left": "5px",
            "padding-right": "5px"
          }));
          return elem.css({
            "padding": 0,
            "padding-top": "5px",
            "text-align": "center"
          }).html(wrapper);
        });
      };
    })(this);
    for (i = _i = 0; 0 <= numRows ? _i < numRows : _i > numRows; i = 0 <= numRows ? ++_i : --_i) {
      barcharter(".pvtVal.row" + i);
    }
    barcharter(".pvtTotal.colTotal");
    return this;
  };

  table_renderer = {
    "Table": function(pvtData, opts) {
      return TableRenderer(pvtData, opts);
    },
    "Table Barchart": function(pvtData, opts) {
      return $(TableRenderer(pvtData, opts)).barchart();
    },
    "Heatmap": function(pvtData, opts) {
      return $(TableRenderer(pvtData, opts)).heatmap();
    },
    "Row Heatmap": function(pvtData, opts) {
      return $(TableRenderer(pvtData, opts)).heatmap("rowheatmap");
    },
    "Col Heatmap": function(pvtData, opts) {
      return $(TableRenderer(pvtData, opts)).heatmap("colheatmap");
    }
  };

  $.extend($.pivotUtilities.renderers, table_renderer);

}).call(this);
