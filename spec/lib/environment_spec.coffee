FS          = require 'fs'
walkdir     = require 'walkdir'
Environment = require '../../lib/environment'

beforeEach ->
  @addMatchers
    toTraverseTo: (expected) ->
      environment = new Environment
      parser      = environment.readCoffee(@actual)

      environment.linkify()

      actual   = JSON.stringify(environment.inspect(), null, 2)
      expected = FS.readFileSync(expected, 'utf8')

      @message = ->
        report = "\n-------------------- CoffeeScript ----------------------\n"
        report += parser.content
        report += "\n------------------- Expected JSON ---------------------\n"
        report += expected
        report += "\n-------------------- Parsed JSON ------------------------\n"
        report += actual
        report += "\n-------------------------------------------------------\n"

      expected == actual

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
      expect('spec/_templates/files/non_class_file.coffee').toTraverseTo(
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

  describe 'Environment', ->
    it 'handles multiple files', ->
      environment = Environment.read [
        'spec/_templates/environment/class.coffee',
        'spec/_templates/environment/mixin.coffee'
      ]

      actual = JSON.stringify(environment.inspect(), null, 2)
      expect(FS.readFileSync('spec/_templates/environment/result.json', 'utf8')).toEqual actual
      expect(Object.keys environment.references).toEqual [ 
        'spec/_templates/environment/class.coffee',
        'spec/_templates/environment/mixin.coffee',
        'Fluffy', 'LookAndFeel', 'LookAndFeel~feel', 'LookAndFeel~look'
      ]