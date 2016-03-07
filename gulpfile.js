var gulp = require('gulp');
var del = require('del');
var coffee = require('gulp-coffee');
var sass = require('gulp-sass');
var run_sequence = require('run-sequence');
var connect = require('gulp-connect');
var watch = require('gulp-watch');
var hash = require('gulp-hash');
var inject = require('gulp-inject');

gulp.task('clean', function(done) {
  return del(['./build'], done);
});

gulp.task('markup', function() {
  var sources = gulp.src(['./build/**/*.js', './build/**/*.css'], {read: false});
  return gulp.src('./src/*.html')
             .pipe(inject(sources, {ignorePath: '/build/'}))
             .pipe(gulp.dest('./build/'));
});

gulp.task('compile', function() {
  return gulp.src('src/script/**/*.coffee')
             .pipe(coffee({bare: true}))
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
  run_sequence('clean', ['compile', 'styles'], 'markup', done);
});

gulp.task('serve', ['build'], function() {
  connect.server({livereload: true, root: './build'});
  gulp.watch("./src/**/*.*", ['build']);
  watch("./build/**/*.*").pipe(connect.reload());
});

gulp.task('default', ['serve']);
