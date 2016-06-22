var gulp = require('gulp'),
    git = require('gulp-git'),
    bump = require('gulp-bump'),
    filter = require('gulp-filter'),
    tag_version = require('gulp-tag-version'),
    runSequence = require('run-sequence').use(gulp),
    spawn = require('child_process').spawn,
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    uglify = require("gulp-uglify"),
    rename = require('gulp-rename'),
    sourcemaps = require('gulp-sourcemaps'),
    concat = require('gulp-concat'),
    minifyCSS = require('gulp-minify-css'),
    serve = require('gulp-serve');

gulp.task('makeCss', function() {
    gulp.src('./dist/pivot.css')
        .pipe(minifyCSS())
        .pipe(concat('pivot.min.css'))//trick to output to new file
        .pipe(gulp.dest('./dist/'))
});


gulp.task('makeJs', function() {
    
    gulp.src(['./*.coffee', './locales/*.coffee'])
        //compile to js (and create map files)
        .pipe(sourcemaps.init())
        .pipe(coffee()).on('error', gutil.log)
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dist'))
        
        //minify js files as well
        .pipe(filter('*.js'))//filter, to avoid doing this processing on the map files generated above 
         .pipe(rename({
            suffix: '.min'
        }))
        .pipe(sourcemaps.init({loadMaps: true}))//load the source maps generated in the first step
        .pipe(uglify())
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dist'));
});



function inc(importance) {
    // get all the files to bump version in
    return gulp.src(['./package.json', './bower.json', './pivottable.jquery.json']) 
        // bump the version number in those files
        .pipe(bump({type: importance}))
        // save it back to filesystem
        .pipe(gulp.dest('./'));
}

gulp.task('publish', function (done) {
  spawn('npm', ['publish'], { stdio: 'inherit' }).on('close', done);
});

gulp.task('push', function (done) {
  git.push('origin', 'master', {args: '--tags'}, function (err) {
    if (err) throw err;
  });
});


gulp.task('tag', function() {
    return gulp.src(['./package.json', './bower.json', './pivottable.jquery.json'])
    .pipe(git.commit('version bump'))
    // read only one file to get the version number
    .pipe(filter('package.json')) 
    .pipe(tag_version());
});


gulp.task('bumpPatch', function() { return inc('patch'); })
gulp.task('bumpMinor', function() { return inc('minor'); })
gulp.task('bumpMajor', function() { return inc('major'); })

gulp.task('patch', function() {
    runSequence('bumpPatch', 'default', 'tag', 'publish', 'push');
});
gulp.task('minor', function() {
    runSequence('bumpMinor', 'default', 'tag', 'publish', 'push');
});
gulp.task('major', function() {
    runSequence('bumpMajor', 'default', 'tag', 'publish', 'push');
});

gulp.task('serve', serve('.'));

gulp.task('watch', function() {
  gulp.watch('./*.coffee', ['makeJs']);
  gulp.watch('./dist/pivot.css', ['makeCss']);
});

gulp.task('default', ['makeJs', 'makeCss']);

