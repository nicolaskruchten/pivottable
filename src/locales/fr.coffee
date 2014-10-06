nf = $.pivotUtilities.numberFormat
tpl = $.pivotUtilities.aggregatorTemplates

frFmt =    nf(thousandsSep: " ", decimalSep: ",")
frFmtInt = nf(digitsAfterDecimal: 0, thousandsSep: " ", decimalSep: ",")
frFmtPct = nf(digitsAfterDecimal: 1, scaler: 100, suffix: "%", thousandsSep: " ", decimalSep: ",")

$.pivotUtilities.locales.fr =

    localeStrings:
        renderError: "Une erreur est survenue en dessinant le tableau crois&eacute;."
        computeError: "Une erreur est survenue en calculant le tableau crois&eacute;."
        uiRenderError: "Une erreur est survenue en dessinant l'interface du tableau crois&eacute; dynamique."
        selectAll: "S&eacute;lectionner tout"
        selectNone: "S&eacute;lectionner rien"
        tooMany: "(trop de valeurs &agrave; afficher)"
        filterResults: "Filtrer les valeurs"
        totals: "Totaux"
        vs: "sur"
        by: "par"

    aggregators:
        "Nombre":                             tpl.Count(frFmtInt)
        "Somme":                              tpl.Sum(frFmt)
        "Somme en entiers":                   tpl.Sum(frFmtInt)
        "Moyenne":                            tpl.Average(frFmt)
        "Somme en proportion du totale":      tpl.fractionOf(tpl.Sum(),   "total", frFmtPct)
        "Somme en proportion de la ligne":    tpl.fractionOf(tpl.Sum(),   "row",   frFmtPct)
        "Somme en proportion de la colonne":  tpl.fractionOf(tpl.Sum(),   "col",   frFmtPct)
        "Nombre en proportion du totale":     tpl.fractionOf(tpl.Count(), "total", frFmtPct)
        "Nombre en proportion de la ligne":   tpl.fractionOf(tpl.Count(), "row",   frFmtPct)
        "Nombre en proportion de la colonne": tpl.fractionOf(tpl.Count(), "col",   frFmtPct)

    renderers:
        "Table":                           $.pivotUtilities.renderers["Table"]
        "Table avec barres":               $.pivotUtilities.renderers["Table Barchart"]
        "Carte de chaleur":                $.pivotUtilities.renderers["Heatmap"]
        "Carte de chaleur par ligne":      $.pivotUtilities.renderers["Row Heatmap"]
        "Carte de chaleur par colonne":    $.pivotUtilities.renderers["Col Heatmap"]


