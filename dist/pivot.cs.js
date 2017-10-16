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
    var csFmt, csFmtInt, csFmtPct, nf, tpl;
    nf = $.pivotUtilities.numberFormat;
    tpl = $.pivotUtilities.aggregatorTemplates;
    csFmt = nf({
      thousandsSep: " ",
      decimalSep: ","
    });
    csFmtInt = nf({
      digitsAfterDecimal: 0,
      thousandsSep: " ",
      decimalSep: ","
    });
    csFmtPct = nf({
      digitsAfterDecimal: 1,
      scaler: 100,
      suffix: "%",
      thousandsSep: " ",
      decimalSep: ","
    });
    return $.pivotUtilities.locales.cs = {
      localeStrings: {
        renderError: "Došlo k chybě při vykreslování výsledků PivotTable.",
        computeError: "Došlo k chybě při výpočtu výsledků PivotTable.",
        uiRenderError: "Došlo k chybě při vykreslování PivotTable UI.",
        selectAll: "Vybrat vše",
        selectNone: "Zrušit výběr",
        tooMany: "(příliš mnoho položek)",
        filterResults: "Hodnoty pro filtr",
        apply: "Použít",
        cancel: "Zrušit",
        totals: "Celkem",
        vs: "ku",
        by: "z"
      },
      aggregators: {
        "Počet": tpl.count(csFmtInt),
        "Počet unikátních hodnot": tpl.countUnique(csFmtInt),
        "Výčet unikátních hodnot": tpl.listUnique(", "),
        "Součet": tpl.sum(csFmt),
        "Celočíselný součet": tpl.sum(csFmtInt),
        "Průměr": tpl.average(csFmt),
        "Medián": tpl.median(csFmt),
        "Rozptyl": tpl["var"](1, csFmt),
        "Směrodatná odchylka": tpl.stdev(1, csFmt),
        "Minimum": tpl.min(csFmt),
        "Maximum": tpl.max(csFmt),
        "První": tpl.first(csFmt),
        "Poslední": tpl.last(csFmt),
        "Součet přes součet": tpl.sumOverSum(csFmt),
        "80% horní hranice": tpl.sumOverSumBound80(true, csFmt),
        "80% spodní hranice": tpl.sumOverSumBound80(false, csFmt),
        "Součet jako poměr z celku": tpl.fractionOf(tpl.sum(), "total", csFmtPct),
        "Součet jako poměr z řádků": tpl.fractionOf(tpl.sum(), "row", csFmtPct),
        "Součet jako poměr ze sloupců": tpl.fractionOf(tpl.sum(), "col", csFmtPct),
        "Počet jako poměr z celku": tpl.fractionOf(tpl.count(), "total", csFmtPct),
        "Počet jako poměr z řádků": tpl.fractionOf(tpl.count(), "row", csFmtPct),
        "Počet jako poměr ze sloupců": tpl.fractionOf(tpl.count(), "col", csFmtPct)
      },
      renderers: {
        "Tabulka": $.pivotUtilities.renderers["Table"],
        "Tabulka se sloupcovým grafem": $.pivotUtilities.renderers["Table Barchart"],
        "Teplotní mapa": $.pivotUtilities.renderers["Heatmap"],
        "Teplotní mapa z řádků": $.pivotUtilities.renderers["Row Heatmap"],
        "Teplotní mapa ze sloupců": $.pivotUtilities.renderers["Col Heatmap"]
      }
    };
  });

}).call(this);

//# sourceMappingURL=pivot.cs.js.map
