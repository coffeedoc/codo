fs           = require 'fs'
_            = require 'underscore'
_.str        = require 'underscore.string'

CoffeeScript = require 'coffee-script'
Class        = require './nodes/class'

{whitespace} = require('./util/text')

# CoffeeScript parser to convert the files into a
# documentation domain nodes.
#
module.exports = class Parser

  # Construct the parser
  #
  # @param [Object] options the parser options
  #
  constructor: (@options) ->
    @files   = []
    @classes = []

  # Parse the given CoffeeScript file
  #
  # @param [String] file the CoffeeScript file name
  #
  parseFile: (file) ->
    @parseContent fs.readFileSync(file, 'utf8'), file
    @files.push file

  # Parse the given CoffeeScript content
  #
  # @param [String] content the CoffeeScript file content
  # @param [String] file the CoffeeScript file name
  #
  parseContent: (content, file = '') ->
    @previousNodes = []

    tokens = CoffeeScript.nodes(@convertComments(content))
    tokens.traverseChildren true, (child) =>
      if child.constructor.name is 'Class'

        # Check the previous tokens for comment nodes
        previous = @previousNodes[@previousNodes.length-1]
        switch previous?.constructor.name
          # A comment is preveding the class declaration
          when 'Comment'
            doc = previous
          when 'Literal'
            # The class is exported `module.exports = class Class`, take the comment before `module`
            if previous.value is 'exports'
              node = @previousNodes[@previousNodes.length-6]
              doc = node if node.constructor.name is 'Comment'

        @classes.push new Class(child, file, @options, doc)

      @previousNodes.push child
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
                 [@$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*[:=]\s+(\(.*\)\s+[-=]>)?
               | # Constant
                 @[$A-Z_][A-Z_]*)
             ///.exec line

            result.push c for c in comment

          comment = []

        result.push line

    result.join('\n')

  # Get all parsed methods
  #
  # @return [Array<Method>] all methods
  #
  getAllMethods: ->
    unless @methods
      @methods = []

      for clazz in @classes
        @methods = _.union @methods, clazz.getMethods()

    @methods

  # Get all parsed variables
  #
  # @return [Array<Variable>] all variables
  #
  getAllVariables: ->
    unless @variables
      @variables = []

    for clazz in @classes
      @variables = _.union @variables, clazz.getVariables()

    @variables

  # Show the parsing statistics
  #
  showResult: ->
    fileCount      = @files.length

    classCount     = @classes.length
    noDocClasses   = _.filter(@classes, (clazz) -> _.isUndefined clazz.getDoc()).length

    methodCount    = @getAllMethods().length
    noDocMethods   = _.filter(@getAllMethods(), (method) -> _.isUndefined method.getDoc()).length

    constants      = _.filter(@getAllVariables(), (variable) -> variable.isConstant())
    constantCount  = constants.length
    noDocConstants = _.filter(constants, (constant) -> _.isUndefined constant.getDoc()).length

    documented = 100 - 100 / (classCount + methodCount + constantCount) * (noDocClasses + noDocMethods + noDocConstants)

    maxCountLength = String(_.max([fileCount, classCount, methodCount, constantCount], (count) -> String(count).length)).length + 6
    maxNoDocLength = String(_.max([noDocClasses, noDocMethods, noDocConstants], (count) -> String(count).length)).length

    stats =
      """
      Files:     #{ _.str.pad(fileCount, maxCountLength) }
      Classes:   #{ _.str.pad(classCount, maxCountLength) } (#{ _.str.pad(noDocClasses, maxNoDocLength) } undocumented)
      Methods:   #{ _.str.pad(methodCount, maxCountLength) } (#{ _.str.pad(noDocMethods, maxNoDocLength) } undocumented)
      Constants: #{ _.str.pad(constantCount, maxCountLength) } (#{ _.str.pad(noDocConstants, maxNoDocLength) } undocumented)
       #{ _.str.sprintf('%.2f', documented) }% documented
      """

    console.log stats

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json = []

    for clazz in @classes
      json.push clazz.toJSON()

    json
