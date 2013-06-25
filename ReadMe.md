#PivotTable.js

PivotTable.js is a Javascript pivot table library built on top of jQuery/jQueryUI and written in CoffeeScript by Nicolas Kruchten at Datacratic.

##What does it do?

PivotTable.js' basic function is to turn a data set into a summary table and then optionally add a drag'n'drop UI to allow a user to manipulate this summary table, turning it into a pivot table.


##Features

* works with common input formats
* layered architecture allows for summary table generation with or without the pivot table UI around it (if you don't use the UI, then there is no dependency on jQueryUI)
* derived columns can be created on the fly based on the whole input row by passing in a function
* complex aggregation functions can compute values based on the whole input row (i.e. weighted averages)
* built-in support for basic heatmap and bar chart visualization
* extension points allow aggregation functions, table output, UI and visualizations to be tailored to specific applications
* works acceptably fast in Chrome on commodity hardware up to hundreds of thousands of rows with a dozen attributes

##Where's the demo?

A demo of PivotTable.js loaded up with a sample dataset of Canadian Members of Parliament as of 2012 can be found here: [PivotTable.js demo](http://nicolaskruchten.github.io/pivottable/mps_prepop.html).

##How do you use the UI?

PivotTable.js implements a pivot table drag'n'drop UI similar to that found in popular spreadsheet programs. You can drag variables into/out of the row/column areas, and choose a summary function. If you choose a summary function that takes an argument, like 'average', you'll have to drag a variable onto the dropdown.

###Initial state of UI with Canadian MP's dataset

![image](http://nicolaskruchten.github.io/pivottable/images/whats_what.png)

###Drag'n'Drop...


![image](http://nicolaskruchten.github.io/pivottable/images/province_x_party_heatmap_instructions.png)

###...for MP counts by Province and Party

![image](http://nicolaskruchten.github.io/pivottable/images/province_x_party_heatmap.png)

###A little more...

![image](http://nicolaskruchten.github.io/pivottable/images/gender_imbalance_instructions.png)


###...for Gender Imbalance by Provice and Party

![image](http://nicolaskruchten.github.io/pivottable/images/gender_imbalance.png)


### Now you do it: Age distribution bar chart by Gender

![image](http://nicolaskruchten.github.io/pivottable/images/gender_age_bins.png)


##How does the code work?

This code ([demo](http://nicolaskruchten.github.io/pivottable/simple.html)):

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

A slight change to the code (calling pivotUI(…) instead of pivot(…) ) yeilds the same table with a drag'n'drop UI around it ([demo](http://nicolaskruchten.github.io/pivottable/simple_ui.html)):

	$("#output").pivotUI(
	    [ 
	        {color: "blue", shape: "circle"}, 
	        {color: "red", shape: "triangle"}
	    ], 
	    { 
	        rows: ["color"], 
	        cols: ["shape"] 
	    }
	);

![image](http://nicolaskruchten.github.io/pivottable/images/simple_ui.png)

###Parameters




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

PivotTable.js is © 2012-2013 Nicolas Kruchten, Datacratic 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.