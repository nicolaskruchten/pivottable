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

    $.pivotUtilities.locales.es = 

        localeStrings:
            renderError: "Ocurrió un error durante la interpretación de la tabla din´mica."
            computeError: "Ocurrió un error durante el c´lculo de la tabla din´mica."
            uiRenderError: "Ocurrió un error durante el dibujado de la tabla din´mica."
            selectAll: "Seleccionar todo"
            selectNone: "Deseleccionar todo"
            tooMany: "(demasiados valores)"
            filterResults: "Filtrar resultados"
            totals: "Totales"
            vs: "vs"
            by: "por"
        aggregators: 
            "Cuenta":                             tpl.count(frFmtInt)
            "Cuenta de valores únicos":          tpl.countUnique(frFmtInt)
            "Lista de valores únicos":           tpl.listUnique(", ")
            "Suma":                              tpl.sum(frFmt)
            "Suma de enteros":                   tpl.sum(frFmtInt)
            "Promedio":                            tpl.average(frFmt)
            "Mínimo":                                       tpl.min(frFmt)
            "Máximo":                                       tpl.max(frFmt)
            "Suma de sumas":                    tpl.sumOverSum(frFmt)
            "Cota 80% superior":        tpl.sumOverSumBound80(true, frFmt)
            "Cota 80% inferior":        tpl.sumOverSumBound80(false, frFmt)
            "Proporción del total (suma)":      tpl.fractionOf(tpl.sum(),   "total", frFmtPct)
            "Proporción de la fila (suma)":    tpl.fractionOf(tpl.sum(),   "row",   frFmtPct)
            "Proporción de la columna (suma)":  tpl.fractionOf(tpl.sum(),   "col",   frFmtPct)
            "Proporción del total (cuenta)":     tpl.fractionOf(tpl.count(), "total", frFmtPct)
            "Proporción de la fila (cuenta)":   tpl.fractionOf(tpl.count(), "row",   frFmtPct)
            "Proporción de la columna (cuenta)": tpl.fractionOf(tpl.count(), "col",   frFmtPct)

        renderers:
            "Tabla":                           $.pivotUtilities.renderers["Table"]
            "Tabla con barras":               $.pivotUtilities.renderers["Table Barchart"]
            "Heatmap":                $.pivotUtilities.renderers["Heatmap"]
            "Heatmap por filas":      $.pivotUtilities.renderers["Row Heatmap"]
            "Heatmap por columnas":    $.pivotUtilities.renderers["Col Heatmap"]


