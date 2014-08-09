var 

gulp       = require('gulp'),
purescript = require('gulp-purescript'),
karma      = require('gulp-karma');

gulp.task('default', function(){
  gulp.src(['bower_components/purescript-*/src/**/*.purs',
            'src/History.purs',
            'tests/History.Spec.purs'])
    .pipe(purescript.psc({main : true}))
    .pipe(karma({
      configFile : "tests/karma.conf.js",
      action     : "run"
    }));
});