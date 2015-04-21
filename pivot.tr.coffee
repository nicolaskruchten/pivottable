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

    frFmt =    nf(thousandsSep: ".", decimalSep: ",")
    frFmtInt = nf(digitsAfterDecimal: 0, thousandsSep: ".", decimalSep: ",")
    frFmtPct = nf(digitsAfterDecimal: 1, scaler: 100, suffix: "%", thousandsSep: ".", decimalSep: ",")

    $.pivotUtilities.locales.tr = 

        localeStrings:
            renderError: "PivotTable sonuçlarını oluştuturken hata oluştu"
            computeError: "PivotTable sonuçlarını işlerken hata oluştu"
            uiRenderError: "PivotTable UI sonuçlarını oluştuturken hata oluştu"
            selectAll: "Tümünü Seç"
            selectNone: "Tümünü Bırak"
            tooMany: "(listelemek için fazla)"
            filterResults: "Sonuçları filtrele"
            totals: "Toplam"
            vs: "vs"
            by: "ile"
        aggregators: 
            "Sayı":                             tpl.count(frFmtInt)
            "Benzersiz değerler sayısı":          tpl.countUnique(frFmtInt)
            "Benzersiz değerler listesi":           tpl.listUnique(", ")
            "Toplam":                              tpl.sum(frFmt)
            "Toplam (tam sayı)":                   tpl.sum(frFmtInt)
            "Ortalama":                            tpl.average(frFmt)
            "Min":                                       tpl.min(frFmt)
            "Maks":                                       tpl.max(frFmt)
            "Miktarların toplamı":                    tpl.sumOverSum(frFmt)
            "%80 daha yüksek":        tpl.sumOverSumBound80(true, frFmt)
            "%80 daha düşük":        tpl.sumOverSumBound80(false, frFmt)
            "Toplam oranı (toplam)":      tpl.fractionOf(tpl.sum(),   "total", frFmtPct)
            "Satır oranı (toplam)":    tpl.fractionOf(tpl.sum(),   "row",   frFmtPct)
            "Sütunun oranı (toplam)":  tpl.fractionOf(tpl.sum(),   "col",   frFmtPct)
            "Toplam oranı (sayı)":     tpl.fractionOf(tpl.count(), "total", frFmtPct)
            "Satır oranı (sayı)":   tpl.fractionOf(tpl.count(), "row",   frFmtPct)
            "Sütunun oranı (sayı)": tpl.fractionOf(tpl.count(), "col",   frFmtPct)

        renderers:
            "Tablo":                           $.pivotUtilities.renderers["Table"]
            "Tablo (Çubuklar)":               $.pivotUtilities.renderers["Table Barchart"]
            "İlgi haritası":                $.pivotUtilities.renderers["Heatmap"]
            "Satır ilgi haritası":      $.pivotUtilities.renderers["Row Heatmap"]
            "Sütun ilgi haritası":    $.pivotUtilities.renderers["Col Heatmap"]


