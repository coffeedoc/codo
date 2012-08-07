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
  ], cb

task 'publish', 'Prepare build and push new version to NPM', -> publish onerror
