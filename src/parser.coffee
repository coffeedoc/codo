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
    result        = []
    comment       = []
    inComment     = false
    indentComment = 0

    for line in content.split('\n')
      if commentLine = /^(\s*#)\s?(\s*.*)/.exec line
        show = true

        if inComment
          comment.push commentLine[2]
        else
          inComment = true
          indentComment =  commentLine[1].length - 1

          comment.push whitespace(indentComment) + '###'
          comment.push commentLine[2]
      else
        if inComment
          inComment = false
          comment.push whitespace(indentComment) + '###'

          # Push here comments only before certain lines
          if ///
               ( # Class
                 class\s*[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*
               | # Function
                 [$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*:\s+(\(.*\)\s+[-=]>)?
               | # Constant
                 @[$A-Z_][A-Z_]*)
             ///.exec line

            result.push c for c in comment

          comment = []

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
