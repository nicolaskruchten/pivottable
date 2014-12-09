require('require-dir')('./gulp');

var gulp = require('gulp');	
gulp.task('default', ['makeJs', 'makeCss']);

