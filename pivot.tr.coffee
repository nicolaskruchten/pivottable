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
  r = $.pivotUtilities.renderers
  gcr = $.pivotUtilities.gchart_renderers
  d3r = $.pivotUtilities.d3_renderers
  c3r = $.pivotUtilities.c3_renderers

  frFmt = nf(thousandsSep: ".", decimalSep: ",")
  frFmtInt = nf(digitsAfterDecimal: 0, thousandsSep: ".", decimalSep: ",")
  frFmtPct = nf(digitsAfterDecimal: 2, scaler: 100, suffix: "%", thousandsSep: ".", decimalSep: ",")

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
      "Sayı": tpl.count(frFmtInt)
      "Benzersiz değerler sayısı": tpl.countUnique(frFmtInt)
      "Benzersiz değerler listesi": tpl.listUnique(", ")
      "Toplam": tpl.sum(frFmt)
      "Toplam (tam sayı)": tpl.sum(frFmtInt)
      "Ortalama": tpl.average(frFmt)
      "Min": tpl.min(frFmt)
      "Maks": tpl.max(frFmt)
      "Miktarların toplamı": tpl.sumOverSum(frFmt)
      "%80 daha yüksek": tpl.sumOverSumBound80(true, frFmt)
      "%80 daha düşük": tpl.sumOverSumBound80(false, frFmt)
      "Toplam oranı (toplam)": tpl.fractionOf(tpl.sum(), "total", frFmtPct)
      "Satır oranı (toplam)": tpl.fractionOf(tpl.sum(), "row", frFmtPct)
      "Sütunun oranı (toplam)": tpl.fractionOf(tpl.sum(), "col", frFmtPct)
      "Toplam oranı (sayı)": tpl.fractionOf(tpl.count(), "total", frFmtPct)
      "Satır oranı (sayı)": tpl.fractionOf(tpl.count(), "row", frFmtPct)
      "Sütunun oranı (sayı)": tpl.fractionOf(tpl.count(), "col", frFmtPct)

    renderers:
      "Tablo": r["Table"]
      "Tablo (Çubuklar)": r["Table Barchart"]
      "İlgi haritası": r["Heatmap"]
      "Satır ilgi haritası": r["Row Heatmap"]
      "Sütun ilgi haritası": r["Col Heatmap"]
  if gcr
    $.pivotUtilities.locales.tr.gchart_renderers =
      "Çizgi Grafiği (gchart)": gcr["Line Chart"]
      "Bar Grafiği (gchart)": gcr["Bar Chart"]
      "Yığılmış Çubuk Grafik (gchart)": gcr["Stacked Bar Chart"]
      "Alan Grafiği (gchart)": gcr["Area Chart"]

  if d3r
    $.pivotUtilities.locales.tr.d3_renderers =
      "Hiyerarşik Alan Grafiği (Treemap)": d3r["Treemap"]

  if c3r
    $.pivotUtilities.locales.tr.c3_renderers =
      "Çizgi Grafiği (C3)": c3r["Line Chart C3"]
      "Bar Grafiği (C3)": c3r["Bar Chart C3"]

  return $.pivotUtilities.locales.tr

