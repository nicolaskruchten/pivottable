fixtureData = [
    ["name",    "gender",   "colour",    "birthday",     "trials",   "successes"],
    ["Nick",    "male",     "blue",      "1982-11-07",   103,        12],
    ["Jane",    "female",   "red",       "1982-11-08",   95,         25],
    ["John",    "male",     "blue",      "1982-12-08",   112,        30],
    ["Carol",   "female",   "yellow",    "1983-12-08",   102,        14]
]

describe "pivot() with no rows/cols, default count aggregator, default TableRenderer",  ->
    table = $("<div>").pivot fixtureData

    it "loads a table", ->
        expect table.find("table.pvtTable").length
        .toBe  1 

    it "has a correct grand total with data value", ->
        expect table.find("td.pvtGrandTotal").text()
        .toBe  "4"
        expect table.find("td.pvtGrandTotal").data("value")
        .toBe  4

describe "pivotUI() with no rows/cols, default count aggregator, default TableRenderer",  ->
    table = null

    beforeEach (done) ->
        table = $("<div>").pivotUI fixtureData, onRefresh: done

    it "loads a table", (done) ->
        expect table.find("table.pvtTable").length
        .toBe  1 
        done()

    it "has all the basic UI elements", (done) ->
        expect table.find("td.pvtAxisContainer").length
        .toBe  3
        expect table.find("td.pvtRendererArea").length
        .toBe  1
        expect table.find("td.pvtVals").length
        .toBe  1
        expect table.find("select.pvtRenderer").length
        .toBe  1
        expect table.find("select.pvtAggregator").length
        .toBe  1
        expect table.find("span.pvtAttr").length
        .toBe  6
        done()

    it "reflects its inputs", (done) ->
        expect table.find("td.pvtUnused span.pvtAttr").length
        .toBe  6
        expect table.find("select.pvtRenderer").val()
        .toBe  "Table"
        expect table.find("select.pvtAggregator").val()
        .toBe  "Count"
        done()

    describe "its renderer output", ->
        it "has the correct type and number of cells", (done) ->
            expect table.find("th.pvtTotalLabel").length
            .toBe  1 
            expect table.find("td.pvtGrandTotal").length
            .toBe  1 
            done()

        it "has a correct grand total with data value", (done) ->
            expect table.find("td.pvtGrandTotal").text()
            .toBe  "4"
            expect table.find("td.pvtGrandTotal").data("value")
            .toBe  4
            done()

describe "pivotUI() with specified rows/cols, sum-over-sum aggregator, Heatmap renderer",  ->
    table = null

    beforeEach (done) ->
        pivotOptions = 
            rows: ["gender"], cols: ["colour"]
            aggregatorName: "Sum over Sum"
            vals: ["successes", "trials"]
            rendererName: "Heatmap"
            onRefresh: done
        table = $("<div>").pivotUI fixtureData, pivotOptions

    it "loads a table", (done) ->
        expect table.find("table.pvtTable").length
        .toBe  1 
        done()


    it "has all the basic UI elements", (done) ->
        expect table.find("td.pvtAxisContainer").length
        .toBe  3
        expect table.find("td.pvtRendererArea").length
        .toBe  1
        expect table.find("td.pvtVals").length
        .toBe  1
        expect table.find("select.pvtRenderer").length
        .toBe  1
        expect table.find("select.pvtAggregator").length
        .toBe  1
        expect table.find("span.pvtAttr").length
        .toBe  6
        done()

    it "reflects its inputs", (done) ->
        expect table.find("td.pvtUnused span.pvtAttr").length
        .toBe  4
        expect table.find("td.pvtRows span.pvtAttr").length
        .toBe  1
        expect table.find("td.pvtCols span.pvtAttr").length
        .toBe  1
        expect table.find("select.pvtRenderer").val()
        .toBe  "Heatmap"
        expect table.find("select.pvtAggregator").val()
        .toBe  "Sum over Sum"
        done()

    describe "its renderer output", ->
        it "has the correct type and number of cells", (done) ->
            expect table.find("th.pvtAxisLabel").length
            .toBe  2 
            expect table.find("th.pvtRowLabel").length
            .toBe  2 
            expect table.find("th.pvtColLabel").length
            .toBe  3 
            expect table.find("th.pvtTotalLabel").length
            .toBe  2 
            expect table.find("td.pvtVal").length
            .toBe  6 
            expect table.find("td.pvtTotal").length
            .toBe  5 
            expect table.find("td.pvtGrandTotal").length
            .toBe  1 
            done()

        it "has a correct grand total with data value", (done) ->
            expect table.find("td.pvtGrandTotal").text()
            .toBe  "0.20"
            expect table.find("td.pvtGrandTotal").data("value")
            .toBe  (12+25+30+14)/(103+95+112+102)
            done()

describe "custom renderer passed to pivot() with no rows/cols, custom aggregator",  ->
    received_PivotData = null
    received_rendererOptions = null
    pivotOptions =
        aggregator: -> 
            count2x: 0
            push: -> @count2x +=2 
            value: -> @count2x
            format: (x) -> "formatted " + x
            label: "Count 2x"
        renderer: (a,b) -> 
            received_PivotData = a
            received_rendererOptions = b
            return $("<div>").addClass("hello").text("world")
        rendererOptions: {a:1}
    table = $("<div>").pivot fixtureData, pivotOptions

    it "is rendered", ->
        expect table.find("div.hello").length
        .toBe  1 

    it "receives a PivotData object and options", ->
        expect(received_PivotData).not.toBe  null 
        expect(received_rendererOptions).toEqual {a: 1} 

    describe "its PivotData object", ->
        it "has a correct grand total value and format for custom aggregator", ->
            agg = received_PivotData.getAggregator([],[])
            val = agg.value()
            expect(agg.label).toBe "Count 2x" 
            expect(val).toBe 8 
            expect(agg.format(val)).toBe "formatted 8"

# TODO
# natural sort
# number format
# derivers: binning and date formatting
# locales
# sorters
# filters
# input types
