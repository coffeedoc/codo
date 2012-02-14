fs           = require 'fs'

CoffeeScript = require 'coffee-script'
Class        = require './nodes/class'

{whitespace} = require('./util/text')

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
    @parseContent fs.readFileSync(file, 'utf8'), file

  # Parse the given CoffeeScript content
  #
  # @param [String] content the CoffeeScript file content
  # @param [String] file the CoffeeScript file name
  #
  parseContent: (content, file = '') ->
    @previousNode = null

    tokens = CoffeeScript.nodes(@convertComments(content))
    tokens.traverseChildren true, (child) =>
      if child.constructor.name is 'Class'
        doc = @previousNode if @previousNode?.constructor.name is 'Comment'
        @classes.push new Class(child, doc, file)

      @previousNode = child
      true

    tokens

  # Convert the comments to block comments,
  # so they appear in the nodes.
  #
  # @param [String] content the CoffeeScript file content
  #
  convertComments: (content) ->
    result = []
    inComment = false
    indentComment = 0

    for line in content.split('\n')
      if comment = /^(\s*#)\s?(\s*.*)/.exec line
        show = true

        if inComment
          result.push comment[2]
        else
          inComment = true
          indentComment =  comment[1].length - 1

          result.push whitespace(indentComment) + '###'
          result.push comment[2]
      else
        if inComment
          inComment = false
          result.push whitespace(indentComment) + '###'

        result.push line

    result.join('\n')

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json = []

    for clazz in @classes
      json.push clazz.toJSON()

    json
