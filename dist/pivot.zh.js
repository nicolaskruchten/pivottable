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
    var c3r, d3r, frFmt, frFmtInt, frFmtPct, gcr, nf, r, tpl;
    nf = $.pivotUtilities.numberFormat;
    tpl = $.pivotUtilities.aggregatorTemplates;
    r = $.pivotUtilities.renderers;
    gcr = $.pivotUtilities.gchart_renderers;
    d3r = $.pivotUtilities.d3_renderers;
    c3r = $.pivotUtilities.c3_renderers;
    frFmt = nf({
      thousandsSep: ",",
      decimalSep: "."
    });
    frFmtInt = nf({
      digitsAfterDecimal: 0,
      thousandsSep: ",",
      decimalSep: "."
    });
    frFmtPct = nf({
      digitsAfterDecimal: 2,
      scaler: 100,
      suffix: "%",
      thousandsSep: ",",
      decimalSep: "."
    });
    $.pivotUtilities.locales.zh = {
      localeStrings: {
        renderError: "展示结果时出错。",
        computeError: "计算结果时出错。",
        uiRenderError: "展示界面时出错。",
        selectAll: "选择全部",
        selectNone: "全部不选",
        tooMany: "(因数据过多而无法列出)",
        filterResults: "输入值帮助筛选",
        totals: "合计",
        vs: "于",
        by: "分组于"
      },
      aggregators: {
        "频数": tpl.count(frFmtInt),
        "非重复值的个数": tpl.countUnique(frFmtInt),
        "列出非重复值": tpl.listUnique(", "),
        "求和": tpl.sum(frFmt),
        "求和后取整": tpl.sum(frFmtInt),
        "平均值": tpl.average(frFmt),
        "最小值": tpl.min(frFmt),
        "最大值": tpl.max(frFmt),
        "两和之比": tpl.sumOverSum(frFmt),
        "二项分布：置信度为80%时的区间上限": tpl.sumOverSumBound80(true, frFmt),
        "二项分布：置信度为80%时的区间下限": tpl.sumOverSumBound80(false, frFmt),
        "和在总计中的比例": tpl.fractionOf(tpl.sum(), "total", frFmtPct),
        "和在行合计中的比例": tpl.fractionOf(tpl.sum(), "row", frFmtPct),
        "和在列合计中的比例": tpl.fractionOf(tpl.sum(), "col", frFmtPct),
        "频数在总计中的比例": tpl.fractionOf(tpl.count(), "total", frFmtPct),
        "频数在行合计中的比例": tpl.fractionOf(tpl.count(), "row", frFmtPct),
        "频数在列合计中的比例": tpl.fractionOf(tpl.count(), "col", frFmtPct)
      },
      renderers: {
        "表格": r["Table"],
        "表格内柱状图": r["Table Barchart"],
        "热图": r["Heatmap"],
        "行热图": r["Row Heatmap"],
        "列热图": r["Col Heatmap"]
      }
    };
    if (gcr) {
      $.pivotUtilities.locales.zh.gchart_renderers = {
        "折线图(g)": gcr["Line Chart"],
        "柱形图(g)": gcr["Bar Chart"],
        "堆栈柱形图(g)": gcr["Stacked Bar Chart"],
        "面积图(g)": gcr["Area Chart"]
      };
      $.pivotUtilities.locales.zh.renderers = $.extend($.pivotUtilities.locales.zh.renderers, $.pivotUtilities.locales.zh.gchart_renderers);
    }
    if (d3r) {
      $.pivotUtilities.locales.zh.d3_renderers = {
        "树图": d3r["Treemap"]
      };
      $.pivotUtilities.locales.zh.renderers = $.extend($.pivotUtilities.locales.zh.renderers, $.pivotUtilities.locales.zh.d3_renderers);
    }
    if (c3r) {
      $.pivotUtilities.locales.zh.c3_renderers = {
        "折线图": c3r["Line Chart"],
        "柱形图": c3r["Bar Chart"],
        "堆栈柱形图": c3r["Stacked Bar Chart"],
        "面积图": c3r["Area Chart"],
        "散点图": c3r["Scatter Chart"]
      };
      $.pivotUtilities.locales.zh.renderers = $.extend($.pivotUtilities.locales.zh.renderers, $.pivotUtilities.locales.zh.c3_renderers);
    }
    return $.pivotUtilities.locales.zh;
  });

}).call(this);

//# sourceMappingURL=pivot.zh.js.map