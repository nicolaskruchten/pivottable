fixtureData = [
    ["name",    "gender",   "colour",    "birthday",     "trials",   "successes"],
    ["Nick",    "male",     "blue",      "1982-11-07",   103,        12],
    ["Jane",    "female",   "red",       "1982-11-08",   95,         25],
    ["John",    "male",     "blue",      "1982-12-08",   112,        30],
    ["Carol",   "female",   "yellow",    "1983-12-08",   102,        14]
]


describe "$.pivotUI()", ->
    describe "with no rows/cols, default count aggregator, default TableRenderer",  ->
        table = null

        beforeEach (done) ->
            table = $("<div>").pivotUI fixtureData, onRefresh: done
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

        it "renders a table", (done) ->
            expect table.find("table.pvtTable").length
            .toBe  1 
            done()


        describe "its renderer output", ->
            it "has the correct type and number of cells", (done) ->
                expect table.find("th.pvtTotalLabel").length
                .toBe  1 
                expect table.find("td.pvtGrandTotal").length
                .toBe  1 
                done()

            it "has the correct textual representation", (done) ->
                expect table.find("table.pvtTable").text()
                .toBe ["Totals", "4"].join("")
                done()

            it "has a correct grand total with data value", (done) ->
                expect table.find("td.pvtGrandTotal").text()
                .toBe  "4"
                expect table.find("td.pvtGrandTotal").data("value")
                .toBe  4
                done()

    describe "with rows/cols, sum-over-sum aggregator, Heatmap renderer",  ->
        table = null

        beforeEach (done) ->
            table = $("<div>").pivotUI fixtureData, 
                rows: ["gender"], cols: ["colour"]
                aggregatorName: "Sum over Sum"
                vals: ["successes", "trials"]
                rendererName: "Heatmap"
                onRefresh: done

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

        it "renders a table", (done) ->
            expect table.find("table.pvtTable").length
            .toBe  1 
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

            it "has the correct textual representation", (done) ->
                expect table.find("table.pvtTable").text()
                .toBe [
                    "colour",   "blue", "red",  "yellow",   "Totals",
                    "gender",
                    "female",           "0.26", "0.14",     "0.20",
                    "male",     "0.20",                     "0.20",
                    "Totals",   "0.20", "0.26", "0.14",     "0.20"
                    ].join("")
                done()

            it "has a correct spot-checked cell with data value", (done) ->
                expect table.find("td.col0.row1").text()
                .toBe  "0.20"
                expect table.find("td.col0.row1").data("value")
                .toBe  (12+30)/(103+112)
                done()

describe "$.pivot()", ->

    describe "with no rows/cols, default count aggregator, default TableRenderer",  ->
        table = $("<div>").pivot fixtureData

        it "renders a table", ->
            expect table.find("table.pvtTable").length
            .toBe  1 

        describe "its renderer output", ->

            it "has the correct textual representation", ->
                expect table.find("table.pvtTable").text()
                .toBe ["Totals", "4"].join("")

            it "has a correct grand total with data value", ->
                expect table.find("td.pvtGrandTotal").text()
                .toBe  "4"
                expect table.find("td.pvtGrandTotal").data("value")
                .toBe  4

    describe "with rows/cols, sum aggregator, derivedAttributes, filter and sorters",  ->
        {sortAs, derivers, aggregators} = $.pivotUtilities
        table = $("<div>").pivot fixtureData,
            rows: ["gender"], cols: ["birthyear"], aggregator: aggregators["Sum"](["trialbins"])
            filter: (record) -> record.name != "Nick"
            derivedAttributes:
                birthyear: derivers.dateFormat "birthday", "%y"
                trialbins: derivers.bin "trials", 10
            sorters: (attr) ->
                if attr == "gender" then return sortAs(["male", "female"])

        it "renders a table with the correct textual representation", ->
            expect table.find("table.pvtTable").text()
            .toBe [
                "birthyear",    "1982",     "1983",     "Totals"
                "gender",  
                "male",         "110.00",               "110.00"
                "female",       "90.00",    "100.00",   "190.00"
                "Totals",       "200.00",   "100.00",   "300.00"
                ].join("")

    describe "with rows/cols, fraction-of aggregator",  ->
        {aggregators} = $.pivotUtilities
        table = $("<div>").pivot fixtureData,
            rows: ["gender"]
            aggregator: aggregators["Sum as Fraction of Total"](["trials"])

        it "renders a table with the correct textual representation", ->
            expect table.find("table.pvtTable").text()
            .toBe [
                "gender",  "Totals"
                "female",  "47.8%"
                "male",    "52.2%"
                "Totals",  "100.0%"
                ].join("")

    describe "with rows/cols, custom aggregator, custom renderer with options",  ->
        received_PivotData = null
        received_rendererOptions = null

        table = $("<div>").pivot fixtureData, 
            rows: ["name", "colour"], cols: ["trials", "successes"]
            aggregator: -> 
                count2x: 0
                push: -> @count2x +=2 
                value: -> @count2x
                format: (x) -> "formatted " + x
            renderer: (a,b) -> 
                received_PivotData = a
                received_rendererOptions = b
                return $("<div>").addClass(b.greeting).text("world")
            rendererOptions: {greeting:"hithere"}

        it "renders the custom renderer as per options", ->
            expect table.find("div.hithere").length
            .toBe  1 

        describe "its received PivotData object", ->
            it "has a correct grand total value and format for custom aggregator", ->
                agg = received_PivotData.getAggregator([],[])
                val = agg.value()
                expect(val).toBe 8 
                expect(agg.format(val)).toBe "formatted 8"

