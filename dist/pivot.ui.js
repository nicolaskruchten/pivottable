(function() {
  var $,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $ = jQuery;


  /*
  Pivot Table UI: calls Pivot Table core above with options set by user
   */

  $.fn.pivotUI = function(input, inputOpts, overwrite, locale) {
    var a, aggregator, attrLength, axisValues, c, colList, d, defaults, e, existingOpts, i, initialRender, k, opts, pivotTable, refresh, refreshDelayed, renderer, rendererControl, shownAttributes, shownValues, tblCols, tr1, tr2, uiTable, unusedAttrsVerticalAutoOverride, x, _fn, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4;
    if (overwrite == null) {
      overwrite = false;
    }
    if (locale == null) {
      locale = "en";
    }
    defaults = {
      derivedAttributes: {},
      aggregators: $.pivotUtilities.locales[locale].aggregators,
      renderers: $.pivotUtilities.locales[locale].renderers,
      attributes: [],
      values: [],
      hiddenAttributes: [],
      menuLimit: 200,
      cols: [],
      rows: [],
      vals: [],
      exclusions: {},
      unusedAttrsVertical: "auto",
      autoSortUnusedAttrs: false,
      rendererOptions: {
        localeStrings: $.pivotUtilities.locales[locale].localeStrings
      },
      onRefresh: null,
      filter: function() {
        return true;
      },
      localeStrings: $.pivotUtilities.locales[locale].localeStrings
    };
    existingOpts = this.data("pivotUIOptions");
    if ((existingOpts == null) || overwrite) {
      opts = $.extend(defaults, inputOpts);
    } else {
      opts = existingOpts;
    }
    try {
      input = $.pivotUtilities.PivotData.convertToArray(input);
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
      $.pivotUtilities.PivotData.forEachRecord(input, opts.derivedAttributes, function(record) {
        var v, _base, _results;
        _results = [];
        for (k in record) {
          if (!__hasProp.call(record, k)) continue;
          v = record[k];
          if (!(opts.filter(record))) {
            continue;
          }
          if (v == null) {
            v = "null";
          }
          if ((_base = axisValues[k])[v] == null) {
            _base[v] = 0;
          }
          _results.push(axisValues[k][v]++);
        }
        return _results;
      });
      uiTable = $("<table cellpadding='5'>");
      rendererControl = $("<td>");
      renderer = $("<select class='pvtRenderer'>").appendTo(rendererControl).bind("change", function() {
        return refresh();
      });
      _ref1 = opts.renderers;
      for (x in _ref1) {
        if (!__hasProp.call(_ref1, x)) continue;
        $("<option>").val(x).html(x).appendTo(renderer);
      }
      colList = $("<td class='pvtAxisContainer pvtUnused'>");
      if (opts.attributes.length > 0) {
        shownAttributes = (function() {
          var _j, _len1, _results;
          _results = [];
          for (_j = 0, _len1 = tblCols.length; _j < _len1; _j++) {
            c = tblCols[_j];
            if (__indexOf.call(opts.attributes, c) >= 0) {
              _results.push(c);
            }
          }
          return _results;
        })();
      } else {
        shownAttributes = (function() {
          var _j, _len1, _results;
          _results = [];
          for (_j = 0, _len1 = tblCols.length; _j < _len1; _j++) {
            c = tblCols[_j];
            if (__indexOf.call(opts.hiddenAttributes, c) < 0 && __indexOf.call(opts.values, c) < 0) {
              _results.push(c);
            }
          }
          return _results;
        })();
      }
      shownValues = opts.values.length > 0 ? (function() {
        var _j, _len1, _results;
        _results = [];
        for (_j = 0, _len1 = tblCols.length; _j < _len1; _j++) {
          d = tblCols[_j];
          if (__indexOf.call(opts.values, d) >= 0) {
            _results.push(d);
          }
        }
        return _results;
      })() : shownAttributes;
      unusedAttrsVerticalAutoOverride = false;
      if (opts.unusedAttrsVertical === "auto") {
        attrLength = 0;
        for (_j = 0, _len1 = shownAttributes.length; _j < _len1; _j++) {
          a = shownAttributes[_j];
          attrLength += a.length;
        }
        unusedAttrsVerticalAutoOverride = attrLength > 120;
      }
      if (opts.unusedAttrsVertical === true || unusedAttrsVerticalAutoOverride) {
        colList.addClass('pvtVertList');
      } else {
        colList.addClass('pvtHorizList');
      }
      _fn = function(c) {
        var attrElem, btns, checkContainer, filterItem, filterItemExcluded, hasExcludedItem, keys, showFilterList, triangleLink, updateFilter, v, valueList, _k, _len2, _ref2;
        keys = (function() {
          var _results;
          _results = [];
          for (k in axisValues[c]) {
            _results.push(k);
          }
          return _results;
        })();
        hasExcludedItem = false;
        valueList = $("<div>").addClass('pvtFilterBox').hide();
        valueList.append($("<h4>").text("" + c + " (" + keys.length + ")"));
        if (keys.length > opts.menuLimit) {
          valueList.append($("<p>").html(opts.localeStrings.tooMany));
        } else {
          btns = $("<p>").appendTo(valueList);
          btns.append($("<button>").html(opts.localeStrings.selectAll).bind("click", function() {
            return valueList.find("input").prop("checked", true);
          }));
          btns.append($("<button>").html(opts.localeStrings.selectNone).bind("click", function() {
            return valueList.find("input").prop("checked", false);
          }));
          btns.append($("<input>").addClass("pvtSearch").attr("placeholder", opts.localeStrings.filterResults).bind("keyup", function() {
            var filter;
            filter = $(this).val().toLowerCase();
            return $(this).parents(".pvtFilterBox").find('label span').each(function() {
              var testString;
              testString = this.innerText.toLowerCase().indexOf(filter);
              if (testString !== -1) {
                return $(this).parent().show();
              } else {
                return $(this).parent().hide();
              }
            });
          }));
          checkContainer = $("<div>").addClass("pvtCheckContainer").appendTo(valueList);
          _ref2 = keys.sort($.pivotUtilities.naturalSort);
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            k = _ref2[_k];
            v = axisValues[c][k];
            filterItem = $("<label>");
            filterItemExcluded = opts.exclusions[c] ? (__indexOf.call(opts.exclusions[c], k) >= 0) : false;
            hasExcludedItem || (hasExcludedItem = filterItemExcluded);
            $("<input type='checkbox' class='pvtFilter'>").attr("checked", !filterItemExcluded).data("filter", [c, k]).appendTo(filterItem);
            filterItem.append($("<span>").text("" + k + " (" + v + ")"));
            checkContainer.append($("<p>").append(filterItem));
          }
        }
        updateFilter = function() {
          var unselectedCount;
          unselectedCount = $(valueList).find("[type='checkbox']").length - $(valueList).find("[type='checkbox']:checked").length;
          if (unselectedCount > 0) {
            attrElem.addClass("pvtFilteredAttribute");
          } else {
            attrElem.removeClass("pvtFilteredAttribute");
          }
          if (keys.length > opts.menuLimit) {
            return valueList.toggle();
          } else {
            return valueList.toggle(0, refresh);
          }
        };
        $("<p>").appendTo(valueList).append($("<button>").text("OK").bind("click", updateFilter));
        showFilterList = function(e) {
          valueList.css({
            left: e.pageX,
            top: e.pageY
          }).toggle();
          $('.pvtSearch').val('');
          return $('label').show();
        };
        triangleLink = $("<span class='pvtTriangle'>").html(" &#x25BE;").bind("click", showFilterList);
        attrElem = $("<li class='axis_" + i + "'>").append($("<span class='pvtAttr'>").text(c).data("attrName", c).append(triangleLink));
        if (hasExcludedItem) {
          attrElem.addClass('pvtFilteredAttribute');
        }
        colList.append(attrElem).append(valueList);
        return attrElem.bind("dblclick", showFilterList);
      };
      for (i in shownAttributes) {
        c = shownAttributes[i];
        _fn(c);
      }
      tr1 = $("<tr>").appendTo(uiTable);
      aggregator = $("<select class='pvtAggregator'>").bind("change", function() {
        return refresh();
      });
      _ref2 = opts.aggregators;
      for (x in _ref2) {
        if (!__hasProp.call(_ref2, x)) continue;
        aggregator.append($("<option>").val(x).html(x));
      }
      $("<td class='pvtVals'>").appendTo(tr1).append(aggregator).append($("<br>"));
      $("<td class='pvtAxisContainer pvtHorizList pvtCols'>").appendTo(tr1);
      tr2 = $("<tr>").appendTo(uiTable);
      tr2.append($("<td valign='top' class='pvtAxisContainer pvtRows'>"));
      pivotTable = $("<td valign='top' class='pvtRendererArea'>").appendTo(tr2);
      if (opts.unusedAttrsVertical === true || unusedAttrsVerticalAutoOverride) {
        uiTable.find('tr:nth-child(1)').prepend(rendererControl);
        uiTable.find('tr:nth-child(2)').prepend(colList);
      } else {
        uiTable.prepend($("<tr>").append(rendererControl).append(colList));
      }
      this.html(uiTable);
      _ref3 = opts.cols;
      for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
        x = _ref3[_k];
        this.find(".pvtCols").append(this.find(".axis_" + (shownAttributes.indexOf(x))));
      }
      _ref4 = opts.rows;
      for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
        x = _ref4[_l];
        this.find(".pvtRows").append(this.find(".axis_" + (shownAttributes.indexOf(x))));
      }
      if (opts.aggregatorName != null) {
        this.find(".pvtAggregator").val(opts.aggregatorName);
      }
      if (opts.rendererName != null) {
        this.find(".pvtRenderer").val(opts.rendererName);
      }
      initialRender = true;
      refreshDelayed = (function(_this) {
        return function() {
          var attr, exclusions, natSort, newDropdown, numInputsToProcess, pivotUIOptions, pvtVals, subopts, unusedAttrsContainer, vals, _len4, _m, _n, _ref5;
          subopts = {
            derivedAttributes: opts.derivedAttributes,
            localeStrings: opts.localeStrings,
            rendererOptions: opts.rendererOptions,
            cols: [],
            rows: []
          };
          numInputsToProcess = (_ref5 = opts.aggregators[aggregator.val()]([])().numInputs) != null ? _ref5 : 0;
          vals = [];
          _this.find(".pvtRows li span.pvtAttr").each(function() {
            return subopts.rows.push($(this).data("attrName"));
          });
          _this.find(".pvtCols li span.pvtAttr").each(function() {
            return subopts.cols.push($(this).data("attrName"));
          });
          _this.find(".pvtVals select.pvtAttrDropdown").each(function() {
            if (numInputsToProcess === 0) {
              return $(this).remove();
            } else {
              numInputsToProcess--;
              if ($(this).val() !== "") {
                return vals.push($(this).val());
              }
            }
          });
          if (numInputsToProcess !== 0) {
            pvtVals = _this.find(".pvtVals");
            for (x = _m = 0; 0 <= numInputsToProcess ? _m < numInputsToProcess : _m > numInputsToProcess; x = 0 <= numInputsToProcess ? ++_m : --_m) {
              newDropdown = $("<select class='pvtAttrDropdown'>").append($("<option>")).bind("change", function() {
                return refresh();
              });
              for (_n = 0, _len4 = shownValues.length; _n < _len4; _n++) {
                attr = shownValues[_n];
                newDropdown.append($("<option>").val(attr).text(attr));
              }
              pvtVals.append(newDropdown);
            }
          }
          if (initialRender) {
            vals = opts.vals;
            i = 0;
            _this.find(".pvtVals select.pvtAttrDropdown").each(function() {
              $(this).val(vals[i]);
              return i++;
            });
            initialRender = false;
          }
          subopts.aggregatorName = aggregator.val();
          subopts.vals = vals;
          subopts.aggregator = opts.aggregators[aggregator.val()](vals);
          subopts.renderer = opts.renderers[renderer.val()];
          exclusions = {};
          _this.find('input.pvtFilter').not(':checked').each(function() {
            var filter;
            filter = $(this).data("filter");
            if (exclusions[filter[0]] != null) {
              return exclusions[filter[0]].push(filter[1]);
            } else {
              return exclusions[filter[0]] = [filter[1]];
            }
          });
          subopts.filter = function(record) {
            var excludedItems, _ref6;
            if (!opts.filter(record)) {
              return false;
            }
            for (k in exclusions) {
              excludedItems = exclusions[k];
              if (_ref6 = "" + record[k], __indexOf.call(excludedItems, _ref6) >= 0) {
                return false;
              }
            }
            return true;
          };
          pivotTable.pivot(input, subopts);
          pivotUIOptions = $.extend(opts, {
            cols: subopts.cols,
            rows: subopts.rows,
            vals: vals,
            exclusions: exclusions,
            aggregatorName: aggregator.val(),
            rendererName: renderer.val()
          });
          _this.data("pivotUIOptions", pivotUIOptions);
          if (opts.autoSortUnusedAttrs) {
            natSort = $.pivotUtilities.naturalSort;
            unusedAttrsContainer = _this.find("td.pvtUnused.pvtAxisContainer");
            $(unusedAttrsContainer).children("li").sort(function(a, b) {
              return natSort($(a).text(), $(b).text());
            }).appendTo(unusedAttrsContainer);
          }
          pivotTable.css("opacity", 1);
          if (opts.onRefresh != null) {
            return opts.onRefresh(pivotUIOptions);
          }
        };
      })(this);
      refresh = (function(_this) {
        return function() {
          pivotTable.css("opacity", 0.5);
          return setTimeout(refreshDelayed, 10);
        };
      })(this);
      refresh();
      this.data("refresh", refresh);
      this.find(".pvtAxisContainer").sortable({
        update: function(e, ui) {
          if (ui.sender == null) {
            return refresh();
          }
        },
        connectWith: this.find(".pvtAxisContainer"),
        items: 'li',
        placeholder: 'pvtPlaceholder'
      });
    } catch (_error) {
      e = _error;
      if (typeof console !== "undefined" && console !== null) {
        console.error(e.stack);
      }
      this.html(opts.localeStrings.uiRenderError);
    }
    return this;
  };

}).call(this);
