var
gulp       = require('gulp'),
purescript = require('gulp-purescript'),
runSq      = require('run-sequence'),
karma      = require('gulp-karma'),
gulpif     = require('gulp-if'),
concat     = require('gulp-concat'),

libSrc     = ['bower_components/purescript-*/src/**/*.purs',
              'src/**/*.purs'],
src        = ['bower_components/purescript-*/src/**/*.purs',
              'bower_components/chai/chai.js',
              'src/**/*.purs',
              'tests/History.Spec.purs',
              'tests/Main.purs'],
libDest    = {
              path : 'tmp/',
              file : 'lib.js'
             },
dest       = {
              path : 'tmp/',
              file : 'Test.js'
             },
psc        = purescript.psc({
              main        : true,
              output      : dest.file
            }),
karma      = karma({
              configFile  : "./tests/karma.conf.js",
              action      : "run"
            });

gulp.task('build:lib', function(){
  gulp.src(libSrc)
    .pipe(purescript.psc())
    .pipe(concat(libDest.file))
    .pipe(gulp.dest(libDest.path));
});

gulp.task('build:test', function(){
  gulp.src(src)
    .pipe(gulpif(/purs/, psc))
    .pipe(concat(dest.file))
    .pipe(gulp.dest(dest.path));
});

gulp.task('docgen', function(){
  gulp.src("src/**/*.purs")
    .pipe(purescript.docgen())
    .pipe(gulp.dest("docs/README.md"));
});

gulp.task('test:unit',function(){
  setTimeout(function(){
    gulp.src(dest.path+dest.file).pipe(karma);
  }, 2000);
});

gulp.task('test', function(){ runSq('build:test', 'test:unit'); });
