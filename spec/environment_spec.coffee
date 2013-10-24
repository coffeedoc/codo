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
    for filename in walkdir.sync './spec/templates/classes' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Variable', ->
    for filename in walkdir.sync './spec/templates/variables' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Property', ->
    for filename in walkdir.sync './spec/templates/properties' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'File', ->
    it 'parses non-class file', ->
      expect('spec/templates/files/non_class_file.coffee').toTraverseTo(
        'spec/templates/files/non_class_file.json'
      )

  describe 'Mixin', ->
    for filename in walkdir.sync './spec/templates/mixins' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Method', ->
    for filename in walkdir.sync './spec/templates/methods' when filename.match /\.coffee$/
      do (filename) ->
        it "parses #{filename}", ->
          expect(filename.substring process.cwd().length + 1)
            .toTraverseTo(filename.replace(/\.coffee$/, '.json'))

  describe 'Environment', ->
    it 'handles multiple files', ->
      environment = Environment.read [
        'spec/templates/environment/class.coffee',
        'spec/templates/environment/mixin.coffee'
      ]

      actual = JSON.stringify(environment.inspect(), null, 2)
      expect(FS.readFileSync('spec/templates/environment/result.json', 'utf8')).toEqual actual
