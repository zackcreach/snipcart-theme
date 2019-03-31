gulp = require 'gulp'
es = require 'event-stream'
sass = require 'gulp-sass'
concat = require 'gulp-concat'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'
autoprefixer = require 'gulp-autoprefixer'
postcss = require 'gulp-postcss'
mqpacker = require 'css-mqpacker'
browserSync = require 'browser-sync'
argv = require('yargs').option('snipcartVersion', {type: 'string'}).argv

themesDir = 'themes'
workingDir = 'themes/base'

sources =
  sass: "#{workingDir}/sass/snipcart.scss"
  compiled: "/Users/zack/Documents/develop/personal/allourformerselves/static/snipcart/snipcart.css"

watch =
  sass: "#{workingDir}/sass/**/*.scss"

getDistDir = (output)->
  version = "2.0"
  dir = './dist/themes'
  if argv.snipcartVersion
    dir = "./dist/themes/#{argv.snipcartVersion}"
  if output
    dir += "/#{output}"
  return dir

gulp.task 'sass', ->
  gulp.src sources.sass
    .pipe(sass().on('error', sass.logError))
    .pipe autoprefixer(cascade: false, browsers: ['> 0.25%'])
    .pipe gulp.dest("/Users/zack/Documents/develop/personal/allourformerselves/static/snipcart")

gulp.task 'min', ['sass'], ->
   gulp.src sources.compiled
    .pipe(postcss([mqpacker]))
    .pipe(minifyCss())
    .pipe(rename({suffix: '.min'}))
    .pipe(gulp.dest("/Users/zack/Documents/develop/personal/allourformerselves/static/snipcart"))

  gulp.src(sources.compiled)
    .pipe(minifyCss())
    .pipe(rename({suffix: '.min'}))
    .pipe(gulp.dest("/Users/zack/Documents/develop/personal/allourformerselves/static/snipcart"))

gulp.task 'watch', ->
  gulp.watch [watch.sass], ['sass']

gulp.task 'sync', ['dev'], ->
  proxy = argv.proxy ? 'snipcart.client/'
  sync = browserSync.create proxy
  sync.init
    port: 3006
    proxy: proxy
    serveStatic: ['.']
    ui:
        port: 3007
  gulp.watch(sources.compiled).on 'change', sync.reload

gulp.task 'dev', ['default', 'watch']
gulp.task 'default', ['sass']
gulp.task 'deploy', ['min'], ->
  gulp.src(["#{themesDir}/**/*", '!**/*.scss', '!**/sass', '!**/styles.css'])
    .pipe(gulp.dest(getDistDir()))