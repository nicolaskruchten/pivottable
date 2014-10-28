(function() {
  var $, PivotData, addSeparators, aggregatorTemplates, aggregators, dayNamesEn, derivers, formatterTemplates, locales, mthNamesEn, naturalSort, numberFormat, renderers, zeroPad,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty;

  $ = jQuery;


  /*
  Utilities
   */

  addSeparators = function(nStr, thousandsSep, decimalSep) {
    var rgx, x, x1, x2;
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? decimalSep + x[1] : '';
    rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + thousandsSep + '$2');
    }
    return x1 + x2;
  };

  numberFormat = function(opts) {
    var defaults;
    defaults = {
      digitsAfterDecimal: 2,
      scaler: 1,
      thousandsSep: ",",
      decimalSep: ".",
      prefix: "",
      suffix: "",
      showZero: false
    };
    opts = $.extend(defaults, opts);
    return function(x) {
      var result;
      if (isNaN(x) || !isFinite(x)) {
        return "";
      }
      if (x === 0 && !opts.showZero) {
        return "";
      }
      result = addSeparators((opts.scaler * x).toFixed(opts.digitsAfterDecimal), opts.thousandsSep, opts.decimalSep);
      return "" + opts.prefix + result + opts.suffix;
    };
  };

  formatterTemplates = {
    "default": function(x) {
      return x;
    },
    percentFormat: numberFormat({
      digitsAfterDecimal: 1,
      scaler: 100,
      suffix: "%"
    })
  };

  aggregatorTemplates = {
    fractionOf: function(wrapped, type, formatter) {
      if (type == null) {
        type = "total";
      }
      if (formatter == null) {
        formatter = formatterTemplates.percentFormat;
      }
      return function() {
        var x;
        x = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return function(data, rowKey, colKey) {
          return {
            selector: {
              total: [[], []],
              row: [rowKey, []],
              col: [[], colKey]
            }[type],
            inner: wrapped.apply(null, x)(data, rowKey, colKey),
            push: function(record) {
              return this.inner.push(record);
            },
            format: formatter,
            value: function() {
              return this.inner.value() / data.getAggregator.apply(data, this.selector).inner.value();
            },
            numInputs: wrapped.apply(null, x)().numInputs
          };
        };
      };
    }
  };

  aggregators = {};

  renderers = {};

  locales = {
    en: {
      aggregators: aggregators,
      renderers: renderers,
      localeStrings: {
        renderError: "An error occurred rendering the PivotTable results.",
        computeError: "An error occurred computing the PivotTable results.",
        uiRenderError: "An error occurred rendering the PivotTable UI.",
        selectAll: "Select All",
        selectNone: "Select None",
        tooMany: "(too many to list)",
        filterResults: "Filter results",
        totals: "Totals",
        vs: "vs",
        by: "by"
      }
    }
  };

  mthNamesEn = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  dayNamesEn = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  zeroPad = function(number) {
    return ("0" + number).substr(-2, 2);
  };

  derivers = {
    bin: function(col, binWidth) {
      return function(record) {
        return record[col] - record[col] % binWidth;
      };
    },
    dateFormat: function(col, formatString, mthNames, dayNames) {
      if (mthNames == null) {
        mthNames = mthNamesEn;
      }
      if (dayNames == null) {
        dayNames = dayNamesEn;
      }
      return function(record) {
        var date;
        date = new Date(Date.parse(record[col]));
        if (isNaN(date)) {
          return "";
        }
        return formatString.replace(/%(.)/g, function(m, p) {
          switch (p) {
            case "y":
              return date.getFullYear();
            case "m":
              return zeroPad(date.getMonth() + 1);
            case "n":
              return mthNames[date.getMonth()];
            case "d":
              return zeroPad(date.getDate());
            case "w":
              return dayNames[date.getDay()];
            case "x":
              return date.getDay();
            case "H":
              return zeroPad(date.getHours());
            case "M":
              return zeroPad(date.getMinutes());
            case "S":
              return zeroPad(date.getSeconds());
            default:
              return "%" + p;
          }
        });
      };
    }
  };

  naturalSort = (function(_this) {
    return function(as, bs) {
      var a, a1, b, b1, rd, rx, rz;
      rx = /(\d+)|(\D+)/g;
      rd = /\d/;
      rz = /^0/;
      if (typeof as === "number" || typeof bs === "number") {
        if (isNaN(as)) {
          return 1;
        }
        if (isNaN(bs)) {
          return -1;
        }
        return as - bs;
      }
      a = String(as).toLowerCase();
      b = String(bs).toLowerCase();
      if (a === b) {
        return 0;
      }
      if (!(rd.test(a) && rd.test(b))) {
        return (a > b ? 1 : -1);
      }
      a = a.match(rx);
      b = b.match(rx);
      while (a.length && b.length) {
        a1 = a.shift();
        b1 = b.shift();
        if (a1 !== b1) {
          if (rd.test(a1) && rd.test(b1)) {
            return a1.replace(rz, ".0") - b1.replace(rz, ".0");
          } else {
            return (a1 > b1 ? 1 : -1);
          }
        }
      }
      return a.length - b.length;
    };
  })(this);


  /*
  Data Model class
   */

  PivotData = (function() {
    function PivotData(input, opts) {
      this.getAggregator = __bind(this.getAggregator, this);
      this.getRowKeys = __bind(this.getRowKeys, this);
      this.getColKeys = __bind(this.getColKeys, this);
      this.sortKeys = __bind(this.sortKeys, this);
      this.arrSort = __bind(this.arrSort, this);
      this.natSort = __bind(this.natSort, this);
      this.aggregator = opts.aggregator;
      this.aggregatorName = opts.aggregatorName;
      this.colAttrs = opts.cols;
      this.rowAttrs = opts.rows;
      this.valAttrs = opts.vals;
      this.tree = {};
      this.rowKeys = [];
      this.colKeys = [];
      this.rowTotals = {};
      this.colTotals = {};
      this.allTotal = this.aggregator(this, [], []);
      this.sorted = false;
      PivotData.forEachRecord(input, opts.derivedAttributes, (function(_this) {
        return function(record) {
          if (opts.filter(record)) {
            return _this.processRecord(record);
          }
        };
      })(this));
    }

    PivotData.forEachRecord = function(input, derivedAttributes, f) {
      var addRecord, compactRecord, i, j, k, record, tblCols, _i, _len, _ref, _results, _results1;
      if ($.isEmptyObject(derivedAttributes)) {
        addRecord = f;
      } else {
        addRecord = function(record) {
          var k, v, _ref;
          for (k in derivedAttributes) {
            v = derivedAttributes[k];
            record[k] = (_ref = v(record)) != null ? _ref : record[k];
          }
          return f(record);
        };
      }
      if ($.isFunction(input)) {
        return input(addRecord);
      } else if ($.isArray(input)) {
        if ($.isArray(input[0])) {
          _results = [];
          for (i in input) {
            if (!__hasProp.call(input, i)) continue;
            compactRecord = input[i];
            if (!(i > 0)) {
              continue;
            }
            record = {};
            _ref = input[0];
            for (j in _ref) {
              if (!__hasProp.call(_ref, j)) continue;
              k = _ref[j];
              record[k] = compactRecord[j];
            }
            _results.push(addRecord(record));
          }
          return _results;
        } else {
          _results1 = [];
          for (_i = 0, _len = input.length; _i < _len; _i++) {
            record = input[_i];
            _results1.push(addRecord(record));
          }
          return _results1;
        }
      } else if (input instanceof jQuery) {
        tblCols = [];
        $("thead > tr > th", input).each(function(i) {
          return tblCols.push($(this).text());
        });
        return $("tbody > tr", input).each(function(i) {
          record = {};
          $("td", this).each(function(j) {
            return record[tblCols[j]] = $(this).text();
          });
          return addRecord(record);
        });
      } else {
        throw new Error("unknown input format");
      }
    };

    PivotData.convertToArray = function(input) {
      var result;
      result = [];
      PivotData.forEachRecord(input, {}, function(record) {
        return result.push(record);
      });
      return result;
    };

    PivotData.prototype.natSort = function(as, bs) {
      return naturalSort(as, bs);
    };

    PivotData.prototype.arrSort = function(a, b) {
      return this.natSort(a.join(), b.join());
    };

    PivotData.prototype.sortKeys = function() {
      if (!this.sorted) {
        this.rowKeys.sort(this.arrSort);
        this.colKeys.sort(this.arrSort);
      }
      return this.sorted = true;
    };

    PivotData.prototype.getColKeys = function() {
      this.sortKeys();
      return this.colKeys;
    };

    PivotData.prototype.getRowKeys = function() {
      this.sortKeys();
      return this.rowKeys;
    };

    PivotData.prototype.processRecord = function(record) {
      var colKey, flatColKey, flatRowKey, rowKey, x, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
      colKey = [];
      rowKey = [];
      _ref = this.colAttrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        colKey.push((_ref1 = record[x]) != null ? _ref1 : "null");
      }
      _ref2 = this.rowAttrs;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        x = _ref2[_j];
        rowKey.push((_ref3 = record[x]) != null ? _ref3 : "null");
      }
      flatRowKey = rowKey.join(String.fromCharCode(0));
      flatColKey = colKey.join(String.fromCharCode(0));
      this.allTotal.push(record);
      if (rowKey.length !== 0) {
        if (!this.rowTotals[flatRowKey]) {
          this.rowKeys.push(rowKey);
          this.rowTotals[flatRowKey] = this.aggregator(this, rowKey, []);
        }
        this.rowTotals[flatRowKey].push(record);
      }
      if (colKey.length !== 0) {
        if (!this.colTotals[flatColKey]) {
          this.colKeys.push(colKey);
          this.colTotals[flatColKey] = this.aggregator(this, [], colKey);
        }
        this.colTotals[flatColKey].push(record);
      }
      if (colKey.length !== 0 && rowKey.length !== 0) {
        if (!this.tree[flatRowKey]) {
          this.tree[flatRowKey] = {};
        }
        if (!this.tree[flatRowKey][flatColKey]) {
          this.tree[flatRowKey][flatColKey] = this.aggregator(this, rowKey, colKey);
        }
        return this.tree[flatRowKey][flatColKey].push(record);
      }
    };

    PivotData.prototype.getAggregator = function(rowKey, colKey) {
      var agg, flatColKey, flatRowKey;
      flatRowKey = rowKey.join(String.fromCharCode(0));
      flatColKey = colKey.join(String.fromCharCode(0));
      if (rowKey.length === 0 && colKey.length === 0) {
        agg = this.allTotal;
      } else if (rowKey.length === 0) {
        agg = this.colTotals[flatColKey];
      } else if (colKey.length === 0) {
        agg = this.rowTotals[flatRowKey];
      } else {
        agg = this.tree[flatRowKey][flatColKey];
      }
      return agg != null ? agg : {
        value: (function() {
          return null;
        }),
        format: function() {
          return "";
        }
      };
    };

    return PivotData;

  })();


  /*
  Pivot Table core: create PivotData object and call Renderer on it
   */

  $.fn.pivot = function(input, opts) {
    var defaults, e, pivotData, result, x;
    defaults = {
      cols: [],
      rows: [],
      filter: function() {
        return true;
      },
      aggregator: "",
      aggregatorName: "",
      derivedAttributes: {},
      renderer: "",
      rendererOptions: null,
      localeStrings: locales.en.localeStrings
    };
    opts = $.extend(defaults, opts);
    result = null;
    try {
      pivotData = new PivotData(input, opts);
      try {
        result = opts.renderer(pivotData, opts.rendererOptions);
      } catch (_error) {
        e = _error;
        if (typeof console !== "undefined" && console !== null) {
          console.error(e.stack);
        }
        result = $("<span>").html(opts.localeStrings.renderError);
      }
    } catch (_error) {
      e = _error;
      if (typeof console !== "undefined" && console !== null) {
        console.error(e.stack);
      }
      result = $("<span>").html(opts.localeStrings.computeError);
    }
    x = this[0];
    while (x.hasChildNodes()) {
      x.removeChild(x.lastChild);
    }
    return this.append(result);
  };

  $.pivotUtilities = {
    aggregatorTemplates: aggregatorTemplates,
    aggregators: aggregators,
    renderers: renderers,
    derivers: derivers,
    locales: locales,
    naturalSort: naturalSort,
    numberFormat: numberFormat,
    formatterTemplates: formatterTemplates,
    PivotData: PivotData
  };

}).call(this);
