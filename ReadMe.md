#PivotTable.js

PivotTable.js is a Javascript Pivot Table library with drag'n'drop functionality built on top of jQuery/jQueryUI and originally written in CoffeeScript by [Nicolas Kruchten](http://nicolas.kruchten.com) at [Datacratic](http://datacratic.com). It is available under an MIT license (see bottom of this document).

##What does it do?

PivotTable.js' basic function is to turn a data set into a summary table and then optionally add a true 2-d drag'n'drop UI to allow a user to manipulate this summary table, turning it into a pivot table, very similar to the one found in older versions of Microsoft Excel with a bunch of extra developer-oriented features and some visualization effects. 

With an optional add-on, the summary table can be rendered as a Google Chart, turning the pivot table into a pivot chart. A d3-based Treemap add-on is also included.

##Why is it good?

* lightweight: the core (without Google Charts or D3 support) is a single file with less than 1000 LOC of CoffeeScript, compiles down to 6.3kb of Javascript minified and gzipped, depends only on jQuery and jQueryUI's 'sortable'
* works wherever jQuery and jQueryUI work (tested with jQuery 1.8.3 and jQueryUI 1.9.2)
* works acceptably fast in Chrome on commodity hardware up to around a hundred thousand records, depending on the cardinality of the attributes.
* layered architecture allows for summary table generation with or without the pivot table UI around it (if you don't use the UI, then there is no dependency on jQueryUI)
* works with common [input formats](https://github.com/nicolaskruchten/pivottable/wiki/Input-Formats)
* [derived attributes](https://github.com/nicolaskruchten/pivottable/wiki/Derived-Attributes) can be created on the fly based on the whole input record by passing in a function
* complex [aggregation functions](https://github.com/nicolaskruchten/pivottable/wiki/Aggregators) can compute values based on the whole input record (i.e. weighted averages)
* built-in support for basic heatmap and bar chart [renderers](https://github.com/nicolaskruchten/pivottable/wiki/Renderers), and optional support for [Google Charts](https://github.com/nicolaskruchten/pivottable/wiki/Google-Chart-support)
* extension points allow aggregation functions, table output, UI and visualizations to be tailored to specific applications
* works on mobile devices with jQuery UI Touch Punch


##Where's the demo?

A demo of PivotTable.js loaded up with a sample dataset of Canadian Members of Parliament as of 2012 can be found here: [PivotTable.js demo](http://nicolaskruchten.github.io/pivottable/examples/mps_prepop.html). 

A version of this demo which include Google Chart renderers can be found here: [Google Charts demo](http://nicolaskruchten.github.io/pivottable/examples/gchart.html).

A fully-loaded version with all renderers and jQuery UI Touch Punch for mobile compatibility is here: [Fully Loaded demo](http://nicolaskruchten.github.io/pivottable/examples/fully_loaded.html).

Finally, here is a demo where you can view your own data from a local CSV file, all in-browser with no server support: [Local CSV demo](http://nicolaskruchten.github.io/pivottable/examples/local.html).

##How do I use the UI?

PivotTable.js implements a pivot table drag'n'drop UI similar to that found in popular spreadsheet programs. You can drag attributes into/out of the row/column areas, and choose a summary function. If you choose a summary function that takes an argument, like 'average', you'll have to drag a attribute onto the dropdown. 
There is a [step-by-step tutorial](https://github.com/nicolaskruchten/pivottable/wiki/UI-Tutorial) in the wiki but the following animation gives you a taste of the interaction. It's based on the Canadian Parliament 2012 dataset.

![image](http://nicolaskruchten.github.io/pivottable/images/animation.gif)


##How do I use the code?

There are two main functions defined in `pivot.coffee`: `pivot()` and `pivotUI()`, both implemented as jQuery plugins, as well as a bunch of helpers and templates.

Despite the fact that this is described as a Javascript library, it's actually written in [CoffeeScript](http://coffeescript.org). You can compile `pivot.coffee` into `pivot.js` with `coffee -c pivot.coffee` or you can use the precompiled JS file from the `examples` directory.

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

A slight change to the code (calling `pivotUI()` instead of `pivot()` ) yeilds the same table with a drag'n'drop UI around it, so long as you've imported jQueryUI ([demo](http://nicolaskruchten.github.io/pivottable/examples/simple_ui.html)):

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
* [Google Charts Support](https://github.com/nicolaskruchten/pivottable/wiki/Google-Chart-support)
* [Used By](https://github.com/nicolaskruchten/pivottable/wiki/Used-By)

## How can I contribute?

Pull requests are welcome! Here are some [Contribution Guidelines](https://github.com/nicolaskruchten/pivottable/wiki/Contribution-Guidelines).

## I have a question, how can I get in touch?

Please [create a GitHub Issue](https://github.com/nicolaskruchten/pivottable/issues/new) if the documentation here or in the [FAQ](https://github.com/nicolaskruchten/pivottable/wiki/Frequently-Asked-Questions) or elsewhere on the [wiki](https://github.com/nicolaskruchten/pivottable/wiki) doesn't answer your question!


##Copyright & Licence (MIT License)

PivotTable.js is © 2012-2013 Nicolas Kruchten, Datacratic, other contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
