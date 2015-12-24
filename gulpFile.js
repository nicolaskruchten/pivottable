require('require-dir')('./gulp');

var gulp = require('gulp');	

gulp.task('watch', function() {
  gulp.watch('./*.coffee', ['makeJs']);
  gulp.watch('./dist/pivot.css', ['makeCss']);
});

gulp.task('default', ['makeJs', 'makeCss']);