describe "$.pivotUtilities", ->

    describe ".PivotData()", ->
        sumOverSumOpts = 
            rows: [], cols: []
            aggregator: $.pivotUtilities.aggregators["Sum over Sum"](["a","b"])
            filter: -> true
            sorters: ->

        describe "with array-of-array input", ->
            aoaInput =  [ ["a","b"], [1,2], [3,4] ]
            pd = new $.pivotUtilities.PivotData aoaInput, sumOverSumOpts

            it "has the correct grand total value", ->
                expect pd.getAggregator([],[]).value()
                .toBe (1+3)/(2+4)

        describe "with array-of-object input", ->
            aosInput =  [ {a:1, b:2}, {a:3, b:4} ]
            pd = new $.pivotUtilities.PivotData aosInput, sumOverSumOpts

            it "has the correct grand total value", ->
                expect pd.getAggregator([],[]).value()
                .toBe (1+3)/(2+4)

        describe "with function input", ->
            functionInput = (record) ->
                record a:1, b:2
                record a:3, b:4
            pd = new $.pivotUtilities.PivotData functionInput, sumOverSumOpts

            it "has the correct grand total value", ->
                expect pd.getAggregator([],[]).value()
                .toBe (1+3)/(2+4)

        describe "with jQuery table element input", ->
            tableInput = $ """
                <table>
                    <thead> 
                        <tr> <th>a</th><th>b</th> </tr>
                    </thead> 
                    <tbody>
                        <tr> <td>1</td> <td>2</td> </tr>
                        <tr> <td>3</td> <td>4</td> </tr>
                    </tbody>
                </table>
                """

            pd = new $.pivotUtilities.PivotData tableInput, sumOverSumOpts

            it "has the correct grand total value", ->
                expect pd.getAggregator([],[]).value()
                .toBe (1+3)/(2+4)


        describe "with rows/cols, no filters/sorters, count aggregator", ->
            pd = new $.pivotUtilities.PivotData fixtureData, 
                rows: ["name", "colour"], 
                cols: ["trials", "successes"],
                aggregator: $.pivotUtilities.aggregators["Count"](),
                filter: -> true
                sorters: ->

            it "has correctly-ordered row keys", ->
                expect pd.getRowKeys()
                .toEqual [ [ 'Carol', 'yellow' ], [ 'Jane', 'red' ], [ 'John', 'blue' ], [ 'Nick', 'blue' ] ]
               
            it "has correctly-ordered col keys", ->
                expect pd.getColKeys()
                .toEqual [ [ 95, 25 ], [ 102, 14 ], [ 103, 12 ], [ 112, 30 ] ]

            it "can be iterated over", ->
                numNotNull = 0
                numNull = 0
                for r in pd.getRowKeys()
                    for c in pd.getColKeys()
                        if pd.getAggregator(r, c).value()?
                            numNotNull++ 
                        else
                            numNull++
                expect numNotNull
                .toBe 4
                expect numNull
                .toBe 12

            it "has a correct spot-checked aggregator", ->
                agg = pd.getAggregator([ 'Carol', 'yellow' ],[ 102, 14 ])
                val = agg.value()
                expect(val).toBe 1 
                expect(agg.format(val)).toBe "1"

            it "has a correct grand total aggregator", ->
                agg = pd.getAggregator([],[])
                val = agg.value()
                expect(val).toBe 4 
                expect(agg.format(val)).toBe "4"

    describe ".naturalSort()", ->
        naturalSort = $.pivotUtilities.naturalSort

        it "sorts numbers", ->
            expect [2,1,3,4,0].sort naturalSort
            .toEqual [0,1,2,3,4]

        it "sorts strings", ->
            expect ['b','a','c','d'].sort naturalSort
            .toEqual ['a','b','c','d']

        it "sorts numbers in strings", ->
            expect ['1','12','2','10','11','112'].sort naturalSort
            .toEqual ['1','2','10','11','12','112']

        it "sorts 0-padded numbers", ->
            expect ['02','01','10','11'].sort naturalSort
            .toEqual ['01','02','10','11']

    describe ".sortAs()", ->
        sortAs = $.pivotUtilities.sortAs

        it "sorts with unknown values sorted at the end", ->
            expect [5,2,3,4,1].sort sortAs([4,3,2])
            .toEqual [4,3,2,1,5]

    describe ".numberFormat()", ->
        numberFormat = $.pivotUtilities.numberFormat

        it "formats numbers", ->
            nf = numberFormat()
            expect nf 1234567.89123456
            .toEqual "1,234,567.89"

        it "formats booleans", ->
            nf = numberFormat()
            expect nf true
            .toEqual "1.00"

        it "formats numbers in strings", ->
            nf = numberFormat()
            expect nf "1234567.89123456"
            .toEqual "1,234,567.89"

        it "doesn't formats strings", ->
            nf = numberFormat()
            expect nf "hi there"
            .toEqual ""

        it "doesn't formats objects", ->
            nf = numberFormat()
            expect nf {a:1}
            .toEqual ""

        it "formats percentages", ->
            nf = numberFormat(scaler: 100, suffix: "%")
            expect nf 0.12345
            .toEqual "12.35%"

        it "adds separators", ->
            nf = numberFormat(thousandsSep: "a", decimalSep: "b")
            expect nf 1234567.89123456
            .toEqual "1a234a567b89"

        it "adds prefixes and suffixes", ->
            nf = numberFormat(prefix: "a", suffix: "b")
            expect nf 1234567.89123456
            .toEqual "a1,234,567.89b"

        it "scales and rounds", ->
            nf = numberFormat(digitsAfterDecimal: 3, scaler: 1000)
            expect nf 1234567.89123456
            .toEqual "1,234,567,891.235"

        it "shows and hides zero", ->
            nf = numberFormat(showZero: true)
            expect nf 0
            .toEqual "0.00"

            nf = numberFormat(showZero: false)
            expect nf 0
            .toEqual ""

    describe ".derivers", ->
        describe ".dateFormat()", ->
            df = $.pivotUtilities.derivers.dateFormat "x", "abc % %% %%% %a %y %m %n %d %w %x %H %M %S", true

            it "formats date objects", ->
                expect df {x: new Date("2015-01-02T23:43:11Z")}
                .toBe 'abc % %% %%% %a 2015 01 Jan 02 Fri 5 23 43 11'

            it "formats input parsed by Date.parse()", ->
                expect df {x: "2015-01-02T23:43:11Z"}
                .toBe 'abc % %% %%% %a 2015 01 Jan 02 Fri 5 23 43 11'

                expect df {x: "bla"}
                .toBe ''

        describe ".bin()", ->
            binner = $.pivotUtilities.derivers.bin "x", 10

            it "bins numbers", ->
                expect binner {x: 11}
                .toBe 10

                expect binner {x: 9}
                .toBe 0

                expect binner {x: 111}
                .toBe 110

            it "bins booleans", ->
                expect binner {x: true}
                .toBe 0

            it "bins negative numbers", ->
                expect binner {x: -12}
                .toBe -10

            it "doesn't bin strings", ->
                expect binner {x: "a"}
                .toBeNaN()

            it "doesn't bin objects", ->
                expect binner {x: {a:1}}
                .toBeNaN()

# todo
# agg templates
# date.parse -> date() ?
# default options for PivotData, including filter