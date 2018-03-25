[![npm](https://pivottable.js.org/images/npm.svg)](https://www.npmjs.com/package/pivottable) [![cdnjs](https://pivottable.js.org/images/cdnjs.svg)](https://cdnjs.com/libraries/pivottable) [![tests](https://pivottable.js.org/images/tests.svg)](https://pivottable.js.org/tests/) [![license](https://pivottable.js.org/images/license.svg)](https://github.com/nicolaskruchten/pivottable/blob/master/LICENSE.md)


# PivotTable.js

PivotTable.js is a Javascript Pivot Table library with drag'n'drop functionality built on top of jQuery/jQueryUI and originally written in CoffeeScript by [Nicolas Kruchten](http://nicolas.kruchten.com).

It is available under an MIT license from [CDNJS](https://cdnjs.com/libraries/pivottable) and [NPM](https://www.npmjs.com/package/pivottable) and [Bower](http://bower.io/) under the name `pivottable`. And on [Packagist.org](https://packagist.org/packages/nicolaskruchten/pivottable), it is `nicolaskruchten/pivottable`.

PivotTable.js can be used with [Python/Jupyter](https://github.com/nicolaskruchten/jupyter_pivottablejs) and [R/RStudio](https://github.com/smartinsightsfromdata/rpivotTable) and you can [try it right now](https://pivottable.js.org/examples/local.html) in your browser on a CSV file.

**Are you using React? Check out the React port: [react-pivottable](https://github.com/plotly/react-pivottable).**

## What does it do?

PivotTable.js' basic function is to enable data exploration and analysis by turning a data set into a summary table and then optionally adding a true 2-d drag'n'drop UI to allow a user to manipulate this summary table, turning it into a pivot table, very similar to the one found in older versions of Microsoft Excel with a bunch of extra developer-oriented features and some visualization effects. With [optional add-ons](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers), the summary table can be rendered as various kinds of charts, turning the pivot table into a pivot chart.

![image](https://pivottable.js.org/images/animation.gif)

The animation above is based on the [Canadian Parliament 2012 dataset example](https://pivottable.js.org/examples/fully_loaded.html).

## Where are the demos/examples?

There are lots on the [examples page](https://pivottable.js.org/examples/index.html) but here are some good entry points:

* [a JSFiddle where you can play with the code](https://jsfiddle.net/nicolaskruchten/kn381h7s/)
* [a simple demo running on the "Canadian Parliament 2012" dataset](http://nicolaskruchten.github.io/pivottable/examples/mps_prepop.html)
* [fully-loaded demo running on the 700+ datasets that ship with R](https://pivottable.js.org/examples/rcsvs.html)
* [fully-loaded demo where you provide your own CSV file for input](https://pivottable.js.org/examples/local.html)

## Why is it good?

* it's lightweight: the core (without chart support) is a single file with less than 1000 LOC of CoffeeScript, compiles down to 6.3kb of Javascript minified and gzipped, and depends only on jQuery and jQueryUI's 'sortable'
* it works wherever jQuery and jQueryUI work (tested with jQuery 1.8.3 and jQueryUI 1.9.2)
* it works acceptably fast in Chrome on commodity hardware up to around a hundred thousand records, depending on the cardinality of the attributes.
* its UI is [localizable](https://github.com/nicolaskruchten/pivottable/wiki/Localization)
* its layered architecture allows for summary table generation with or without the pivot table UI around it (if you don't use the UI, then there is no dependency on jQueryUI)
* it works with common [input formats](https://github.com/nicolaskruchten/pivottable/wiki/Input-Formats)
* its [derived attributes](https://github.com/nicolaskruchten/pivottable/wiki/Derived-Attributes) can be created on the fly based on the whole input record by passing in a function
* its complex [aggregation functions](https://github.com/nicolaskruchten/pivottable/wiki/Aggregators) can compute values based on the whole input record (e.g. weighted averages)
* it has built-in support for basic heatmap and bar chart [renderers](https://github.com/nicolaskruchten/pivottable/wiki/Renderers), and [optional extra renderers that add charting or TSV export support](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers)
* its extension points allow aggregation functions, table output, UI and visualizations to be tailored to specific applications
* it works on mobile devices with [jQuery UI Touch Punch](http://touchpunch.furf.com/)
* it has a [test suite](https://pivottable.js.org/tests)

## How do I use the UI?

PivotTable.js implements a pivot table drag'n'drop UI similar to that found in popular spreadsheet programs. You can drag attributes into/out of the row/column areas, and specify rendering, aggregation and filtering options. There is a [step-by-step tutorial](https://github.com/nicolaskruchten/pivottable/wiki/UI-Tutorial) in the wiki.

## How do I load the code?

PivotTable.js implements the [Universal Module Definition (UMD)](https://github.com/umdjs/umd) pattern and so should be compatible with most approaches to script loading and dependency management: direct script loading i.e. from [CDNJS](https://cdnjs.com/libraries/pivottable) or with [RequireJS](http://requirejs.org/), [Browserify](http://browserify.org/) etc. For the latter options, you can grab it from [NPM](https://www.npmjs.com/package/pivottable) with `npm install pivottable` or via [Bower](http://bower.io/) with `bower install pivottable`.

If you are loading the scripts directly (as in the [examples](https://pivottable.js.org)), you need to:

1. load the dependencies:
  1. jQuery in all cases
  2. jQueryUI for the interactive `pivotUI()` function (see below)
  3. D3.js, C3.js and/or Google Charts if you use [charting plugins](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers)
2. load the PivotTable.js files:
  1. `pivot.min.js`
  2. any [plugins](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers) you wish to use

The dependencies and PivotTable.js files can be loaded:

  1. By copying the files from their official distributions to your project and loading them locally (the [`dist`](https://github.com/nicolaskruchten/pivottable/tree/master/dist) directory is where you will find the PivotTable.js files)
  2. From a Content Distribution Network (CDN) like [CDNJS](https://cdnjs.com/libraries/pivottable)

(The [examples](https://pivottable.js.org) load dependencies from CDNJS and PivotTable.js locally)

## How do I use the code?

There are two main functions provided by PivotTable.js: `pivot()` and `pivotUI()`, both implemented as jQuery plugins, as well as a bunch of helpers and templates.

### `pivot()`

Once you've loaded jQuery and pivot.js, this code ([demo](http://nicolaskruchten.github.io/pivottable/examples/simple.html)):

```javascript
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
```

appends this table to `$("#output")` (the default, *overridable* behaviour is to populate the table cells with counts):

![image](http://nicolaskruchten.github.io/pivottable/images/simple.png)

### `pivotUI()`

A slight change to the code (calling `pivotUI()` instead of `pivot()` ) yields the same table with a drag'n'drop UI around it, so long as you've imported jQueryUI ([demo](http://nicolaskruchten.github.io/pivottable/examples/simple_ui.html)):

```javascript
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
```

![image](http://nicolaskruchten.github.io/pivottable/images/simple_ui.png)

Note that **`pivot()` and `pivotUI()` take different parameters in general**, even though in the example above we passed the same parameters to both. See the [FAQ](https://github.com/nicolaskruchten/pivottable/wiki/Frequently-Asked-Questions#params).

See the wiki for [full parameter documentation](https://github.com/nicolaskruchten/pivottable/wiki/Parameters).

## Where is the documentation?

More extensive documentation can be found in the [wiki](https://github.com/nicolaskruchten/pivottable/wiki):

* [Frequently Asked Questions](https://github.com/nicolaskruchten/pivottable/wiki/Frequently-Asked-Questions)
* [Full Parameter Documentation](https://github.com/nicolaskruchten/pivottable/wiki/Parameters)
* [Input Formats](https://github.com/nicolaskruchten/pivottable/wiki/Input-Formats)
* [Aggregators](https://github.com/nicolaskruchten/pivottable/wiki/Aggregators)
* [Renderers](https://github.com/nicolaskruchten/pivottable/wiki/Renderers)
* [Derived Attributes](https://github.com/nicolaskruchten/pivottable/wiki/Derived-Attributes)
* [Localization](https://github.com/nicolaskruchten/pivottable/wiki/Localization)
* [Optional Extra Renderers: Charting and Exporting](https://github.com/nicolaskruchten/pivottable/wiki/Optional-Extra-Renderers)
* [Used By](https://github.com/nicolaskruchten/pivottable/wiki/Used-By)

## How can I build the code and run the tests?

To install the development dependencies, just run `npm install`, which will create a `node_modules` directory with the files required to run the [Gulp](http://gulpjs.com/) build system.

After modifying any of the `.coffee` files at the top of the repo, you can compile/minify the files into the `dist` directory by running `node_modules/gulp/bin/gulp.js`

Once that's done, you can point your browser to `tests/index.html` to run the [Jasmine](http://jasmine.github.io/) test suite. You can view the [current test results here](https://pivottable.js.org/tests).

The easiest way to modify the code and work with the examples is to leave a `node_modules/gulp/bin/gulp.js watch serve` command running, which will automatically compile the CoffeeScript files when they are modified and will also run a local web server you can connect to to run the tests and examples.

## How can I contribute?

Pull requests are welcome! Here are some [Contribution Guidelines](https://github.com/nicolaskruchten/pivottable/blob/master/CONTRIBUTING.md).

## I have a question, how can I get in touch?

Please first check the [Frequently Asked Questions](https://github.com/nicolaskruchten/pivottable/wiki/Frequently-Asked-Questions) and if you can't find what you're looking for there, or in the [wiki](https://github.com/nicolaskruchten/pivottable/wiki), then please [create a GitHub Issue](https://github.com/nicolaskruchten/pivottable/issues/new). When creating an issue, please try to provide a replicable test case so that others can more easily help you. Please do not email the author directly, as you will just be asked to create a Github Issue :)

## Copyright & Licence (MIT License)

PivotTable.js is © 2012-2016 Nicolas Kruchten, Datacratic, other contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
