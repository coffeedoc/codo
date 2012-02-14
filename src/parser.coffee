fs           = require 'fs'

CoffeeScript = require 'coffee-script'
Class        = require './nodes/class'

# CoffeeScript parser to convert the files into a
# documentation domain nodes.
#
module.exports = class Parser

  # Construct the parser
  #
  constructor: ->
    @classes = []

  # Parse the given CoffeeScript file
  #
  # @param [String] file the CoffeeScript file name
  #
  parseFile: (file) ->
    @parseContent fs.readFileSync(file, 'utf8')

  # Parse the given CoffeeScript content
  #
  # @param [String] content the CoffeeScript file content
  #
  parseContent: (content) ->
    CoffeeScript.nodes(content).traverseChildren true, (child) =>
      @classes.push new Class(child) if child.constructor.name is 'Class'

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json = []

    for clazz in @classes
      json.push clazz.toJSON()

    json
