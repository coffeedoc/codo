FS          = require 'fs'
walkdir     = require 'walkdir'
Environment = require '../lib/environment'

beforeEach ->
  @addMatchers
    toTraverseTo: (expected) ->
      environment = new Environment
      parser      = environment.read(@actual)

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
