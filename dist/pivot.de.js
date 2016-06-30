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
      thousandsSep: " ",
      decimalSep: ","
    });
    frFmtInt = nf({
      digitsAfterDecimal: 0,
      thousandsSep: " ",
      decimalSep: ","
    });
    frFmtPct = nf({
      digitsAfterDecimal: 1,
      scaler: 100,
      suffix: "%",
      thousandsSep: " ",
      decimalSep: ","
    });
    return $.pivotUtilities.locales.fr = {
      localeStrings: {
        renderError: "Bei der Darstellung der Pivot-Tabelle ist ein Fehler aufgetreten.",
        computeError: "Bei der Berechnung der Pivot-Tabelle ist ein Fehler aufgetreten.",
        uiRenderError: "Bei der Darstellung Oberfläche der Pivot-Tabelle ist ein Fehler aufgetreten.",
        selectAll: "Alles auswählen",
        selectNone: "Nichts auswählen",
        tooMany: "(zu viele für Liste)",
        filterResults: "Ergebnisse filtern",
        totals: "Gesamt",
        vs: "gegen",
        by: "pro"
      },
      aggregators: {
        "Anzahl": tpl.count(frFmtInt),
        "Anzahl eindeutiger Werte": tpl.countUnique(frFmtInt),
        "Liste eindeutiger Werte": tpl.listUnique(", "),
        "Summe": tpl.sum(frFmt),
        "Ganzzahlige Summe": tpl.sum(frFmtInt),
        "Durchschnitt": tpl.average(frFmt),
        "Minimum": tpl.min(frFmt),
        "Maximum": tpl.max(frFmt),
        "Summe über Summe": tpl.sumOverSum(frFmt),
        "80% Obergrenze": tpl.sumOverSumBound80(true, frFmt),
        "80% Untergrenze": tpl.sumOverSumBound80(false, frFmt),
        "Summe als Anteil von Gesamt": tpl.fractionOf(tpl.sum(), "total", frFmtPct),
        "Summe als Anteil von Zeile": tpl.fractionOf(tpl.sum(), "row", frFmtPct),
        "Summe als Anteil von Spalte": tpl.fractionOf(tpl.sum(), "col", frFmtPct),
        "Anzahl als Anteil von Gesamt": tpl.fractionOf(tpl.count(), "total", frFmtPct),
        "Anzahl als Anteil von Zeile": tpl.fractionOf(tpl.count(), "row", frFmtPct),
        "Anzahl als Anteil von Spalte": tpl.fractionOf(tpl.count(), "col", frFmtPct)
      },
      renderers: {
        "Tabelle": $.pivotUtilities.renderers["Table"],
        "Tabelle mit Balkendiagramm": $.pivotUtilities.renderers["Table Barchart"],
        "Heatmap": $.pivotUtilities.renderers["Heatmap"],
        "Heatmap pro Zeile": $.pivotUtilities.renderers["Row Heatmap"],
        "Heatmap pro Spalte": $.pivotUtilities.renderers["Col Heatmap"]
      }
    };
  });

}).call(this);

//# sourceMappingURL=pivot.de.js.map
