callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->
    nf = $.pivotUtilities.numberFormat
    tpl = $.pivotUtilities.aggregatorTemplates

    plFmt =    nf(thousandsSep: " ", decimalSep: ",")
    plFmtInt = nf(digitsAfterDecimal: 0, thousandsSep: " ", decimalSep: ",")
    plFmtPct = nf(digitsAfterDecimal: 1, scaler: 100, suffix: "%", thousandsSep: " ", decimalSep: ",")

    $.pivotUtilities.locales.pl =
        localeStrings:
            renderError: "Wystąpił błąd podczas renderowania wyników PivotTable."
            computeError: "Wystąpił błąd podczas obliczania wyników PivotTable."
            uiRenderError: "Wystąpił błąd podczas renderowania UI PivotTable."
            selectAll: "Zaznacz wszystko"
            selectNone: "Odznacz wszystkie"
            tooMany: "(za dużo do wylistowania)"
            filterResults: "Filtruj wartości"
            apply: "Zastosuj"
            cancel: "Anuluj"
            totals: "Podsumowanie"
            vs: "vs"
            by: "przez"

        aggregators: 
            "Liczba":                       tpl.count(plFmtInt)
            "Liczba Unikatowych Wartości":  tpl.countUnique(plFmtInt)
            "Lista Unikatowych Wartości":   tpl.listUnique(", ")
            "Suma":                         tpl.sum(plFmt)
            "Całkowita Suma":               tpl.sum(plFmtInt)
            "Średnia":                      tpl.average(plFmt)
            "Minimum":                      tpl.min(plFmt)
            "Maksimum":                     tpl.max(plFmt)
            "Pierwszy":                     tpl.first(plFmt)
            "Ostatni":                      tpl.last(plFmt)
            "Suma po Sumie":                tpl.sumOverSum(plFmt)
            "80% Kres Dolny":               tpl.sumOverSumBound80(true, plFmt)
            "80% Kres Górny":               tpl.sumOverSumBound80(false, plFmt)
            "Suma jako Ułamek Całości":     tpl.fractionOf(tpl.sum(),       "total", plFmtPct)
            "Suma jako Ułamek w Wierszach":     tpl.fractionOf(tpl.sum(),   "row",   plFmtPct)
            "Suma jako Ułamek w Kolumnach":     tpl.fractionOf(tpl.sum(),   "col",   plFmtPct)
            "Liczba jako Ułamek Całości":       tpl.fractionOf(tpl.count(), "total", plFmtPct)
            "Liczba jako Ułamek w Wierszach":   tpl.fractionOf(tpl.count(), "row",   plFmtPct)
            "Liczba jako Ułamek w Kolumnach":   tpl.fractionOf(tpl.count(), "col",   plFmtPct)

        renderers:
            "Tabela":                       $.pivotUtilities.renderers["Table"]
            "Tabela z Wykresem Słupkowym":  $.pivotUtilities.renderers["Table Barchart"]
            "Mapa cieplna":                 $.pivotUtilities.renderers["Heatmap"]
            "Mapa cieplna po Wierszach":    $.pivotUtilities.renderers["Row Heatmap"]
            "Mapa cieplna po Kolumnach":    $.pivotUtilities.renderers["Col Heatmap"]
