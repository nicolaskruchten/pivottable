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
    var frFmt, frFmtInt, frFmtPct, nf, tpl;
    nf = $.pivotUtilities.numberFormat;
    tpl = $.pivotUtilities.aggregatorTemplates;
    frFmt = nf({
      thousandsSep: ".",
      decimalSep: ","
    });
    frFmtInt = nf({
      digitsAfterDecimal: 0,
      thousandsSep: ".",
      decimalSep: ","
    });
    frFmtPct = nf({
      digitsAfterDecimal: 1,
      scaler: 100,
      suffix: "%",
      thousandsSep: ".",
      decimalSep: ","
    });
    return $.pivotUtilities.locales.tr = {
      localeStrings: {
        renderError: "PivotTable sonu&ccedil;lar&#305;n&#305; olu&#351;tuturken hata olu&#351;tu",
        computeError: "PivotTable sonu&ccedil;lar&#305;n&#305; i&#351;lerken hata olu&#351;tu",
        uiRenderError: "PivotTable UI sonu&ccedil;lar&#305;n&#305; olu&#351;tuturken hata olu&#351;tu",
        selectAll: "T&uuml;m&uuml;n&uuml; Se&ccedil;",
        selectNone: "T&uuml;m&uuml;n&uuml; B&#305;rak",
        tooMany: "(listelemek i&ccedil;in fazla)",
        filterResults: "Sonu&ccedil;lar&#305; filtrele",
        totals: "Toplam",
        vs: "vs",
        by: "ile"
      },
      aggregators: {
        "Say&#305;": tpl.count(frFmtInt),
        "Benzersiz de&#287;erler say&#305;s&#305;": tpl.countUnique(frFmtInt),
        "Benzersiz de&#287;erler listesi": tpl.listUnique(", "),
        "Toplam": tpl.sum(frFmt),
        "Toplam (tam say&#305;)": tpl.sum(frFmtInt),
        "Ortalama": tpl.average(frFmt),
        "Min": tpl.min(frFmt),
        "Maks": tpl.max(frFmt),
        "Miktarlar&#305;n toplam&#305;": tpl.sumOverSum(frFmt),
        "%80 daha y&uuml;ksek": tpl.sumOverSumBound80(true, frFmt),
        "%80 daha d&uuml;&#351;&uuml;k": tpl.sumOverSumBound80(false, frFmt),
        "Toplam oran&#305; (toplam)": tpl.fractionOf(tpl.sum(), "total", frFmtPct),
        "Sat&#305;r oran&#305; (toplam)": tpl.fractionOf(tpl.sum(), "row", frFmtPct),
        "S&uuml;tunun oran&#305; (toplam)": tpl.fractionOf(tpl.sum(), "col", frFmtPct),
        "Toplam oran&#305; (say&#305;)": tpl.fractionOf(tpl.count(), "total", frFmtPct),
        "Sat&#305;r oran&#305; (say&#305;)": tpl.fractionOf(tpl.count(), "row", frFmtPct),
        "S&uuml;tunun oran&#305; (say&#305;)": tpl.fractionOf(tpl.count(), "col", frFmtPct)
      },
      renderers: {
        "Tablo": $.pivotUtilities.renderers["Table"],
        "Tablo (&Ccedil;ubuklar)": $.pivotUtilities.renderers["Table Barchart"],
        "&#304;lgi haritas&#305;": $.pivotUtilities.renderers["Heatmap"],
        "Sat&#305;r ilgi haritas&#305;": $.pivotUtilities.renderers["Row Heatmap"],
        "S&uuml;tun ilgi haritas&#305;": $.pivotUtilities.renderers["Col Heatmap"]
      }
    };
  });

}).call(this);

//# sourceMappingURL=pivot.tr.js.map