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

    frFmt =    nf(thousandsSep: " ", decimalSep: ",")
    frFmtInt = nf(digitsAfterDecimal: 0, thousandsSep: " ", decimalSep: ",")
    frFmtPct = nf(digitsAfterDecimal: 1, scaler: 100, suffix: "%", thousandsSep: " ", decimalSep: ",")

    $.pivotUtilities.locales.sq = 
        localeStrings:
            renderError: "Ka ndodhur një gabim gjatë shfaqjes së rezultateve të PivotTable."
            computeError: "Ka ndodhur një gabim gjatë llogaritjes së rezultateve të PivotTable."
            uiRenderError: "Ka ndodhur një gabim gjatë shfaqjes së ndërfaqes së PivotTable."
            selectAll: "Përzgjedh të gjitha"
            selectNone: "Mos përzgjedh asnjërën"
            tooMany: "(shumë për t'u listuar)"
            filterResults: "Filtro vlerat"
            totals: "Totalet"
            vs: "kundër"
            by: "për"

        aggregators: 
            "Numëro":                       tpl.count(frFmtInt)
            "Numëro vlerat unike":     tpl.countUnique(frFmtInt)
            "Listo vlerat unike":      tpl.listUnique(", ")
            "Shuma":                        tpl.sum(frFmt)
            "Shuma si numër i plotë":			tpl.sum(frFmtInt)
            "Mesatarja":                 tpl.average(frFmt)
            "Minimumi":                      tpl.min(frFmt)
            "Maksimumi":                      tpl.max(frFmt)
            "Shuma mbi shumë":             tpl.sumOverSum(frFmt)
            "80% kufiri i sipërm":               tpl.sumOverSumBound80(true, frFmt)
            "80% kufiri i poshtëm":        		tpl.sumOverSumBound80(false, frFmt)
            "Shuma si thyesë e totalit":  tpl.fractionOf(tpl.sum(),   "total", frFmtPct)
            "Shuma si thyesë e rreshtave":   tpl.fractionOf(tpl.sum(),   "row",   frFmtPct)
            "Shuma si thyesë e kolonave":  tpl.fractionOf(tpl.sum(),   "col",   frFmtPct)
            "Numërimi si thyesë e totalit": tpl.fractionOf(tpl.count(), "total", frFmtPct)
            "Numërimi si thyesë e rreshtave":  tpl.fractionOf(tpl.count(), "row",   frFmtPct)
            "Numërimi si thyesë e kolonave": tpl.fractionOf(tpl.count(), "col",   frFmtPct)
        
        renderers:
            "Tabela":                      $.pivotUtilities.renderers["Table"]
            "Tabela me diagram vertikal":   $.pivotUtilities.renderers["Table Barchart"]
            "Heatmap":                      $.pivotUtilities.renderers["Heatmap"]
            "Heatmap për rresht":            $.pivotUtilities.renderers["Row Heatmap"]
            "Heatmap për kolonë":           $.pivotUtilities.renderers["Col Heatmap"]
