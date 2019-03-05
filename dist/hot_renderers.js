(function() {
  var callWithJQuery,
    hasProp1 = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
    var ScrollEvent, colEnd, colLimit, colStart, colTotalFlag, elementAppend, getExtendedOpts, grandTotalFlag, hasProp, isOverlap, keydownendEvent, makeClickHandler, pivotTableRenderer, rowEnd, rowLimit, rowStart, rowTotalFlag, scrollColrender, scrollDown, scrollRowrender;
    hasProp = {}.hasOwnProperty;
    colLimit = 99;
    rowLimit = 99;
    rowStart = 0;
    colStart = 0;
    colEnd = colStart + colLimit;
    rowEnd = rowStart + rowLimit;
    scrollDown = false;
    grandTotalFlag = false;
    colTotalFlag = false;
    rowTotalFlag = false;
    isOverlap = function(arr, i, j) {
      if (j === 0) {
        return -1;
      }
      if (arr[j][i - 1] === arr[j - 1][i - 1] && arr[j][i] === arr[j - 1][i]) {
        return 1;
      }
      return -1;
    };
    scrollColrender = function(pivotData, opts) {
      return function() {
        var colAttrs, createPivotChild, result, rowKeys, scrollPositionX, scrollWidth, tbodyChildNodes, theadChildNodes;
        scrollWidth = this.scrollWidth;
        scrollPositionX = this.scrollLeft + this.offsetWidth;
        colAttrs = pivotData.colAttrs;
        rowKeys = pivotData.getRowKeys();
        result = document.getElementsByClassName('pvtTable').item(0);
        createPivotChild = elementAppend(pivotData, opts);
        if (!rowTotalFlag && (((scrollPositionX - scrollWidth) < 0) || (scrollPositionX - scrollWidth) === 1)) {
          colStart = colEnd;
          colEnd = colStart + colLimit;
          theadChildNodes = result.getElementsByTagName('thead').item(0).childNodes;
          theadChildNodes.forEach(node, i)(function() {
            var colAttr, j, results;
            results = [];
            for (j in colAttrs) {
              if (!hasProp1.call(colAttrs, j)) continue;
              colAttr = colAttrs[j];
              if (parseInt(i) === parseInt(j)) {
                results.push(createPivotChild('thead-th', rowStart, rowEnd, colStart, colEnd, parseInt(j), node));
              } else {
                results.push(void 0);
              }
            }
            return results;
          });
          tbodyChildNodes = result.getElementsByTagName('tbody').item(0).childNodes;
          tbodyChildNodes.forEach(node, i)(function() {
            var j, k, ref, results;
            results = [];
            for (j = k = 0, ref = rowEnd; 0 <= ref ? k <= ref : k >= ref; j = 0 <= ref ? ++k : --k) {
              if (parseInt(i) === parseInt(j)) {
                if (i >= rowKeys.length) {
                  results.push(createPivotChild('col-total-td', rowStart, rowEnd, colStart, colEnd, null, node));
                } else {
                  results.push(createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(j), node));
                }
              } else {
                results.push(void 0);
              }
            }
            return results;
          });
          if (opts.type === 'Heatmap') {
            return $(result).heatmap("heatmap", opts);
          }
        }
      };
    };
    scrollRowrender = function(pivotData, opts) {
      return function() {
        var createPivotChild, i, ref, result, rowKey, rowKeys, scrollHeight, scrollPositionY, tbody, tr;
        scrollHeight = $(document).height();
        scrollPositionY = $(window).height() + $(window).scrollTop();
        if ((scrollHeight - scrollPositionY) / scrollHeight === 0) {
          rowKeys = pivotData.getRowKeys();
          result = document.getElementsByClassName('pvtTable').item(0);
          tbody = result.getElementsByTagName('tbody').item(0);
          createPivotChild = elementAppend(pivotData, opts);
          if (!colTotalFlag) {
            rowStart = rowEnd;
            rowEnd = rowStart + rowLimit;
            ref = rowKeys.slice(rowStart, rowEnd);
            for (i in ref) {
              if (!hasProp1.call(ref, i)) continue;
              rowKey = ref[i];
              tr = document.createElement("tr");
              createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
              createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
              tbody.appendChild(tr);
            }
            createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody);
            if (opts.type === 'Heatmap') {
              return $(result).heatmap("heatmap", opts);
            }
          }
        }
      };
    };
    keydownendEvent = function(e, pivotData, opts) {
      if (e.code === 'PageDown') {
        scrollRowrender(pivotData, opts);
      }
      if (e.code === 'end') {
        scrollRowrender(pivotData, opts);
      }
      if (e.ecode === 'ArrowDown') {
        return scrollRowrender(pivotData, opts);
      }
    };

    /*
    Scroll Event Class
     */
    ScrollEvent = (function() {
      function ScrollEvent(pivotData, opts) {
        if (opts == null) {
          opts = {};
        }
        this.removeRenderEvent = bind(this.removeRenderEvent, this);
        this.addRenderEvent = bind(this.addRenderEvent, this);
        this.fn = {
          rowrender: scrollRowrender(pivotData, opts),
          colrender: scrollColrender(pivotData, opts),
          keydownend: function(event) {
            return keydownendEvent(event, pivotData, opts);
          }
        };
        this.getKeydownendEvent = function() {
          return this.fn.keydownend;
        };
        this.getRowrenderEvent = function() {
          return this.fn.rowrender;
        };
        this.getColRenderEvent = (function(_this) {
          return function() {
            return _this.fn.colrender;
          };
        })(this);
      }

      ScrollEvent.prototype.addRenderEvent = function() {
        window.addEventListener('scroll', this.getRowrenderEvent());
        window.addEventListener('keydown', this.getKeydownendEvent());
        return document.getElementById('output').addEventListener('scroll', this.getColRenderEvent());
      };

      ScrollEvent.prototype.removeRenderEvent = function() {
        window.removeEventListener('scroll', this.getRowRenderEvent());
        window.removeEventListener('keydown', this.getKeydownendEvent());
        return document.getElementById('output').removeEventListener('scroll', this.getColRenderEvent());
      };

      return ScrollEvent;

    })();
    elementAppend = function(pivotData, opts) {
      var colAttrs, colKeys, getClickHandler, rowAttrs, rowKeys;
      colAttrs = pivotData.colAttrs;
      rowAttrs = pivotData.rowAttrs;
      rowKeys = pivotData.getRowKeys();
      colKeys = pivotData.getColKeys();
      getClickHandler = makeClickHandler(opts);
      return function(element, rowStart, rowEnd, colStart, colEnd, i, target) {
        var fn;
        fn = {
          'thead-th': function() {
            var colKey, j, ref, th, x;
            ref = colKeys.slice(colStart, colEnd);
            for (j in ref) {
              if (!hasProp1.call(ref, j)) continue;
              colKey = ref[j];
              x = isOverlap(colKeys, parseInt(i), parseInt(j));
              th = document.createElement("th");
              th.className = "pvtColLabel";
              if (x === -1) {
                th.textContent = colKey[i];
                th.setAttribute('style', 'border-right:none;');
              } else {
                th.setAttribute('style', 'border-left:none;border-right:none;');
              }
              if (parseInt(i) === colAttrs.length - 1 && rowAttrs.length !== 0) {
                th.setAttribute("rowspan", 2);
              }
              target.appendChild(th);
              if (parseInt(j) === colKeys.length - 1 && !rowTotalFlag) {
                if (parseInt(i) === 0 && opts.table.rowTotals) {
                  th = document.createElement("th");
                  th.className = "pvtTotalLabel pvtRowTotalLabel";
                  th.innerHTML = opts.localeStrings.totals;
                  th.setAttribute("rowspan", colAttrs.length + (rowAttrs.length === 0 ? 0 : 1));
                  target.appendChild(th);
                }
              }
            }
            return target;
          },
          'thead-th-total': function() {
            var r, th, tr;
            if (rowAttrs.length !== 0) {
              tr = document.createElement("tr");
              for (i in rowAttrs) {
                if (!hasProp1.call(rowAttrs, i)) continue;
                r = rowAttrs[i];
                th = document.createElement("th");
                th.className = "pvtAxisLabel";
                th.textContent = r;
                tr.appendChild(th);
              }
              th = document.createElement("th");
              if (colAttrs.length === 0) {
                th.className = "pvtTotalLabel pvtRowTotalLabel";
                th.innerHTML = opts.localeStrings.totals;
              }
              tr.appendChild(th);
              target.appendChild(tr);
            }
            return target;
          },
          'tbody-th': function() {
            var j, rowKey, th, txt, x;
            rowKey = rowKeys[i];
            for (j in rowKey) {
              if (!hasProp1.call(rowKey, j)) continue;
              txt = rowKey[j];
              th = document.createElement("th");
              th.className = "pvtRowLabel";
              x = isOverlap(rowKeys, parseInt(j), parseInt(i));
              if (x === -1) {
                th.textContent = txt;
                th.setAttribute('style', 'border-bottom:none;');
              } else {
                th.setAttribute('style', 'border-bottom:none;border-top:none;');
              }
              if (parseInt(j) === rowAttrs.length - 1 && colAttrs.length !== 0) {
                th.setAttribute("colspan", 2);
              }
              target.appendChild(th);
            }
            return target;
          },
          'tbody-td': function() {
            var aggregator, colKey, j, ref, rowKey, td, val;
            rowKey = rowKeys[i];
            ref = colKeys.slice(colStart, colEnd);
            for (j in ref) {
              if (!hasProp1.call(ref, j)) continue;
              colKey = ref[j];
              colKey = colKeys[j];
              aggregator = pivotData.getAggregator(rowKey, colKey);
              val = aggregator.value();
              td = document.createElement("td");
              td.className = "pvtVal row" + i + " col" + j;
              td.textContent = aggregator.format(val);
              td.setAttribute("data-value", val);
              if (getClickHandler != null) {
                td.onclick = getClickHandler(val, rowKey, colKey);
              }
              target.appendChild(td);
            }
            this['row-total-td']();
            return target;
          },
          'row-total-td': function() {
            var rowKey, td, totalAggregator, val;
            rowKey = rowKeys[i];
            if (colEnd >= colKeys.length) {
              if (opts.table.rowTotals || colAttrs.length === 0) {
                rowTotalFlag = true;
                totalAggregator = pivotData.getAggregator(rowKey, []);
                val = totalAggregator.value();
                td = document.createElement("td");
                td.className = "pvtTotal rowTotal";
                td.textContent = totalAggregator.format(val);
                td.setAttribute("data-value", val);
                if (getClickHandler != null) {
                  td.onclick = getClickHandler(val, rowKey, []);
                }
                td.setAttribute("data-for", "row" + i);
                target.appendChild(td);
              }
            }
            return target;
          },
          'col-total-th': function(tr) {
            var th;
            tr = tr || document.createElement("tr");
            if (rowEnd > rowKeys.length && !colTotalFlag) {
              if (opts.table.colTotals || rowAttrs.length === 0) {
                colTotalFlag = true;
                th = document.createElement("th");
                th.className = "pvtTotalLabel pvtColTotalLabel";
                th.innerHTML = opts.localeStrings.totals;
                th.setAttribute("colspan", rowAttrs.length + (colAttrs.length === 0 ? 0 : 1));
                tr.appendChild(th);
                this['col-total-td'](tr);
                target.appendChild(tr);
              }
            }
            return target;
          },
          'col-total-td': function(tr) {
            var colKey, j, k, ref, ref1, td, totalAggregator, val;
            tr = tr || target;
            if (colAttrs.length === 0) {
              this['grand-total-td'](tr);
            }
            for (j = k = ref = colStart, ref1 = colEnd; ref <= ref1 ? k <= ref1 : k >= ref1; j = ref <= ref1 ? ++k : --k) {
              if (hasProp.call(colKeys, j)) {
                colKey = colKeys[j];
                totalAggregator = pivotData.getAggregator([], colKey);
                val = totalAggregator.value();
                td = document.createElement("td");
                td.className = "pvtTotal colTotal";
                td.textContent = totalAggregator.format(val);
                td.setAttribute("data-value", val);
                if (getClickHandler != null) {
                  td.onclick = getClickHandler(val, [], colKey);
                }
                td.setAttribute("data-for", "col" + j);
                tr.appendChild(td);
                if (colKeys.length - 1 === j) {
                  this['grand-total-td'](tr);
                }
              }
            }
            return tr;
          },
          'grand-total-td': function(tr) {
            var td, totalAggregator, val;
            if ((opts.table.rowTotals || colAttrs.length === 0) || !grandTotalFlag) {
              grandTotalFlag = true;
              totalAggregator = pivotData.getAggregator([], []);
              val = totalAggregator.value();
              td = document.createElement("td");
              td.className = "pvtGrandTotal";
              td.textContent = totalAggregator.format(val);
              td.setAttribute("data-value", val);
              if (getClickHandler != null) {
                td.onclick = getClickHandler(val, [], []);
              }
              tr.appendChild(td);
            }
            return tr;
          }
        };
        return fn[element]();
      };
    };
    makeClickHandler = function(opts) {
      var getClickHandler;
      if (opts.table.clickCallback) {
        getClickHandler = function(value, rowValues, colValues) {
          var attr, filters, i, j;
          filters = {};
          for (i in colAttrs) {
            if (!hasProp1.call(colAttrs, i)) continue;
            attr = colAttrs[i];
            if (colValues[i] != null) {
              filters[attr] = colValues[i];
            }
          }
          for (j in rowAttrs) {
            if (!hasProp1.call(rowAttrs, j)) continue;
            attr = rowAttrs[j];
            if (rowValues[j] != null) {
              filters[attr] = rowValues[j];
            }
          }
          return function(e) {
            return opts.table.clickCallback(e, value, filters, pivotData);
          };
        };
      }
      return getClickHandler;
    };
    getExtendedOpts = function(opts, type) {
      var defaults;
      defaults = {
        table: {
          clickCallback: null,
          rowTotals: true,
          colTotals: true
        },
        localeStrings: {
          totals: "Totals"
        },
        type: type
      };
      return $.extend(true, {}, defaults, opts);
    };
    pivotTableRenderer = function(pivotData, opts) {
      var c, colAttrs, colKeys, createPivotChild, i, j, ref, result, rowAttrs, rowKey, rowKeys, scrollevent, tbody, th, thead, tr;
      colAttrs = pivotData.colAttrs;
      rowAttrs = pivotData.rowAttrs;
      rowKeys = pivotData.getRowKeys();
      colKeys = pivotData.getColKeys();
      rowLimit = pivotData.getRowLimit() > 0 ? pivotData.getRowLimit() : rowKeys.length;
      colLimit = pivotData.getColLimit() > 0 ? pivotData.getColLimit() : colKeys.length;
      rowStart = 0;
      colStart = 0;
      colEnd = colStart + colLimit;
      rowEnd = rowStart + rowLimit;
      grandTotalFlag = false;
      colTotalFlag = false;
      rowTotalFlag = false;
      result = document.createElement("table");
      result.className = "pvtTable";
      result.setAttribute("data-numrows", colEnd);
      result.setAttribute("data-numcols", rowEnd);
      createPivotChild = elementAppend(pivotData, opts);
      scrollevent = new ScrollEvent(pivotData, opts);
      scrollevent.addRenderEvent();
      thead = document.createElement("thead");
      for (j in colAttrs) {
        if (!hasProp1.call(colAttrs, j)) continue;
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
        createPivotChild('thead-th', rowStart, rowEnd, colStart, colEnd, parseInt(j), tr);
        thead.appendChild(tr);
      }
      createPivotChild('thead-th-total', rowStart, rowEnd, colStart, colEnd, null, thead);
      result.appendChild(thead);
      tbody = document.createElement("tbody");
      ref = rowKeys.slice(rowStart, rowEnd);
      for (i in ref) {
        if (!hasProp1.call(ref, i)) continue;
        rowKey = ref[i];
        tr = document.createElement("tr");
        createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
        createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
        tbody.appendChild(tr);
      }
      createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody);
      result.appendChild(tbody);
      return result;
    };
    return $.pivotUtilities.hot_renderes = {
      renderer: {
        'Table': function(data, opts) {
          var extendedOpts;
          extendedOpts = getExtendedOpts(opts, 'Table');
          return pivotTableRenderer(data, extendedOpts);
        },
        'Heatmap': function(data, opts) {
          var extendedOpts;
          extendedOpts = getExtendedOpts(opts, 'Heatmap');
          return $(pivotTableRenderer(data, extendedOpts)).heatmap("heatmap", extendedOpts);
        }
      },
      removeScrollevent: function() {
        if (scrollevent) {
          return scrollevent.removeRenderEvent();
        }
      }
    };
  });

}).call(this);

//# sourceMappingURL=hot_renderers.js.map
