nf = $.pivotUtilities.numberFormat
tpl = $.pivotUtilities.aggregatorTemplates

frFmt =    nf(thousandsSep: " ", decimalSep: ",")
frFmtInt = nf(sigfig: 0, thousandsSep: " ", decimalSep: ",")
frFmtPct = nf(sigfig:1, scaler: 100, suffix: "%", thousandsSep: " ", decimalSep: ",")

$.pivotUtilities.locales.fr = 

    localeStrings:
        renderError: "An error occurred rendering the PivotTable results."
        computeError: "An error occurred computing the PivotTable results."
        uiRenderError: "An error occurred rendering the PivotTable UI."
        selectAll: "Select All"
        selectNone: "Select None"
        tooMany: "(too many to list)"
        filterResults: "Filter results"
        totals: "Totaux"
        vs: "versus"
        by: "par"

    aggregators: 
        "Nombre":                tpl.count(frFmtInt)
        "Nombre de valeurs uniques":  tpl.countUnique(frFmtInt)
        "List Unique Values":   tpl.listUnique(",")
        "Sum":                  tpl.sum(frFmt)
        "Integer Sum":          tpl.sum(frFmtInt)
        "Average":              tpl.average(frFmt)
        "Sum over Sum":         tpl.sumOverSum(frFmt)
        "80% Upper Bound":      tpl.sumOverSumBound80(true, frFmt)
        "80% Lower Bound":      tpl.sumOverSumBound80(false, frFmt)
        "Sum as Fraction of Total":     tpl.fractionOf(tpl.sum(),   "total", frFmtPct)
        "Sum as Fraction of Rows":      tpl.fractionOf(tpl.sum(),   "row",   frFmtPct)
        "Sum as Fraction of Columns":   tpl.fractionOf(tpl.sum(),   "col",   frFmtPct)
        "Count as Fraction of Total":   tpl.fractionOf(tpl.count(), "total", frFmtPct)
        "Count as Fraction of Rows":    tpl.fractionOf(tpl.count(), "row",   frFmtPct)
        "Count as Fraction of Columns": tpl.fractionOf(tpl.count(), "col",   frFmtPct)

    renderers:
        "Table":          $.pivotUtilities.renderers["Table"]
        "Table Barcharte": $.pivotUtilities.renderers["Table Barchart"]
        "Heatmape":        $.pivotUtilities.renderers["Heatmap"]
        "Row Heatmape":    $.pivotUtilities.renderers["Row Heatmap"]
        "Col Heatmape":    $.pivotUtilities.renderers["Col Heatmap"]


