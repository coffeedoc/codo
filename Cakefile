# Taken from https://github.com/cjoudrey/typhoon/blob/master/Cakefile and adapted to Codo

{exec}   = require 'child_process'
{series} = require 'async'
fs       = require 'fs'

process.env['PATH'] = "node_modules/.bin:#{ process.env['PATH'] }"

bold  = '\x1b[0;1m'
red   = '\x1b[0;31m'
green = '\x1b[0;32m'
reset = '\x1b[0m'

log = (message, color = green) -> console.log "#{ color }#{ message }#{ reset }"

onerror = (err) ->
  if err
    process.stdout.write "#{ red }#{ err.stack }#{ reset }\n"
    process.exit -1

test = (cb) ->
  exec 'jasmine-node --coffee spec', (err, stdout, stderr) ->
    msg = /(\d+) tests?, (\d+) assertions?, (\d+) failures?/
    matches = stdout.match msg || stderr.match msg
    cb new Error('Tests failed') if matches[3] != '0'
    log matches[0]
    cb err

task 'test', 'Run all tests', -> test onerror

generateGHPages = (cb) ->
  cloneGHPages = (cb) ->
    log "Clone gh-pages"
    exec 'git clone git@github.com:netzpirat/codo.git -b gh-pages /tmp/codoc', (err, stdout, stderr) ->
      onerror err
      log stdout
      cb err

  generateDocs = (cb) ->
    log "Generacte codo documentation"
    exec './bin/codo -o /tmp/codoc', (err, stdout, stderr) ->
      onerror err
      log stdout
      cb err

  pushDocs = (cb) ->
    log "Push site"
    exec 'cd /tmp/codoc && git add * . && git commit -am "Update docs to latest version." && git push origin gh-pages', (err, stdout, stderr) ->
      onerror err
      log stdout
      cb err

  cleanUp = (cb) ->
    exec 'rm -rf /tmp/codoc', (err, stdout, stderr) ->
      onerror err
      log "Done."
      cb err

  series [
    cloneGHPages
    generateDocs
    pushDocs
    cleanUp
  ]

task 'pages', 'Generate the Codo docs and push it to GitHub pages', -> generateGHPages onerror

publish = (cb) ->
  npmPublish = (cb) ->
    log 'Publishing to NPM'
    exec 'npm publish', (err, stdout, stderr) ->
      log stdout
      cb err

  tagVersion = (cb) ->
    fs.readFile 'package.json', 'utf8', (err, p) ->
      onerror err
      p = JSON.parse p
      throw new Exception 'Invalid package.json' if !p.version
      log "Tagging v#{ p.version }"
      exec "git tag v#{ p.version }", (err, stdout, stderr) ->
        log stdout
        cb err

  pushGithub = (cb) ->
    exec 'git push --tag origin master', (err, stdout, stderr) ->
      log stdout
      cb err

  series [
    test
    tagVersion
    pushGithub
    npmPublish
    generateGHPages
  ], cb

task 'publish', 'Prepare build and push new version to NPM', -> publish onerror
