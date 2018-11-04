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
    var jpFmt, jpFmtInt, jpFmtPct, nf, tpl;
    nf = $.pivotUtilities.numberFormat;
    tpl = $.pivotUtilities.aggregatorTemplates;
    jpFmt = nf({
      thousandsSep: ",",
      decimalSep: "."
    });
    jpFmtInt = nf({
      digitsAfterDecimal: 0,
      thousandsSep: ",",
      decimalSep: "."
    });
    jpFmtPct = nf({
      digitsAfterDecimal: 1,
      scaler: 100,
      suffix: "%",
      thousandsSep: ",",
      decimalSep: "."
    });
    return $.pivotUtilities.locales.ja = {
      localeStrings: {
        renderError: "描画処理でエラーが発生しました。",
        computeError: "処理中にエラーが発生しました。",
        uiRenderError: "表示処理中にエラーが発生しました。",
        selectAll: "全選択",
        selectNone: "選択解除",
        tooMany: "項目が多すぎます",
        filterResults: "項目を検索する",
        totals: "合計",
        vs: "vs",
        by: "per",
        apply: "適用する",
        cancel: "キャンセル"
      },
      aggregators: {
        "件数": tpl.count(jpFmtInt),
        "件数（ユニーク）": tpl.countUnique(jpFmtInt),
        "ユニーク値を表示 (CSV)": tpl.listUnique(", "),
        "合計": tpl.sum(jpFmt),
        "合計（整数）": tpl.sum(jpFmtInt),
        "平均": tpl.average(jpFmt),
        "最小": tpl.min(jpFmt),
        "最大": tpl.max(jpFmt),
        "選択２項目の比率": tpl.sumOverSum(jpFmt),
        "選択２項目の比率（上限80%）": tpl.sumOverSumBound80(true, jpFmt),
        "選択２項目の比率（下限80%）": tpl.sumOverSumBound80(false, jpFmt),
        "合計割合": tpl.fractionOf(tpl.sum(), "total", jpFmtPct),
        "合計割合（行）": tpl.fractionOf(tpl.sum(), "row", jpFmtPct),
        "合計割合（列）": tpl.fractionOf(tpl.sum(), "col", jpFmtPct),
        "件数割合": tpl.fractionOf(tpl.count(), "total", jpFmtPct),
        "件数割合（行）": tpl.fractionOf(tpl.count(), "row", jpFmtPct),
        "件数割合（列）": tpl.fractionOf(tpl.count(), "col", jpFmtPct)
      },
      renderers: {
        "表": $.pivotUtilities.renderers["Table"],
        "表（棒グラフ）": $.pivotUtilities.renderers["Table Barchart"],
        "ヒートマップ": $.pivotUtilities.renderers["Heatmap"],
        "ヒートマップ（行）": $.pivotUtilities.renderers["Row Heatmap"],
        "ヒートマップ（列）": $.pivotUtilities.renderers["Col Heatmap"]
      }
    };
  });

}).call(this);

//# sourceMappingURL=pivot.jp.js.map
