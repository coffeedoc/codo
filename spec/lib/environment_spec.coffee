FS          = require 'fs'
jsdiff      = require 'diff'
Path        = require 'path'
walkdir     = require 'walkdir'
Environment = require '../../lib/environment'

normalizePathsInObject = (obj) ->
  return if typeof obj is "string"
  if obj.file? then obj.file = Path.normalize obj.file
  for key, val of obj # ['variables', 'methods', 'properties', 'includes', 'container', 'parent', 'extends']
    if Array.isArray val
      val.forEach normalizePathsInObject
    else normalizePathsInObject obj[key]

beforeEach ->
  @addMatchers
    toTraverseTo: (expected) ->
      environment = new Environment
      parser      = environment.readCoffee(@actual)

      environment.linkify()

      actual = JSON.parse JSON.stringify environment.inspect()
      expected = JSON.parse FS.readFileSync(expected, 'utf8')

      expected.forEach (entry) -> normalizePathsInObject entry

      diff = ""
      for part in jsdiff.diffJson(expected, actual)
        if part.added
          diff += part.value.green
        else if part.removed
          diff += part.value.red
        else
          diff += part.value
      diff

      @message = ->
        report = "\n-------------------- CoffeeScript ----------------------\n"
        report += parser.content
        report += "\n--------------------- JSON diff -----------------------\n"
        report += diff
        report += "\n-------------------------------------------------------\n"

      require('deep-eql')(expected, actual)

describe 'Environment', ->

  describe 'Extras', ->
    beforeEach -> @environment = new Environment

    it 'reads plain text', ->
      @environment.readExtra 'spec/_templates/extras/README'
      expect(@environment.allExtras().map (e) -> e.inspect()).toEqual([{
        path: 'spec/_templates/extras/README',
        parsed: '<p>This is a test README</p>'
      }])

    it 'reads markdown', ->
      @environment.readExtra 'spec/_templates/extras/README.md'
      expect(@environment.allExtras().map (e) -> e.inspect()).toEqual([{
        path: 'spec/_templates/extras/README.md',
        parsed: '<h1 id="this-is-a-test-readme">This is a test README</h1><p>We even have some content here. <a href="http://github.com">With links!</a></p><h2 id="and-nested-menus">And nested menus</h2><p>And even more content</p><h3 id="actually-">Actually...</h3><p>I feel terribly sick writing this. It&#39;s like talking to myself.</p>'
        parsed: '<h1 id="this-is-a-test-readme">This is a test README</h1><p>We even have some content here. <a href="http://github.com">With links!</a></p><h2 id="and-nested-menus">And nested menus</h2><p>And even more content</p><h3 id="actually-">Actually...</h3><p>I feel terribly sick writing this. It&#39;s like talking to myself.</p><p><a href="SomeOtherFile.md.html">With relative markdown links too</a></p>'
      }])

  describe 'Class', ->
    for filename in walkdir.sync './spec/_templates/classes' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Variable', ->
    for filename in walkdir.sync './spec/_templates/variables' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Property', ->
    for filename in walkdir.sync './spec/_templates/properties' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'File', ->
    it 'parses non-class file', ->
      expect(Path.normalize 'spec/_templates/files/non_class_file.coffee').toTraverseTo(
        'spec/_templates/files/non_class_file.json'
      )

  describe 'Mixin', ->
    for filename in walkdir.sync './spec/_templates/mixins' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Method', ->
    for filename in walkdir.sync './spec/_templates/methods' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Angular', ->
    for filename in walkdir.sync './spec/_templates/angular' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Environment', ->
    it 'handles multiple files', ->
      environment = Environment.read [
        'spec/_templates/environment/class.coffee',
        'spec/_templates/environment/mixin.coffee'
      ].map Path.normalize

      actual = JSON.stringify(environment.inspect(), null, 2)
      expected = JSON.parse FS.readFileSync 'spec/_templates/environment/result.json', 'utf8'
      expected.forEach normalizePathsInObject
      expected = JSON.stringify expected, null, 2
      expect(actual).toEqual expected
      expect(Object.keys environment.references).toEqual [ 
        'spec/_templates/environment/class.coffee',
        'spec/_templates/environment/mixin.coffee',
        'Fluffy', 'LookAndFeel', 'LookAndFeel~feel', 'LookAndFeel~look'
      ].map Path.normalize