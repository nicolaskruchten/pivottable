(function () {
    var callWithJQuery,
        bind = function (fn, me) { return function () { return fn.apply(me, arguments); }; },
        hasProp = {}.hasOwnProperty;
    callWithJQuery = function (pivotModule) {
        if (typeof exports === "object" && typeof module === "object") {
            return pivotModule(require("jquery"));
        } else if (typeof define === "function" && define.amd) {
            return define(["jquery"], pivotModule);
        } else {
            return pivotModule(jQuery);
        }
    };

    callWithJQuery(function ($) {
        var pivotTableRenderer, usFmt, usFmtDollar, aggregatorTemplates, aggregators, isOverlap, grandTotalFlag, rowTotalFlag, colTotalFlag, colStart, colEnd, colLimit, rowStart, rowEnd, rowLimit, ScrollEvent, scrollevent, scrollRowRender, scrollColRender, scrollDown;
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
        usFmt = $.pivotUtilities.numberFormat
        usFmtDollar = usFmt({ digitsAfterDecimal: 3 });
        aggregatorTemplates = {
            value: function (formatter) {
                if (formatter == null) {
                    formatter = usFmt;
                }
                return function (arg) {
                    var attr;
                    attr = arg[0];
                    return function (data, rowKey, colKey) {
                        return {
                            val: 0,
                            push: function (record) {
                                if (!isNaN(parseFloat(record[attr]))) {
                                    return this.val += parseFloat(record[attr]);
                                }
                            },
                            value: function () {
                                return this.val;
                            },
                            format: formatter,
                            numInputs: attr != null ? 0 : 1
                        };
                    };
                };
            },
        }
        aggregators = (function (tpl) {
            return {
                'Value': tpl.value(usFmtDollar)
            }
        })(aggregatorTemplates);

        isOverlap = function (i, j, arr) {
            if (j === 0) {
                return -1
            }
            if (arr[j][i - 1] === arr[j - 1][i - 1] && arr[j][i] === arr[j - 1][i]) {
                return 1;
            }
            return -1;
        }

        function scrollColRender(pivotData, opts) {
            return function () {
                var result, scrollWidth, scrollPositionX, colAttrs, rowKeys, createPivotChild;;
                scrollWidth = this.scrollWidth;
                scrollPositionX = this.scrollLeft + this.offsetWidth
                colAttrs = pivotData.colAttrs;
                rowKeys = pivotData.getRowKeys();
                result = document.getElementsByClassName('pvtTable').item(0);
                createPivotChild = elementAppend(pivotData, opts);

                if (!rowTotalFlag && (((scrollPositionX - scrollWidth) < 0) || (scrollPositionX - scrollWidth) === 1)) {
                    colStart = colEnd
                    colEnd = colStart + colLimit
                    var theadChildNodes = result.getElementsByTagName('thead').item(0).childNodes;
                    theadChildNodes.forEach(function (node, i) {
                        for (var j in colAttrs) {
                            if (parseInt(i) === parseInt(j)) {
                                createPivotChild('thead-th', rowStart, rowEnd, colStart, colEnd, parseInt(j), node);
                            }
                        }
                    });
                    var tbodyChildNodes = result.getElementsByTagName('tbody').item(0).childNodes;
                    tbodyChildNodes.forEach(function (node, i) {

                        for (var j = 0; j < rowEnd; j++) {
                            if (parseInt(i) === parseInt(j)) {
                                if (i >= rowKeys.length) {
                                    createPivotChild('col-total-td', rowStart, rowEnd, colStart, colEnd, null, node)
                                } else {
                                    createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(j), node);
                                }
                            }
                        }
                    });
                    if (opts.type === 'Heatmap') $(result).heatmap("heatmap", opts);
                }
            }
        };
        function scrollRowRender(pivotData, opts) {
            return function () {
                var scrollHeight, scrollPositionY;
                scrollHeight = $(document).height();
                scrollPositionY = $(window).height() + $(window).scrollTop();
                if ((scrollHeight - scrollPositionY) / scrollHeight === 0) {
                    var result, tbody, rowKeys, i, tr, createPivotChild;
                    rowKeys = pivotData.getRowKeys();
                    result = document.getElementsByClassName('pvtTable').item(0);
                    tbody = result.getElementsByTagName('tbody').item(0);
                    createPivotChild = elementAppend(pivotData, opts);
                    if (!colTotalFlag) {
                        rowStart = rowEnd;
                        rowEnd = rowStart + rowLimit;
                        for (i = rowStart; i < rowEnd; i++) {
                            if (!hasProp.call(rowKeys, i)) continue;
                            rowKey = rowKeys[i];
                            tr = document.createElement("tr");
                            createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
                            createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
                            tbody.appendChild(tr);
                        }
                        createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody)
                        if (opts.type === 'Heatmap') $(result).heatmap("heatmap", opts);
                    }
                }
            }
        }
        function keydownendEvent(e, pivotData, opts) {
            if (e.code === 'PageDown') {
                scrollRowRender(pivotData, opts);
            }
            if (e.code === 'end') {
                scrollRowRender(pivotData, opts);
            }
            if (e.ecode === 'ArrowDown') {
                scrollRowRender(pivotData, opts);
            }

        }
        ScrollEvent = (function () {
            function ScrollEvent(pivotData, opts) {
                this.fn = {
                    rowRender: scrollRowRender(pivotData, opts),
                    colRender: scrollColRender(pivotData, opts),
                    keydownend: function (event) {
                        return keydownendEvent(event, pivotData, opts)
                    }
                }
            }
            ScrollEvent.prototype.getKeydownendEvent = function () {
                return this.fn.keydownend
            }
            ScrollEvent.prototype.getRowRenderEvent = function () {
                return this.fn.rowRender;
            }
            ScrollEvent.prototype.getColRenderEvent = function () {
                return this.fn.colRender;
            }
            ScrollEvent.prototype.getMousewheelEvent = function () {
                return this.fn.mousewheel
            }
            ScrollEvent.prototype.addEventListener = function () {
                // window.addEventListener('mousewheel', this.getMousewheelEvent())
                window.addEventListener('scroll', this.getRowRenderEvent());
                window.addEventListener('keydown', this.getKeydownendEvent())
                document.getElementById('output').addEventListener('scroll', this.getColRenderEvent());
            }
            ScrollEvent.prototype.removeEventListener = function () {
                // window.removeEventListener('mousewheel', this.getMousewheelEvent());
                window.removeEventListener('scroll', this.getRowRenderEvent());
                window.removeEventListener('keydown', this.getKeydownendEvent())
                document.getElementById('output').removeEventListener('scroll', this.getColRenderEvent());
            }
            return ScrollEvent
        })();
        elementAppend = function (pivotData, opts) {
            var colAttrs, rowAttrs, rowKeys, colKeys, getClickHandler;
            colAttrs = pivotData.colAttrs;
            rowAttrs = pivotData.rowAttrs;
            rowKeys = pivotData.getRowKeys();
            colKeys = pivotData.getColKeys();
            getClickHandler = makeClickHandler(opts);
            return function (element, rowStart, rowEnd, colStart, colEnd, i, target) {
                var fn = {
                    'thead-th': function () {
                        var th, x, j;
                        for (j = colStart; j < colEnd; j++) {
                            if (!hasProp.call(colKeys, j)) continue;
                            x = isOverlap(parseInt(i), parseInt(j), colKeys)
                            colKey = colKeys[j];

                            th = document.createElement("th");
                            th.className = "pvtColLabel";
                            if (x === -1) {
                                th.textContent = colKey[i];
                                th.setAttribute('style', 'border-right:none;')
                            } else {
                                th.setAttribute('style', 'border-left:none;border-right:none;')
                            }
                            if (parseInt(i) === colAttrs.length - 1 && rowAttrs.length !== 0) {
                                th.setAttribute("rowspan", 2);
                            }
                            target.appendChild(th);

                            if (colEnd >= colKeys.length && parseInt(j) === colKeys.length - 1 && !rowTotalFlag) {
                                if (parseInt(i) === 0 && opts.table.rowTotals) {
                                    th = document.createElement("th");
                                    th.className = "pvtTotalLabel pvtRowTotalLabel";
                                    th.innerHTML = opts.localeStrings.totals;
                                    th.setAttribute("rowspan", colAttrs.length + (rowAttrs.length === 0 ? 0 : 1));
                                    target.appendChild(th);
                                }
                            }
                        }

                        return target
                    },
                    'thead-th-total': function () {
                        var tr, r, th;
                        // pvtAxisLabel
                        if (rowAttrs.length !== 0) {
                            tr = document.createElement("tr");
                            for (var i in rowAttrs) {
                                if (!hasProp.call(rowAttrs, i)) continue;
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
                    },
                    'tbody-th': function () {
                        var j, th, rowKey, txt, x;
                        rowKey = rowKeys[i];
                        // tbody tr th
                        for (j in rowKey) {
                            if (!hasProp.call(rowKey, j)) continue;
                            txt = rowKey[j];
                            th = document.createElement("th");
                            th.className = "pvtRowLabel";
                            x = isOverlap(parseInt(j), parseInt(i), rowKeys)
                            if (x === -1) {
                                th.textContent = txt;
                                th.setAttribute('style', 'border-bottom:none;')
                            } else {
                                th.setAttribute('style', 'border-bottom:none;border-top:none;')
                            }
                            if (parseInt(j) === rowAttrs.length - 1 && colAttrs.length !== 0) {
                                th.setAttribute("colspan", 2);
                            }
                            target.appendChild(th);
                        }
                        return target;

                    },
                    'tbody-td': function () {
                        var td, val, aggregator, val, colKey, rowKey
                        // tbody tr td
                        rowKey = rowKeys[i];

                        for (j = colStart; j < colEnd; j++) {
                            if (!hasProp.call(colKeys, j)) continue;
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
                        return target

                    },
                    'row-total-td': function () {
                        var totalAggregator, val, td, rowKey;
                        // col Total
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
                        return target
                    },
                    'col-total-th': function (tr) {
                        var tr = tr || document.createElement("tr");
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
                        return target
                    },
                    'col-total-td': function (tr) {
                        var j, val, td;
                        var tr = tr || target
                        if (colAttrs.length === 0) this['grand-total-td'](tr);
                        for (j = colStart; j < colEnd; j++) {
                            if (!hasProp.call(colKeys, j)) continue;
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
                                this['grand-total-td'](tr)
                            }
                        }
                        return tr
                    },
                    'grand-total-td': function (tr) {
                        var totalAggregator, td, val;
                        if ((opts.table.rowTotals || colAttrs.length === 0) || !grandTotalFlag) {
                            grandTotalFlag = true
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
                        return tr
                    }
                }
                return fn[element]();

            }
        }
        makeClickHandler = function (opts) {
            var getClickHandler = null;
            if (opts.table.clickCallback) {
                getClickHandler = function (value, rowValues, colValues) {
                    var attr, filters, i;
                    filters = {};
                    for (i in colAttrs) {
                        if (!hasProp.call(colAttrs, i)) continue;
                        attr = colAttrs[i];
                        if (colValues[i] != null) {
                            filters[attr] = colValues[i];
                        }
                    }
                    for (i in rowAttrs) {
                        if (!hasProp.call(rowAttrs, i)) continue;
                        attr = rowAttrs[i];
                        if (rowValues[i] != null) {
                            filters[attr] = rowValues[i];
                        }
                    }
                    return function (e) {
                        return opts.table.clickCallback(e, value, filters, pivotData);
                    };
                };
            }
            return getClickHandler
        }
        getExtendedOpts = function (opts, type) {
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
        }
        pivotTableRenderer = function (pivotData, opts) {
            var c, colAttrs, i, j, r, result, rowAttrs, rowKeys, tbody, th, thead, tr, createPivotChild;
            colLimit = 99;
            rowLimit = 99;
            rowStart = 0;
            colStart = 0;
            colEnd = colStart + colLimit;
            rowEnd = rowStart + rowLimit;
            grandTotalFlag = false;
            colTotalFlag = false;
            rowTotalFlag = false;
            colAttrs = pivotData.colAttrs;
            rowAttrs = pivotData.rowAttrs;
            rowKeys = pivotData.getRowKeys();

            result = document.createElement("table");
            result.className = "pvtTable";
            result.setAttribute("data-numrows", colEnd);
            result.setAttribute("data-numcols", rowEnd);
            createPivotChild = elementAppend(pivotData, opts);
            scrollevent = new ScrollEvent(pivotData, opts);
            scrollevent.addEventListener();

            /*
                thead
            */
            thead = document.createElement("thead");
            for (j in colAttrs) {
                tr = document.createElement("tr");
                c = colAttrs[j];
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

            /*
                tbody
            */
            tbody = document.createElement("tbody");
            for (i = rowStart; i < rowEnd; i++) {
                if (!hasProp.call(rowKeys, i)) continue;
                rowKey = rowKeys[i];
                tr = document.createElement("tr");
                createPivotChild('tbody-th', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
                createPivotChild('tbody-td', rowStart, rowEnd, colStart, colEnd, parseInt(i), tr);
                tbody.appendChild(tr);
            }
            createPivotChild('col-total-th', rowStart, rowEnd, colStart, colEnd, null, tbody)
            result.appendChild(tbody);
            return result;
        };

        $.pivotUtilities.hot_renderes = {
            renderer: {
                'Table': function (data, opts) {
                    var extendedOpts = getExtendedOpts(opts, 'Table');
                    return pivotTableRenderer(data, extendedOpts);
                },
                'Heatmap': function (data, opts) {
                    var extendedOpts = getExtendedOpts(opts, 'Heatmap');
                    return $(pivotTableRenderer(data, extendedOpts)).heatmap("heatmap", extendedOpts);
                }
            },
            removeScrollevent: function () {
                // console.log('remove scroll event');
                if (scrollevent) return scrollevent.removeEventListener();
            }
        }
    });
}).call(this);