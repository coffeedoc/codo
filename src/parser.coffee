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
  # @param [String] file the CoffeeScript file
  #
  parse: (file) ->
    content = fs.readFileSync file, 'utf8'

    root = CoffeeScript.nodes(content)
    root.traverseChildren true, (child) =>
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
