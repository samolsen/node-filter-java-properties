var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var clean = require('gulp-clean');

gulp.task('clean', function () {
  return gulp.src('./lib', {read: false})
    .pipe(clean());
});

gulp.task('coffee', function () {
  return gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./lib'))
});

gulp.task('default', ['clean', 'coffee']);
