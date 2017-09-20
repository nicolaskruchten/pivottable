(function() {
  var callWithJQuery;

  callWithJQuery = function(pivotModule) {
    if (typeof exports === "object" && typeof module === "object") {
      return pivotModule(require("jquery"));
    } else if (typeof define === "function" && define.amd) {
      return define(["jquery"], pivotModule);
    } else {
      return pivotModule(jQuery);
    }
  };

  callWithJQuery(function($) {
    var c3r, d3r, frFmt, frFmtInt, frFmtPct, gcr, nf, r, tpl;
    nf = $.pivotUtilities.numberFormat;
    tpl = $.pivotUtilities.aggregatorTemplates;
    r = $.pivotUtilities.renderers;
    gcr = $.pivotUtilities.gchart_renderers;
    d3r = $.pivotUtilities.d3_renderers;
    c3r = $.pivotUtilities.c3_renderers;
    frFmt = nf({
      thousandsSep: ".",
      decimalSep: ","
    });
    frFmtInt = nf({
      digitsAfterDecimal: 0,
      thousandsSep: ".",
      decimalSep: ","
    });
    frFmtPct = nf({
      digitsAfterDecimal: 2,
      scaler: 100,
      suffix: "%",
      thousandsSep: ".",
      decimalSep: ","
    });
    $.pivotUtilities.locales.pt = {
      localeStrings: {
        renderError: "Ocorreu um error ao renderizar os resultados da Tabela Dinâmica.",
        computeError: "Ocorreu um error ao computar os resultados da Tabela Dinâmica.",
        uiRenderError: "Ocorreu um error ao renderizar a interface da Tabela Dinâmica.",
        selectAll: "Selecionar Tudo",
        selectNone: "Selecionar Nenhum",
        tooMany: "(demais para listar)",
        filterResults: "Filtrar resultados",
        totals: "Totais",
        apply: "Aplicar",
        cancel: "Cancelar",
        vs: "vs",
        by: "por"
      },
      aggregators: {
        "Contagem": tpl.count(frFmtInt),
        "Contagem de Valores únicos": tpl.countUnique(frFmtInt),
        "Lista de Valores únicos": tpl.listUnique(", "),
        "Soma": tpl.sum(frFmt),
        "Soma de Inteiros": tpl.sum(frFmtInt),
        "Média": tpl.average(frFmt),
        "Mínimo": tpl.min(frFmt),
        "Máximo": tpl.max(frFmt),
        "Primeiro": tpl.first(frFmt),
        "Último": tpl.last(frFmt),
        "Soma sobre Soma": tpl.sumOverSum(frFmt),
        "Limite Superior a 80%": tpl.sumOverSumBound80(true, frFmt),
        "Limite Inferior a 80%": tpl.sumOverSumBound80(false, frFmt),
        "Soma como Fração do Total": tpl.fractionOf(tpl.sum(), "total", frFmtPct),
        "Soma como Fração da Linha": tpl.fractionOf(tpl.sum(), "row", frFmtPct),
        "Soma como Fração da Coluna": tpl.fractionOf(tpl.sum(), "col", frFmtPct),
        "Contagem como Fração do Total": tpl.fractionOf(tpl.count(), "total", frFmtPct),
        "Contagem como Fração da Linha": tpl.fractionOf(tpl.count(), "row", frFmtPct),
        "Contagem como Fração da Coluna": tpl.fractionOf(tpl.count(), "col", frFmtPct)
      },
      renderers: {
        "Tabela": r["Table"],
        "Tabela com Barras": r["Table Barchart"],
        "Mapa de Calor": r["Heatmap"],
        "Mapa de Calor por Linhas": r["Row Heatmap"],
        "Mapa de Calor por Colunas": r["Col Heatmap"]
      }
    };
    if (gcr) {
      $.pivotUtilities.locales.pt.gchart_renderers = {
        "Gráfico de Linhas": gcr["Line Chart"],
        "Gráfico de Barras": gcr["Bar Chart"],
        "Gráfico de Barras Empilhadas": gcr["Stacked Bar Chart"],
        "Gráfico de Área": gcr["Area Chart"]
      };
    }
    if (d3r) {
      $.pivotUtilities.locales.pt.d3_renderers = {
        "Mapa de Árvore": d3r["Treemap"]
      };
    }
    if (c3r) {
      $.pivotUtilities.locales.pt.c3_renderers = {
        "Gráfico de Linhas": c3r["Line Chart"],
        "Gráfico de Barras": c3r["Bar Chart"],
        "Gráfico de Barras Empilhadas": c3r["Stacked Bar Chart"],
        "Gráfico de Área": c3r["Area Chart"]
      };
    }
    return $.pivotUtilities.locales.pt;
  });

}).call(this);

//# sourceMappingURL=pivot.pt.js.map
