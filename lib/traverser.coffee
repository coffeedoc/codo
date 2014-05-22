FS            = require 'fs'
_             = require 'underscore'
_.str         = require 'underscore.string'
CoffeeScript  = require 'coffee-script'
Environment   = require './environment'
Documentation = require './documentation'
File          = require './entities/file'

#
# The class takes CS nodes tree and recursively injects
# additional meta-data into it:
#
#   1. For each possible node it tries every registered
#      entity and pushes an instance of it into tree if it suites.
#   2. For every suitable node it finds the suitable comment block
#      respecting things like `this.` and `module.exports =` and
#      links it to the tree as well.
#
# Since the transformation is happening upside down, nested entities
# can interact with initialized parents (for instance a class can find
# parent class; method can find the class/mixin/file it belongs to).
#
module.exports = class Traverser

  @read: (file, environment) ->
    content = FS.readFileSync(file, 'utf8')
    content = @convertComments(content, environment.options.closure) unless environment.options.cautios

    new @(file, content, environment)

  # Attach each parent to its children, so we are able
  # to traverse the ancestor parse tree. Since the
  # parent attribute is already used in the class node,
  # the parent is stored as `ancestor`.
  #
  # @param [Base] nodes the CoffeeScript nodes
  #
  @linkAncestors: (node) ->
    node.eachChild (child) =>
      child.ancestor = node
      @linkAncestors child

    node

  # Convert the comments to block comments,
  # so they appear in the nodes.
  #
  # The methods replaces starting # symbols with invisible
  # unicode whitespace to keep empty lines formatted.
  #
  # @param [String] content the CoffeeScript file content
  #
  @convertComments: (content, closure=false) ->
    result         = []
    comment        = []
    inComment      = false
    inBlockComment = false
    indentComment  = 0

    for line in content.split('\n')

      blockComment = /^\s*#{3}/.exec(line) && !/^\s*#{3}.+#{3}/.exec(line)

      if blockComment || inBlockComment
        line = line.replace /#{3}\*/, "###" if closure
        inBlockComment = !inBlockComment if blockComment
        result.push line
      else
        commentLine = /^(\s*#)\s?(\s*.*)/.exec(line)
        if commentLine
          if inComment
            comment.push @whitespace(indentComment) + commentLine[2]?.replace /#/g, "\u0091#"
          else
            inComment = true
            indentComment =  commentLine[1].length - 1

            comment.push @whitespace(indentComment) + '###'
            comment.push @whitespace(indentComment) + commentLine[2]?.replace /#/g, "\u0091#"
        else
          if inComment
            inComment = false
            comment.push @whitespace(indentComment) + '###'

            # Push here comments only before certain lines
            if ///
                 ( # class Foo
                   class\s*@?[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*
                 | # variable =
                   ^\s*[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff.]*\s+\=
                 | # method: ->
                   (?:[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*|["'].*["'])\s*:\s*(\(.*\)\s*)?[-=]>
                 | # @method = ->
                   @[A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*=\s*(\(.*\)\s*)?[-=]>
                 | # CONSTANT
                   ^\s*@[$A-Z_][A-Z_]*
                 | # property:
                   ^\s*[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*:
                 | # @property 'foo'
                   @[A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s+['"].+['"]
                 )
               ///.exec line

              result.push c for c in comment

            comment = []

          result.push line

    result.join('\n')

  # Whitespace helper function
  #
  # @param [Number] n the number of spaces
  # @return [String] the space string
  #
  @whitespace: (n) ->
    a = []
    while a.length < n
      a.push ' '
    a.join ''

  constructor: (@path, @content, @environment) ->
    @environment ?= new Environment
    @history      = []
    @root         = @constructor.linkAncestors(CoffeeScript.nodes @content)
    @file         = @prepare(@root, @path, File)

    @root.traverseChildren true, (node) =>
      for Entity in @environment.needles when Entity.looksLike(node)
        @prepare(node, @file, Entity)

      @history.push node

  prepare: (node, file, Entity) ->
    node.entities ?= []

    unless node.documentation?
      # Find actual comment node
      previous = @history[@history.length-1]

      switch previous?.constructor.name
        # A comment is preveding the entity declaration
        when 'Comment'
          doc = previous

        when 'Literal'
          # The node is exported `module.exports = ...`, take the comment before `module`
          if previous.value is 'exports'
            previous = @history[@history.length-6]
            doc = previous if previous?.constructor.name is 'Comment'

      if doc?.comment?
        node.documentation = new Documentation(@leftTrimBlock doc.comment)

    if Entity.is(node)
      entity = new Entity @environment, file, node
      node.entities.push(entity)
      @environment.registerEntity(entity)

      entity

  # Detect whitespace on the left and removes
  # the minimum whitespace ammount.
  #
  # The method additionally drops invisible UTF
  # whitespace introduced by `convertComments`
  #
  # @example left trim all lines
  #   leftTrimBlock(['', '  Escape at maximum speed.', '', '  @param (see #move)', '  '])
  #   => ['', 'Escape at maximum speed.', '', '@param (see #move)', '']
  #
  # This will keep indention for examples intact.
  #
  # @param [Array<String>] lines the comment lines
  # @return [Array<String>] lines left trimmed lines
  #
  leftTrimBlock: (text) ->
    return unless text

    lines = text.replace(/\u0091/gm, '').split('\n')

    # Detect minimal left trim amount
    trimMap = lines.map (line) ->
      line.length - _.str.ltrim(line).length if line.length != 0

    minimalTrim = _.min _.without(trimMap, undefined)

    # If we have a common amount of left trim
    if minimalTrim > 0 && minimalTrim < Infinity

      # Trim same amount of left space on each line
      lines = for line in lines
        line = line.substring(minimalTrim, line.length)
        line

    # Strip empty prepending lines
    lines = lines.slice(1) while lines[0].length == 0

    # Strip empty postponing lines
    lines = lines.slice(0, -1) while lines[lines.length-1].length == 0

    lines

  inspect: ->
    @environment.inspect()
