## Issues

[Issues](https://github.com/nicolaskruchten/pivottable/issues/new) are the preferred way to communicate with the author and users of PivotTable.js, rather than private email.

* If you have multiple questions, please create multiple issues
* Please do not add a comment to an existing issue to ask an unrelated question: create a new issue instead
* When creating issue to report a problem, please try to provide a replicable test case (set of steps and/or a URL demonstrating the problem) so that others can help you.

## Pull Requests

[Pull requests](https://help.github.com/articles/using-pull-requests) to this project are very welcome! They are most likely to be merged in if they conform to this project's basic goals, scope and structure:

* If accepted, you agree that your pull-requests will be released to the world under the same license as the rest of the code: the [MIT license](LICENSE.md).
* It's probably best to log an issue (see above) to report a bug or ask how something was meant to be done before jumping in and modifying the code, if only to confirm that there isn't another way to do what you're aiming for, and to increase the odds that your pull request will be merged :)
* Multiple small pull requests which aim to solve clearly-stated problems are preferable to large pull requests which make many unrelated changes
* The code for this project is written in CoffeeScript and thereafter compiled to Javascript, so it would be best to submit modifications to the CoffeeScript source files rather than to the automatically-generated Javascript source files (please reach out if you've made some neat modifications to the Javascript and want help 'porting' back up to the CoffeeScript version). 
  * Releases for this project are built using the Gulp build system, and the resulting build products (located under `dist`) are tested with the Jasmine test suite under `tests`. See the building/test section of the main [ReadMe](https://github.com/nicolaskruchten/pivottable/blob/master/ReadMe.md) for details.
* The aim of this project is to have an extensible core component that fits into a single smallish file ([pivot.coffee](https://github.com/nicolaskruchten/pivottable/blob/master/pivot.coffee)), which depends only on the jQuery and jQueryUI core. If you want to submit changes which depend on other libraries, please submit them as separate 'plugin' files like the Google Chart or D3 renderers.
* This is a cross-browser, client-side library with very little (if any) browser-specific shim code, so please try to submit modifications that work with as many browsers as possible and which don't require any server-side components
