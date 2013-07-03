(function() {
  var $, addCommas, aggregatorTemplates, aggregators, convertToArray, deriveAttributes, derivers, effects, forEachRow, numberFormat;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  /*
  Utilities
  */
  addCommas = function(nStr) {
    var rgx, x, x1, x2;
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  };
  numberFormat = function(sigfig, scaler) {
    if (sigfig == null) {
      sigfig = 3;
    }
    if (scaler == null) {
      scaler = 1;
    }
    return function(x) {
      if (x === 0 || isNaN(x) || !isFinite(x)) {
        return "";
      } else {
        return addCommas((scaler * x).toFixed(sigfig));
      }
    };
  };
  aggregatorTemplates = {
    sum: function(sigfig, scaler) {
      if (sigfig == null) {
        sigfig = 3;
      }
      if (scaler == null) {
        scaler = 1;
      }
      return function(_arg) {
        var field;
        field = _arg[0];
        return function() {
          return {
            sum: 0,
            push: function(row) {
              if (!isNaN(parseFloat(row[field]))) {
                return this.sum += parseFloat(row[field]);
              }
            },
            value: function() {
              return this.sum;
            },
            format: numberFormat(sigfig, scaler)
          };
        };
      };
    },
    average: function(sigfig, scaler) {
      if (sigfig == null) {
        sigfig = 3;
      }
      if (scaler == null) {
        scaler = 1;
      }
      return function(_arg) {
        var field;
        field = _arg[0];
        return function() {
          return {
            sum: 0,
            len: 0,
            push: function(row) {
              if (!isNaN(parseFloat(row[field]))) {
                this.sum += parseFloat(row[field]);
                return this.len++;
              }
            },
            value: function() {
              return this.sum / this.len;
            },
            format: numberFormat(sigfig, scaler)
          };
        };
      };
    },
    sumOverSum: function(sigfig, scaler) {
      if (sigfig == null) {
        sigfig = 3;
      }
      if (scaler == null) {
        scaler = 1;
      }
      return function(_arg) {
        var denom, num;
        num = _arg[0], denom = _arg[1];
        return function() {
          return {
            sumNum: 0,
            sumDenom: 0,
            push: function(row) {
              if (!isNaN(parseFloat(row[num]))) {
                this.sumNum += parseFloat(row[num]);
              }
              if (!isNaN(parseFloat(row[denom]))) {
                return this.sumDenom += parseFloat(row[denom]);
              }
            },
            value: function() {
              return this.sumNum / this.sumDenom;
            },
            format: numberFormat(sigfig, scaler)
          };
        };
      };
    },
    sumOverSumBound80: function(sigfig, scaler, upper) {
      if (sigfig == null) {
        sigfig = 3;
      }
      if (scaler == null) {
        scaler = 1;
      }
      if (upper == null) {
        upper = true;
      }
      return function(_arg) {
        var denom, num;
        num = _arg[0], denom = _arg[1];
        return function() {
          return {
            sumNum: 0,
            sumDenom: 0,
            push: function(row) {
              if (!isNaN(parseFloat(row[num]))) {
                this.sumNum += parseFloat(row[num]);
              }
              if (!isNaN(parseFloat(row[denom]))) {
                return this.sumDenom += parseFloat(row[denom]);
              }
            },
            value: function() {
              var sign;
              sign = upper ? 1 : -1;
              return (0.821187207574908 / this.sumDenom + this.sumNum / this.sumDenom + 1.2815515655446004 * sign * Math.sqrt(0.410593603787454 / (this.sumDenom * this.sumDenom) + (this.sumNum * (1 - this.sumNum / this.sumDenom)) / (this.sumDenom * this.sumDenom))) / (1 + 1.642374415149816 / this.sumDenom);
            },
            format: numberFormat(sigfig, scaler)
          };
        };
      };
    }
  };
  aggregators = {
    count: function() {
      return function() {
        return {
          count: 0,
          push: function() {
            return this.count++;
          },
          value: function() {
            return this.count;
          },
          format: numberFormat(0)
        };
      };
    },
    countUnique: function(_arg) {
      var field;
      field = _arg[0];
      return function() {
        return {
          uniq: [],
          push: function(row) {
            var _ref;
            if (_ref = row[field], __indexOf.call(this.uniq, _ref) < 0) {
              return this.uniq.push(row[field]);
            }
          },
          value: function() {
            return this.uniq.length;
          },
          format: numberFormat(0)
        };
      };
    },
    listUnique: function(_arg) {
      var field;
      field = _arg[0];
      return function() {
        return {
          uniq: [],
          push: function(row) {
            var _ref;
            if (_ref = row[field], __indexOf.call(this.uniq, _ref) < 0) {
              return this.uniq.push(row[field]);
            }
          },
          value: function() {
            return this.uniq.join(", ");
          },
          format: function(x) {
            return x;
          }
        };
      };
    },
    intSum: aggregatorTemplates.sum(0),
    sum: aggregatorTemplates.sum(3),
    average: aggregatorTemplates.average(3),
    sumOverSum: aggregatorTemplates.sumOverSum(3),
    ub80: aggregatorTemplates.sumOverSumBound80(3, 1, true),
    lb80: aggregatorTemplates.sumOverSumBound80(3, 1, false)
  };
  effects = {
    "Row Barchart": function(x) {
      return x.barchart();
    },
    "Heatmap": function(x) {
      return x.heatmap();
    },
    "Row Heatmap": function(x) {
      return x.heatmap("rowheatmap");
    },
    "Col Heatmap": function(x) {
      return x.heatmap("colheatmap");
    }
  };
  derivers = {
    bin: function(selector, binWidth) {
      var select;
      if ("string" === typeof selector) {
        select = function(x) {
          return x[selector];
        };
      } else {
        select = selector;
      }
      return function(row) {
        return "" + (select(row) - select(row) % binWidth);
      };
    }
  };
  $.pivotUtilities = {
    aggregatorTemplates: aggregatorTemplates,
    aggregators: aggregators,
    effects: effects,
    derivers: derivers
  };
  /*
  functions for accessing input
  */
  deriveAttributes = function(row, derivedAttributes, f) {
    var k, v, _ref, _ref2;
    for (k in derivedAttributes) {
      v = derivedAttributes[k];
      row[k] = (_ref = v(row)) != null ? _ref : row[k];
    }
    for (k in row) {
      if (!__hasProp.call(row, k)) continue;
      if ((_ref2 = row[k]) == null) {
        row[k] = "null";
      }
    }
    return f(row);
  };
  forEachRow = function(input, derivedAttributes, f) {
    var addRow, compactRow, i, j, k, row, tblCols, _i, _len, _ref, _results, _results2;
    addRow = function(row) {
      return deriveAttributes(row, derivedAttributes, f);
    };
    if (Object.prototype.toString.call(input) === '[object Function]') {
      return input(addRow);
    } else if (Array.isArray(input)) {
      if (Array.isArray(input[0])) {
        _results = [];
        for (i in input) {
          if (!__hasProp.call(input, i)) continue;
          compactRow = input[i];
          if (i > 0) {
            row = {};
            _ref = input[0];
            for (j in _ref) {
              if (!__hasProp.call(_ref, j)) continue;
              k = _ref[j];
              row[k] = compactRow[j];
            }
            _results.push(addRow(row));
          }
        }
        return _results;
      } else {
        _results2 = [];
        for (_i = 0, _len = input.length; _i < _len; _i++) {
          row = input[_i];
          _results2.push(addRow(row));
        }
        return _results2;
      }
    } else {
      tblCols = [];
      $("thead > tr > th", input).each(function(i) {
        return tblCols.push($(this).text());
      });
      return $("tbody > tr", input).each(function(i) {
        row = {};
        $("td", this).each(function(j) {
          return row[tblCols[j]] = $(this).text();
        });
        return addRow(row);
      });
    }
  };
  convertToArray = function(input) {
    var result;
    result = [];
    forEachRow(input, {}, function(row) {
      return result.push(row);
    });
    return result;
  };
  /*
  Pivot Table
  */
  $.fn.pivot = function(input, opts) {
    var aggregator, arrSort, c, cA, ca, colAs, cols, defaults, i, j, nullAggregator, r, rA, result, rowAs, rows, spanSize, strSort, th, totalAggregator, totals, tr, tree, txt, val, x, _ref, _ref2, _ref3, _ref4, _ref5;
    defaults = {
      filter: function() {
        return true;
      },
      aggregator: aggregators.count(),
      derivedAttributes: {},
      postProcessor: function() {}
    };
    opts = $.extend(defaults, opts);
    rows = [];
    rowAs = [];
    cols = [];
    colAs = [];
    tree = {};
    totals = {
      rows: {},
      cols: {},
      all: opts.aggregator()
    };
    forEachRow(input, opts.derivedAttributes, function(row) {
      var c, cA, r, rA, x;
      if (opts.filter(row)) {
        cA = (function() {
          var _i, _len, _ref, _results;
          _ref = opts.cols;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            _results.push(row[x]);
          }
          return _results;
        })();
        c = cA.join("-");
        rA = (function() {
          var _i, _len, _ref, _results;
          _ref = opts.rows;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            _results.push(row[x]);
          }
          return _results;
        })();
        r = rA.join("-");
        totals.all.push(row);
        if (r !== "") {
          if (__indexOf.call(rows, r) < 0) {
            rowAs.push(rA);
            rows.push(r);
          }
          if (!totals.rows[r]) {
            totals.rows[r] = opts.aggregator();
          }
          totals.rows[r].push(row);
        }
        if (c !== "") {
          if (__indexOf.call(cols, c) < 0) {
            colAs.push(cA);
            cols.push(c);
          }
          if (!totals.cols[c]) {
            totals.cols[c] = opts.aggregator();
          }
          totals.cols[c].push(row);
        }
        if (c !== "" && r !== "") {
          if (!(r in tree)) {
            tree[r] = {};
          }
          if (!(c in tree[r])) {
            tree[r][c] = opts.aggregator();
          }
          return tree[r][c].push(row);
        }
      }
    });
    strSort = function(a, b) {
      if (a > b) {
        return 1;
      }
      if (a < b) {
        return -1;
      }
      return 0;
    };
    arrSort = function(a, b) {
      return strSort(a.join(), b.join());
    };
    rowAs = rowAs.sort(arrSort);
    colAs = colAs.sort(arrSort);
    spanSize = function(arr, i, j) {
      var len, noDraw, stop, x;
      if (i !== 0) {
        noDraw = true;
        for (x = 0; 0 <= j ? x <= j : x >= j; 0 <= j ? x++ : x--) {
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
        for (x = 0; 0 <= j ? x <= j : x >= j; 0 <= j ? x++ : x--) {
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
    result = $("<table class='table table-bordered pvtTable'>");
    _ref = opts.cols;
    for (j in _ref) {
      if (!__hasProp.call(_ref, j)) continue;
      c = _ref[j];
      tr = $("<tr>");
      if (parseInt(j) === 0 && opts.rows.length !== 0) {
        tr.append($("<th>").attr("colspan", opts.rows.length).attr("rowspan", opts.cols.length));
      }
      tr.append($("<th class='pvtAxisLabel'>").text(c));
      for (i in colAs) {
        if (!__hasProp.call(colAs, i)) continue;
        cA = colAs[i];
        x = spanSize(colAs, parseInt(i), parseInt(j));
        if (x !== -1) {
          th = $("<th class='pvtColLabel'>").text(cA[j]).attr("colspan", x);
          if (parseInt(j) === opts.cols.length - 1 && opts.rows.length !== 0) {
            th.attr("rowspan", 2);
          }
          tr.append(th);
        }
      }
      if (parseInt(j) === 0) {
        tr.append($("<th class='pvtTotalLabel'>").text("Totals").attr("rowspan", opts.cols.length + (opts.rows.length === 0 ? 0 : 1)));
      }
      result.append(tr);
    }
    if (opts.rows.length !== 0) {
      tr = $("<tr>");
      _ref2 = opts.rows;
      for (i in _ref2) {
        if (!__hasProp.call(_ref2, i)) continue;
        r = _ref2[i];
        tr.append($("<th class='pvtAxisLabel'>").text(r));
      }
      th = $("<th>");
      if (opts.cols.length === 0) {
        th.addClass("pvtTotalLabel").text("Totals");
      }
      tr.append(th);
      result.append(tr);
    }
    nullAggregator = {
      value: function() {
        return null;
      },
      format: function() {
        return "";
      }
    };
    for (i in rowAs) {
      if (!__hasProp.call(rowAs, i)) continue;
      rA = rowAs[i];
      tr = $("<tr>");
      for (j in rA) {
        if (!__hasProp.call(rA, j)) continue;
        txt = rA[j];
        x = spanSize(rowAs, parseInt(i), parseInt(j));
        if (x !== -1) {
          th = $("<th class='pvtRowLabel'>").text(txt).attr("rowspan", x);
          if (parseInt(j) === opts.rows.length - 1 && opts.cols.length !== 0) {
            th.attr("colspan", 2);
          }
          tr.append(th);
        }
      }
      for (j in colAs) {
        if (!__hasProp.call(colAs, j)) continue;
        cA = colAs[j];
        aggregator = (_ref3 = tree[rA.join("-")][cA.join("-")]) != null ? _ref3 : nullAggregator;
        val = aggregator.value();
        tr.append($("<td class='pvtVal row" + i + " col" + j + "'>").text(aggregator.format(val)).data("value", val));
      }
      totalAggregator = (_ref4 = totals.rows[rA.join("-")]) != null ? _ref4 : nullAggregator;
      val = totalAggregator.value();
      tr.append($("<td class='pvtTotal rowTotal'>").text(totalAggregator.format(val)).data("value", val).data("for", "row" + i));
      result.append(tr);
    }
    tr = $("<tr>");
    th = $("<th class='pvtTotalLabel'>").text("Totals");
    th.attr("colspan", opts.rows.length + (opts.cols.length === 0 ? 0 : 1));
    tr.append(th);
    for (j in colAs) {
      if (!__hasProp.call(colAs, j)) continue;
      ca = colAs[j];
      totalAggregator = (_ref5 = totals.cols[ca.join("-")]) != null ? _ref5 : nullAggregator;
      val = totalAggregator.value();
      tr.append($("<td class='pvtTotal colTotal'>").text(totalAggregator.format(val)).data("value", val).data("for", "col" + j));
    }
    val = totals.all.value();
    tr.append($("<td class='pvtGrandTotal'>").text(totals.all.format(val)).data("value", val));
    result.append(tr);
    result.data("dimensions", [rowAs.length, colAs.length]);
    this.html(result);
    opts.postProcessor(result);
    return this;
  };
  /*
  UI code, calls pivot table above
  */
  $.fn.pivotUI = function(input, opts) {
    var aggregator, axisValues, c, colList, controls, defaults, effectNames, form, k, pivotTable, radio, refresh, tblCols, tr1, tr2, uiTable, x, y, _i, _j, _k, _l, _len, _len2, _len3, _len4, _len5, _len6, _m, _n, _ref, _ref2, _ref3, _ref4, _ref5;
    defaults = {
      derivedAttributes: {},
      aggregators: aggregators,
      effects: effects,
      hiddenAxes: [],
      cols: [],
      rows: [],
      vals: []
    };
    opts = $.extend(defaults, opts);
    input = convertToArray(input);
    tblCols = (function() {
      var _ref, _results;
      _ref = input[0];
      _results = [];
      for (k in _ref) {
        if (!__hasProp.call(_ref, k)) continue;
        _results.push(k);
      }
      return _results;
    })();
    _ref = opts.derivedAttributes;
    for (c in _ref) {
      if (!__hasProp.call(_ref, c)) continue;
      if ((__indexOf.call(tblCols, c) < 0)) {
        tblCols.push(c);
      }
    }
    axisValues = {};
    for (_i = 0, _len = tblCols.length; _i < _len; _i++) {
      x = tblCols[_i];
      axisValues[x] = {};
    }
    forEachRow(input, opts.derivedAttributes, function(row) {
      var k, v, _base, _ref2, _results;
      _results = [];
      for (k in row) {
        if (!__hasProp.call(row, k)) continue;
        v = row[k];
        if (v == null) {
          v = "null";
        }
        if ((_ref2 = (_base = axisValues[k])[v]) == null) {
          _base[v] = 0;
        }
        _results.push(axisValues[k][v]++);
      }
      return _results;
    });
    uiTable = $("<table class='table table-bordered' cellpadding='5'>");
    effectNames = (function() {
      var _ref2, _results;
      _ref2 = opts.effects;
      _results = [];
      for (x in _ref2) {
        if (!__hasProp.call(_ref2, x)) continue;
        y = _ref2[x];
        _results.push(x);
      }
      return _results;
    })();
    if (effectNames.length !== 0) {
      effectNames.unshift("None");
      controls = $("<td colspan='2' align='center'>");
      form = $("<form>").addClass("form-inline");
      controls.append(form);
      form.append($("<strong>").text("Effects:"));
      for (_j = 0, _len2 = effectNames.length; _j < _len2; _j++) {
        x = effectNames[_j];
        radio = $("<input type='radio' name='effects' id='effects_" + (x.replace(/\s/g, "")) + "'>").css({
          "margin-left": "15px",
          "margin-right": "5px"
        }).val(x);
        if (x === "None") {
          radio.attr("checked", "checked");
        }
        form.append(radio).append($("<label class='checkbox inline' for='effects_" + (x.replace(/\s/g, "")) + "'>").text(x));
      }
      uiTable.append($("<tr>").append(controls));
    }
    colList = $("<td colspan='2' id='unused' class='pvtAxisContainer pvtHorizList'>");
    for (_k = 0, _len3 = tblCols.length; _k < _len3; _k++) {
      c = tblCols[_k];
      if (__indexOf.call(opts.hiddenAxes, c) < 0) {
        (function(c) {
          var btns, colLabel, filterItem, k, numKeys, v, valueList, _l, _len4, _ref2;
          numKeys = Object.keys(axisValues[c]).length;
          colLabel = $("<nobr>").text(c);
          valueList = $("<div>").css({
            "z-index": 100,
            "width": "280px",
            "height": "350px",
            "overflow": "scroll",
            "border": "1px solid gray",
            "background": "white",
            "display": "none",
            "position": "absolute",
            "padding": "20px"
          });
          valueList.append($("<strong>").text("" + numKeys + " values for " + c));
          if (numKeys > 20) {
            valueList.append($("<p>").text("(too many to list)"));
          } else {
            btns = $("<p>");
            btns.append($("<button>").text("Select All").bind("click", function() {
              return valueList.find("input").attr("checked", true);
            }));
            btns.append($("<button>").text("Select None").bind("click", function() {
              return valueList.find("input").attr("checked", false);
            }));
            valueList.append(btns);
            _ref2 = Object.keys(axisValues[c]).sort();
            for (_l = 0, _len4 = _ref2.length; _l < _len4; _l++) {
              k = _ref2[_l];
              v = axisValues[c][k];
              filterItem = $("<label>");
              filterItem.append($("<input type='checkbox' class='pvtFilter'>").attr("checked", true).data("filter", [c, k]));
              filterItem.append($("<span>").text("" + k + " (" + v + ")"));
              valueList.append($("<p>").append(filterItem));
            }
          }
          colLabel.bind("dblclick", function(e) {
            valueList.css({
              left: e.pageX,
              top: e.pageY
            }).toggle();
            valueList.bind("click", function(e) {
              return e.stopPropagation();
            });
            return $(document).one("click", function() {
              refresh();
              return valueList.toggle();
            });
          });
          return colList.append($("<li class='label label-info' id='axis_" + (c.replace(/\s/g, "")) + "'>").append(colLabel).append(valueList));
        })(c);
      }
    }
    uiTable.append($("<tr>").append(colList));
    tr1 = $("<tr>");
    aggregator = $("<select id='aggregator'>").css("margin-bottom", "5px").bind("change", function() {
      return refresh();
    });
    _ref2 = opts.aggregators;
    for (x in _ref2) {
      if (!__hasProp.call(_ref2, x)) continue;
      aggregator.append($("<option>").val(x).text(x));
    }
    tr1.append($("<td id='vals' class='pvtAxisContainer pvtHorizList'>").css("text-align", "center").append(aggregator).append($("<br>")));
    tr1.append($("<td id='cols' class='pvtAxisContainer pvtHorizList'>"));
    uiTable.append(tr1);
    tr2 = $("<tr>");
    tr2.append($("<td valign='top' id='rows' class='pvtAxisContainer'>"));
    pivotTable = $("<td valign='top'>");
    tr2.append(pivotTable);
    uiTable.append(tr2);
    this.html(uiTable);
    _ref3 = opts.cols;
    for (_l = 0, _len4 = _ref3.length; _l < _len4; _l++) {
      x = _ref3[_l];
      $("#cols").append($("#axis_" + (x.replace(/\s/g, ""))));
    }
    _ref4 = opts.rows;
    for (_m = 0, _len5 = _ref4.length; _m < _len5; _m++) {
      x = _ref4[_m];
      $("#rows").append($("#axis_" + (x.replace(/\s/g, ""))));
    }
    _ref5 = opts.vals;
    for (_n = 0, _len6 = _ref5.length; _n < _len6; _n++) {
      x = _ref5[_n];
      $("#vals").append($("#axis_" + (x.replace(/\s/g, ""))));
    }
    if (opts.aggregatorName != null) {
      $("#aggregator").val(opts.aggregatorName);
    }
    if (opts.effectsName != null) {
      $("#effects_" + (opts.effectsName.replace(/\s/g, ""))).attr('checked', true);
    }
    refresh = function() {
      var effect, exclusions, subopts, vals;
      subopts = {
        derivedAttributes: opts.derivedAttributes
      };
      subopts.cols = [];
      subopts.rows = [];
      vals = [];
      $("#rows li nobr").each(function() {
        return subopts.rows.push($(this).text());
      });
      $("#cols li nobr").each(function() {
        return subopts.cols.push($(this).text());
      });
      $("#vals li nobr").each(function() {
        return vals.push($(this).text());
      });
      subopts.aggregator = opts.aggregators[aggregator.val()](vals);
      exclusions = [];
      $('input.pvtFilter').not(':checked').each(function() {
        return exclusions.push($(this).data("filter"));
      });
      subopts.filter = function(row) {
        var v, _len7, _o, _ref6;
        for (_o = 0, _len7 = exclusions.length; _o < _len7; _o++) {
          _ref6 = exclusions[_o], k = _ref6[0], v = _ref6[1];
          if (row[k] === v) {
            return false;
          }
        }
        return true;
      };
      if (effectNames.length !== 0) {
        effect = $('input[name=effects]:checked').val();
        if (effect !== "None") {
          subopts.postProcessor = opts.effects[effect];
        }
      }
      return pivotTable.pivot(input, subopts);
    };
    refresh();
    $('input[name=effects]').bind("change", refresh);
    $(".pvtAxisContainer").sortable({
      connectWith: ".pvtAxisContainer",
      items: 'li'
    }).bind("sortstop", refresh);
    return this;
  };
  /*
  Heatmap post-processing
  */
  $.fn.heatmap = function(scope) {
    var colorGen, heatmapper, i, j, numCols, numRows, _ref;
    if (scope == null) {
      scope = "heatmap";
    }
    _ref = this.data("dimensions"), numRows = _ref[0], numCols = _ref[1];
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
    heatmapper = __bind(function(scope, color) {
      var colorFor, forEachCell, values;
      forEachCell = __bind(function(f) {
        return this.find(scope).each(function() {
          var x;
          x = $(this).data("value");
          if ((x != null) && isFinite(x)) {
            return f(x, $(this));
          }
        });
      }, this);
      values = [];
      forEachCell(function(x) {
        return values.push(x);
      });
      colorFor = colorGen(color, Math.min.apply(Math, values), Math.max.apply(Math, values));
      return forEachCell(function(x, elem) {
        return elem.css("background-color", "#" + colorFor(x));
      });
    }, this);
    switch (scope) {
      case "heatmap":
        heatmapper(".pvtVal", "red");
        break;
      case "rowheatmap":
        for (i = 0; 0 <= numRows ? i < numRows : i > numRows; 0 <= numRows ? i++ : i--) {
          heatmapper(".pvtVal.row" + i, "red");
        }
        break;
      case "colheatmap":
        for (j = 0; 0 <= numCols ? j < numCols : j > numCols; 0 <= numCols ? j++ : j--) {
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
    var barcharter, i, numCols, numRows, _ref;
    _ref = this.data("dimensions"), numRows = _ref[0], numCols = _ref[1];
    barcharter = __bind(function(scope) {
      var forEachCell, max, scaler, values;
      forEachCell = __bind(function(f) {
        return this.find(scope).each(function() {
          var x;
          x = $(this).data("value");
          if ((x != null) && isFinite(x)) {
            return f(x, $(this));
          }
        });
      }, this);
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
    }, this);
    for (i = 0; 0 <= numRows ? i < numRows : i > numRows; 0 <= numRows ? i++ : i--) {
      barcharter(".pvtVal.row" + i);
    }
    barcharter(".pvtTotal.colTotal");
    return this;
  };
}).call(this);
