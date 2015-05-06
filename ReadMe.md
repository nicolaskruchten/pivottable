#PivotTable.js

PivotTable.js is a Javascript Pivot Table library with drag'n'drop functionality built on top of jQuery/jQueryUI and originally written in CoffeeScript by [Nicolas Kruchten](http://nicolas.kruchten.com) at [Datacratic](http://datacratic.com). It is available under an MIT license (see bottom of this document).

##What does it do?

PivotTable.js' basic function is to turn a data set into a summary table and then optionally add a true 2-d drag'n'drop UI to allow a user to manipulate this summary table, turning it into a pivot table, very similar to the one found in older versions of Microsoft Excel with a bunch of extra developer-oriented features and some visualization effects. With optional add-ons, the summary table can be rendered various kinds of charts, turning the pivot table into a pivot chart.

##Why is it good?

* lightweight: the core (without chart support) is a single file with less than 1000 LOC of CoffeeScript, compiles down to 6.3kb of Javascript minified and gzipped, depends only on jQuery and jQueryUI's 'sortable'
* works wherever jQuery and jQueryUI work (tested with jQuery 1.8.3 and jQueryUI 1.9.2)
* works acceptably fast in Chrome on commodity hardware up to around a hundred thousand records, depending on the cardinality of the attributes.
* UI is [localizable](https://github.com/nicolaskruchten/pivottable/wiki/Localization)
* layered architecture allows for summary table generation with or without the pivot table UI around it (if you don't use the UI, then there is no dependency on jQueryUI)
* works with common [input formats](https://github.com/nicolaskruchten/pivottable/wiki/Input-Formats)
* [derived attributes](https://github.com/nicolaskruchten/pivottable/wiki/Derived-Attributes) can be created on the fly based on the whole input record by passing in a function
* complex [aggregation functions](https://github.com/nicolaskruchten/pivottable/wiki/Aggregators) can compute values based on the whole input record (e.g. weighted averages)
* built-in support for basic heatmap and bar chart [renderers](https://github.com/nicolaskruchten/pivottable/wiki/Renderers), and optional extra renderers that add [charting or TSV export support](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers)
* extension points allow aggregation functions, table output, UI and visualizations to be tailored to specific applications
* works on mobile devices with jQuery UI Touch Punch


##Where's the demo?

There are lots on the [examples page](http://nicolas.kruchten.com/pivottable/examples/index.html) but here are some good entry points:

* [a simple demo running on the "Canadian Parliament 2012" dataset](http://nicolaskruchten.github.io/pivottable/examples/mps_prepop.html)
* [fully-loaded demo running on the 700+ datasets that ship with R](http://nicolas.kruchten.com/pivottable/examples/rcsvs.html)
* [fully-loaded demo where you provide a CSV file for input](http://nicolaskruchten.github.io/pivottable/examples/fully_loaded.html)

##How do I use the UI?

PivotTable.js implements a pivot table drag'n'drop UI similar to that found in popular spreadsheet programs. You can drag attributes into/out of the row/column areas, and choose a summary function. There is a [step-by-step tutorial](https://github.com/nicolaskruchten/pivottable/wiki/UI-Tutorial) in the wiki but the following animation gives you a taste of the interaction. It's based on the [Canadian Parliament 2012 dataset](https://github.com/nicolaskruchten/pivottable/blob/master/examples/mps.csv).

![image](http://nicolas.kruchten.com/pivottable/images/animation.gif)


##How do I use the code?

You first need to load jQuery and the PivotTable.js scripts (`pivot.min.js` and any plugins or source maps), which can be done the normal way (download the files from the [`dist`](https://github.com/nicolaskruchten/pivottable/tree/master/dist) directory and reference them), or loaded from [CDNJS](https://cdnjs.com/libraries/pivottable), or via [NPM](https://www.npmjs.com/package/pivottable) with `npm install pivottable` or via [Bower](http://bower.io/) with `bower install pivottable`.

There are two main functions provided by PivotTable.js: `pivot()` and `pivotUI()`, both implemented as jQuery plugins, as well as a bunch of helpers and templates.

### `pivot()`

Once you've loaded jQuery and pivot.js, this code ([demo](http://nicolaskruchten.github.io/pivottable/examples/simple.html)):

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

![image](http://nicolaskruchten.github.io/pivottable/images/simple.png)

### `pivotUI()`

A slight change to the code (calling `pivotUI()` instead of `pivot()` ) yields the same table with a drag'n'drop UI around it, so long as you've imported jQueryUI ([demo](http://nicolaskruchten.github.io/pivottable/examples/simple_ui.html)):

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

Note that **`pivot()` and `pivotUI()` take different parameters in general**, even though in the example above we passed the same parameters to both.

See the wiki for [full parameter documentation](https://github.com/nicolaskruchten/pivottable/wiki/Parameters).

## Where is the documentation?

More extensive documentation can be found in the [wiki](https://github.com/nicolaskruchten/pivottable/wiki):

* [Frequently Asked Questions](https://github.com/nicolaskruchten/pivottable/wiki/Frequently-Asked-Questions)
* [Step by step UI Tutorial](https://github.com/nicolaskruchten/pivottable/wiki/UI-Tutorial)
* [Full Parameter Documentation](https://github.com/nicolaskruchten/pivottable/wiki/Parameters)
* [Input Formats](https://github.com/nicolaskruchten/pivottable/wiki/Input-Formats)
* [Aggregators](https://github.com/nicolaskruchten/pivottable/wiki/Aggregators)
* [Renderers](https://github.com/nicolaskruchten/pivottable/wiki/Renderers)
* [Derived Attributes](https://github.com/nicolaskruchten/pivottable/wiki/Derived-Attributes)
* [Localization](https://github.com/nicolaskruchten/pivottable/wiki/Localization)
* [Optional Extra Renderers: Google Charts and D3/C3 Support](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers)
* [Used By](https://github.com/nicolaskruchten/pivottable/wiki/Used-By)

## How can I contribute?

Pull requests are welcome! Here are some [Contribution Guidelines](https://github.com/nicolaskruchten/pivottable/blob/master/CONTRIBUTING.md).

## I have a question, how can I get in touch?

Please first check the [Frequently Asked Questions](https://github.com/nicolaskruchten/pivottable/wiki/Frequently-Asked-Questions) and if you can't find what you're looking for there, or in the [wiki](https://github.com/nicolaskruchten/pivottable/wiki), then please [create a GitHub Issue](https://github.com/nicolaskruchten/pivottable/issues/new). When creating an issue, please try to provide a replicable test case so that others can more easily help you.

##Copyright & Licence (MIT License)

PivotTable.js is © 2012-2013 Nicolas Kruchten, Datacratic, other contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
