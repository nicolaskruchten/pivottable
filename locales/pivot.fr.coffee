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

    $.pivotUtilities.locales.fr =
        localeStrings:
            renderError: "Une erreur est survenue en dessinant le tableau croisé."
            computeError: "Une erreur est survenue en calculant le tableau croisé."
            uiRenderError: "Une erreur est survenue en dessinant l'interface du tableau croisé dynamique."
            selectAll: "Sélectionner tout"
            selectNone: "Sélectionner rien"
            tooMany: "(trop de valeurs à afficher)"
            filterResults: "Filtrer les valeurs"
            totals: "Totaux"
            vs: "sur"
            by: "par"
            apply: "Appliquer"
            cancel: "Annuler"

        aggregators:
            "Nombre":                             tpl.count(frFmtInt)
            "Nombre de valeurs uniques":          tpl.countUnique(frFmtInt)
            "Liste de valeurs uniques":           tpl.listUnique(", ")
            "Somme":                              tpl.sum(frFmt)
            "Somme en entiers":                   tpl.sum(frFmtInt)
            "Moyenne":                            tpl.average(frFmt)
            "Minimum":                            tpl.min(frFmt)
            "Maximum":                            tpl.max(frFmt)
            "Premier":                            tpl.first(frFmt)
            "Dernier":                            tpl.last(frFmt)
            "Ratio de sommes":                    tpl.sumOverSum(frFmt)
            "Borne supérieure 80%":               tpl.sumOverSumBound80(true, frFmt)
            "Borne inférieure 80%":               tpl.sumOverSumBound80(false, frFmt)
            "Somme en proportion du totale":      tpl.fractionOf(tpl.sum(),   "total", frFmtPct)
            "Somme en proportion de la ligne":    tpl.fractionOf(tpl.sum(),   "row",   frFmtPct)
            "Somme en proportion de la colonne":  tpl.fractionOf(tpl.sum(),   "col",   frFmtPct)
            "Nombre en proportion du totale":     tpl.fractionOf(tpl.count(), "total", frFmtPct)
            "Nombre en proportion de la ligne":   tpl.fractionOf(tpl.count(), "row",   frFmtPct)
            "Nombre en proportion de la colonne": tpl.fractionOf(tpl.count(), "col",   frFmtPct)

        renderers:
            "Table":                           $.pivotUtilities.renderers["Table"]
            "Table avec barres":               $.pivotUtilities.renderers["Table Barchart"]
            "Carte de chaleur":                $.pivotUtilities.renderers["Heatmap"]
            "Carte de chaleur par ligne":      $.pivotUtilities.renderers["Row Heatmap"]
            "Carte de chaleur par colonne":    $.pivotUtilities.renderers["Col Heatmap"]


