var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var clean = require('gulp-clean');
var docco = require("gulp-docco");

gulp.task('clean', function () {
  return gulp.src(['./lib', './html-docs/**/*.html', './html-docs/**/*.css', './html-docs/**/fonts'], {read: false})
    .pipe(clean());
});

gulp.task('coffee', function () {
  return gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./lib'))
});

gulp.task('generate-docs', function () {
  return gulp.src('./src/*.coffee')
    .pipe(docco())
    .pipe(gulp.dest('./html-docs'))
});

gulp.task('default', ['clean', 'coffee', 'generate-docs']);
