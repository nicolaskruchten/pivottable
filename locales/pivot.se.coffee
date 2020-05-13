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

    $.pivotUtilities.locales.se = 
        localeStrings:
          renderError: "Ett fel uppstod när PivotTable-resultaten skulle ritas upp.",
          computeError: "Ett fel uppstod när PivotTable-resultaten skulle beräknas.",
          uiRenderError: "Ett fel uppstod när användargränssnittet för PivotTable skulle ritas upp.",
          selectAll: "Välj alla",
          selectNone: "Välj ingen",
          tooMany: "(för många att lista)",
          filterResults: "Filtrera värden",
          apply: "Verkställ",
          cancel: "Avbryt",
          totals: "Totalt",
          vs: "mot",
          by: "av"
			

        aggregators: 
            "Antal":                 			tpl.count(frFmtInt)
            "Antal unika värden": 				tpl.countUnique(frFmtInt)
            "Lista unika värden":				tpl.listUnique(", ")
            "Summa":							tpl.sum(frFmt)
            "Heltal":							tpl.sum(frFmtInt)
            "Medelvärde":						tpl.average(frFmt)
            "Median":							tpl.median(frFmt),
			"Urval avvikelse":					tpl["var"](1, frFmt),
			"Urval standardavvikelse": 			tpl.stdev(1, frFmt),
			"Minimum":                      	tpl.min(frFmt)
            "Maximum":                      	tpl.max(frFmt)
		    "Första": tpl.first(usFmt),
			"Sista": tpl.last(usFmt)
            "Summa över summa":					tpl.sumOverSum(frFmt)
            "80% övre gräns":					tpl.sumOverSumBound80(true, frFmt)
            "80% undre gräns":					tpl.sumOverSumBound80(false, frFmt)
            "Summa som en andel av det totala": tpl.fractionOf(tpl.sum(),   "total", frFmtPct)
            "Summa som en del av raden": 		tpl.fractionOf(tpl.sum(),   "row",   frFmtPct)
            "Summa som en del av kolumnen":		tpl.fractionOf(tpl.sum(),   "col",   frFmtPct)
            "Antal som en del av det totala":	tpl.fractionOf(tpl.count(), "total", frFmtPct)
            "Antal som en del av raden":		tpl.fractionOf(tpl.count(), "row",   frFmtPct)
            "Antal som en del av kolumnen":		tpl.fractionOf(tpl.count(), "col",   frFmtPct)

        renderers:
            "Tabell":                  		    $.pivotUtilities.renderers["Table"]
            "Tabell med stapeldiagram": 		$.pivotUtilities.renderers["Table Barchart"]
            "Värmekarta":						$.pivotUtilities.renderers["Heatmap"]
            "Värmekarta per rad":				$.pivotUtilities.renderers["Row Heatmap"]
            "Värmekarta per kolumn":			$.pivotUtilities.renderers["Col Heatmap"]