#PivotTable.js

PivotTable.js is a Javascript pivot table library built on top of jQuery/jQueryUI and written in CoffeeScript by Nicolas Kruchten at Datacratic.

##What does it do?

PivotTable.js' basic function is to turn a data set into a summary table and then optionally add a drag'n'drop UI to allow a user to manipulate this summary table, turning it into a pivot table.

##Bare-bones example

This code:

	$("#output").pivot(
	    [ 
	        {color: "blue", shape: "circle"}, 
	        {color: "red", shape: "triangle"}
	    ], 
	    { 
	        rows: ["color"], 
	        cols: ["shape"] 
	    }
	);

appends this table to `$("#output")` (the default, *overridable* behaviour is to populate the table cells with counts):

<table class="pvtTable"><tbody><tr><th colspan="1" rowspan="1"></th><th class="pvtAxisLabel">shape</th><th class="pvtColLabel" colspan="1" rowspan="2">circle</th><th class="pvtColLabel" colspan="1" rowspan="2">triangle</th><th class="pvtTotalLabel" rowspan="2">Totals</th></tr><tr><th class="pvtAxisLabel">color</th><th></th></tr><tr><th class="pvtRowLabel" rowspan="1" colspan="2">blue</th><td class="pvtVal row0 col0">1</td><td class="pvtVal row0 col1"></td><td class="pvtTotal rowTotal">1</td></tr><tr><th class="pvtRowLabel" rowspan="1" colspan="2">red</th><td class="pvtVal row1 col0"></td><td class="pvtVal row1 col1">1</td><td class="pvtTotal rowTotal">1</td></tr><tr><th class="pvtTotalLabel" colspan="2">Totals</th><td class="pvtTotal colTotal">1</td><td class="pvtTotal colTotal">1</td><td class="pvtGrandTotal">2</td></tr></tbody></table>


##Fancy examples

For example, PivotTable.js can turn data like this list of Canadian Members of Parliament:

(data)

into tables like these which summarize the data in various ways (some of these examples show the pivot table UI, click on them to see the code and play with the UI):

(tables)


##How do you use the UI?

PivotTable.js implements a pivot table drag'n'drop UI similar to that found in popular spreadsheet programs:

(how-to image)

##Features

* works with common input formats
* layered architecture allows for summary table generation with or without the pivot table UI around it (if you don't use the UI, then there is no dependency on jQueryUI)
* derived columns can be created on the fly based on the whole input row by passing in a function
* complex aggregation functions can compute values based on the whole input row (i.e. weighted averages)
* built-in support for basic heatmap and bar chart visualization
* extension points allow aggregation functions, table output, UI and visualizations to be tailored to specific applications
* works acceptably fast in Chrome on commodity hardware up to hundreds of thousands of rows with a dozen attributes

##Input Formats


###Arrays of objects

	<script>
		var input = [
			{
				attribute1: value1, 
				attribute2: value2, 
				//...
			},
			{
				attribute1: value1, 
				attribute2: value2, 
				//...
			},
			//...
		];
	</script>

###Simple Tables

	<script>
		var input = $("#input");
	</script>
	
	<table id="input">
		<thead>
			<tr>
				<th>attribute1</th>
				<th>attribute2</th>
				<!-- etc... -->
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>value1</td>
				<td>value2</td>
			</tr>
			<tr>
				<td>value1</td>
				<td>value2</td>
			</tr>
				<!-- etc... -->
		</tbody>
	</table>


##Copyright & Licence

PivotTable.js is © 2012-2013 Datacratic 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.