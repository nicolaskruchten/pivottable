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

    it "has a correct grand total with data value", (done) ->
        expect table.find("td.pvtGrandTotal").text()
        .toBe  "4"
        expect table.find("td.pvtGrandTotal").data("value")
        .toBe  4
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
            return $("<div>")
        rendererOptions: {a:1}
    $("<div>").pivot fixtureData, pivotOptions

    it "receives a PivotData object and options", ->
        expect(received_PivotData).not.toBe  null 
        expect(received_rendererOptions).toEqual {a: 1} 

    describe "received PivotData object", ->
        it "has a correct grand total value and format for custom aggregator", ->
            agg = received_PivotData.getAggregator([],[])
            val = agg.value()
            expect(agg.label).toBe "Count 2x" 
            expect(val).toBe 8 
            expect(agg.format(val)).toBe "formatted 8"
