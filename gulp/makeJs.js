var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    uglify = require("gulp-uglify"),
    rename = require('gulp-rename'),
    filter = require('gulp-filter'),
    sourcemaps = require('gulp-sourcemaps');

gulp.task('makeJs', function() {
    
    gulp.src('./*.coffee')
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

