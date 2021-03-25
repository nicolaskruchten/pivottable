[![npm](https://pivottable.js.org/images/npm.svg)](https://www.npmjs.com/package/pivottable) [![cdnjs](https://pivottable.js.org/images/cdnjs.svg)](https://cdnjs.com/libraries/pivottable) [![tests](https://pivottable.js.org/images/tests.svg)](https://pivottable.js.org/tests/) [![license](https://pivottable.js.org/images/license.svg)](https://github.com/nicolaskruchten/pivottable/blob/master/LICENSE.md)

# PivotTable-Grouping.js

This fork of [PivotTable.js](https://pivottable.js.org/) adds the data grouping capablity, similar to [Subtotal.js](http://nagarajanchinnasamy.com/subtotal/) but made directly in the PivotTable code with the intention of the minimal changes possible. What's more, it introduces `compactLayout` feature to the default `pivotTableRenderer` that arranges the row headers in condensed way.

Working demo can be found here: [PivotTable grouping demo](https://jjagielka.github.io/pivottable-grouping-demo/)

Left image is the default [PivotTable.js](https://pivottable.js.org/) rendering, while right images shows [PivotTable-Grouping.js](https://jjagielka.github.com/pivottable-grouping) with the default _grouping:true_ enabled.

<img src="http://jjagielka.github.io/pivottable-grouping-demo/images/grouping_false.png" width="50%"> <img src="http://jjagielka.github.io/pivottable-grouping-demo/images/grouping_true.png" width="49%">


To enable the `grouping` feature with the default options use:

```javascript
$("#output").pivot(data, {
    grouping: true,
});
```

To control the behaviour set `grouping` as an object:

```javascript
$("#output").pivot(data, {
    grouping: {
        rowGroupBefore: true,     // this is the default value, row grouping above the child rows
        colGroupBefore: false,    // this is the default value, col grouping after the child cols
    }
});
```

By default the `compactLayout` is set when `grouping` is enabled. To switch it off:

```javascript
$("#output").pivot(data, {
    grouping: true,
    renderingOptions: {
        table: {
            compactLayout: false,
        }
    }
});
```
Example page is extended with two samples of default usage of grouping capability (marked with the star).

All other PivotTable.js functionality rest unchanged. (https://github.com/nicolaskruchten/pivottable/)



## Copyright & Licence (MIT License)

PivotTable.js is © 2012-2016 Nicolas Kruchten, Datacratic, other contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
