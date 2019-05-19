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
      tooMany: "(Listelemek için çok fazla)"
      filterResults: "Sonuçları filtrele"
      totals: "Toplam"
      apply: "Uygula"
      cancel: "Kapat"
      vs: "vs"
      by: "ile"

    aggregators:
      "Say": tpl.count(frFmtInt)
      "Benzersiz Değerleri Say": tpl.countUnique(frFmtInt)
      "Benzersiz Değerleri Listele": tpl.listUnique(", ")
      "Toplam": tpl.sum(frFmt)
      "Toplam (Tam Sayı)": tpl.sum(frFmtInt)
      "Ortalama": tpl.average(frFmt)
      "Medyan": tpl.median(frFmt)
      "Varyans (Örneklem)": tpl["var"](1, frFmt)
      "Standart Sapma (Örneklem)": tpl.stdev(1, frFmt)
      "En Az": tpl.min(frFmt)
      "En Çok": tpl.max(frFmt)
      "İlk": tpl.first(frFmt)
      "Son": tpl.last(frFmt)
      "Miktarların Toplamı": tpl.sumOverSum(frFmt)
      "%80 Daha Yüksek": tpl.sumOverSumBound80(true, frFmt)
      "%80 Daha Düşük": tpl.sumOverSumBound80(false, frFmt)
      "Toplam Oranı (Toplam)": tpl.fractionOf(tpl.sum(), "total", frFmtPct)
      "Satır Oranı (Toplam)": tpl.fractionOf(tpl.sum(), "row", frFmtPct)
      "Sütun Oranı (Toplam)": tpl.fractionOf(tpl.sum(), "col", frFmtPct)
      "Toplam Oranı (Say)": tpl.fractionOf(tpl.count(), "total", frFmtPct)
      "Satır Oranı (Say)": tpl.fractionOf(tpl.count(), "row", frFmtPct)
      "Sütun Oranı (Say)": tpl.fractionOf(tpl.count(), "col", frFmtPct)

    renderers:
      "Tablo": r["Table"]
      "Tablo (Çubuklar)": r["Table Barchart"]
      "Sıcaklık Haritası": r["Heatmap"]
      "Sıcaklık Haritası (Satır) ": r["Row Heatmap"]
      "Sıcaklık Haritası (Sütun) ": r["Col Heatmap"]
  if gcr
    $.pivotUtilities.locales.tr.gchart_renderers =
      "Çizgi Grafiği": gcr["Line Chart"]
      "Bar Grafiği": gcr["Bar Chart"]
      "Yığılmış Çubuk Grafik ": gcr["Stacked Bar Chart"]
      "Alan Grafiği": gcr["Area Chart"]

  if d3r
    $.pivotUtilities.locales.tr.d3_renderers =
      "Hiyerarşik Alan Grafiği (Treemap)": d3r["Treemap"]

  if c3r
    $.pivotUtilities.locales.tr.c3_renderers =
      "Çizgi Grafiği": c3r["Line Chart"]
      "Bar Grafiği": c3r["Bar Chart"]
      "Yığılmış Çubuk Grafik ": c3r["Stacked Bar Chart"]
      "Alan Grafiği": c3r["Area Chart"]

  return $.pivotUtilities.locales.tr

