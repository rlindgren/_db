var gulp = require('gulp')
	, gutil = require('gulp-util')
	, mocha = require('gulp-mocha')
	, mochaPhantom = require('gulp-mocha-phantomjs')
	, coffee = require('gulp-coffee')
	, del = require('del')
	;

chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
expect = chai.expect;
should = chai.should();

gulp.task('clean', function () {
	return del('./.tmp')
});

gulp.task('coffee', function () {
	return gulp.src('./{lib,test}/**/*.coffee')
		.pipe(coffee())
		.on('error', gutil.log)
		.pipe(gulp.dest('./.tmp'));
});

gulp.task('mocha', ['coffee'], function () {
	return gulp.src(['./.tmp/test/**/*.js', '!./.tmp/test/helpers/*.js'])
		.pipe(mocha({
			ui: 'bdd',
			reporter: 'spec'
		}))
		.on('error', gutil.log);
});

gulp.task('mochaPhantom', ['moveSpecRunner', 'coffee'], function () {
	return gulp.src('.tmp/test/specRunner.html')
		.pipe(mochaPhantom({
			ui: 'bdd',
			reporter: 'spec'
		}))
		.on('error', gutil.log);
});

gulp.task('moveSpecRunner', function () {
	return gulp.src('test/specRunner.html').pipe(gulp.dest('.tmp/test'))
})

gulp.task('ci', ['mocha'], function () {
	gulp.watch(['./{test,lib}/**/*.coffee'], ['mocha']);
});

gulp.task('ciWeb', ['clean'], function () {
	gulp.run('mochaPhantom')
	gulp.watch(['./{test,lib}/**/*.coffee'], ['mochaPhantom']);
});