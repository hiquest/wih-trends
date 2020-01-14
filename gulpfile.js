// Imports
var gulp = require('gulp');
var del = require('del');
var sass = require('gulp-sass');
var run_sequence = require('run-sequence');
var connect = require('gulp-connect');
var watch = require('gulp-watch');
var hash = require('gulp-hash');
var inject = require('gulp-inject');
var s3 = require("gulp-s3");
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var aws_creds = require('./aws.json');

// Task definitions
gulp.task('clean', function(done) {
  return del(['./build'], done);
});

gulp.task('markup', function() {
  var sources = gulp.src(['./build/**/*.js', './build/**/*.css'], { read: false });
  return gulp.src('./src/*.html')
    .pipe(inject(sources, {ignorePath: '/build/'}))
    .pipe(gulp.dest('./build/'));
});

gulp.task('scripts', function() {
  return gulp.src('src/script/**/*.js')
    .pipe(concat('all.js'))
    .pipe(uglify())
    .pipe(hash())
    .pipe(gulp.dest('./build/js'));
});

gulp.task('styles', function () {
  return gulp.src('./src/styles/**/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(hash())
    .pipe(gulp.dest('./build/css/'));
});

gulp.task('build', function(done) {
  return run_sequence('clean', ['scripts', 'styles'], 'markup', done);
});

gulp.task('serve', ['build'], function() {
  connect.server({livereload: true, root: './build'});
  gulp.watch("./src/**/*.*", ['build']);
  watch("./build/**/*.*").pipe(connect.reload());
});

gulp.task('deploy', ['build'], function() {
  gulp
    .src('./build/**')
    .pipe(s3(aws_creds));
});

gulp.task('default', ['serve']);
