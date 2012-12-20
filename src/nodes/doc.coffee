Node      = require './node'
Markdown  = require '../util/markdown'

marked = require 'marked'
_      = require 'underscore'
_.str  = require 'underscore.string'

# A documentation node is responsible for parsing
# the comments for known tags.
#
module.exports = class Doc extends Node

  # Construct a documentation
  #
  # @param [Object] node the comment node
  # @param [Object] options the parser options
  #
  constructor: (@node, @options) ->
    try
      if @node
        @parseTags @leftTrimBlock(@node.comment.replace(/\u0091/gm, '').split('\n'))

    catch error
      console.warn('Create doc error:', @node, error) if @options.verbose

  # Determines if the current doc has some comments
  #
  # @return [Boolean] the comment status
  #
  hasComment: ->
    @node && @node.comment

  # Detect whitespace on the left and removes
  # the minimum whitespace ammount.
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
  leftTrimBlock: (lines) ->
    # Detect minimal left trim amount
    trimMap = _.map lines, (line) ->
      if line.length is 0
        undefined
      else
        line.length - _.str.ltrim(line).length

    minimalTrim = _.min _.without(trimMap, undefined)

    # If we have a common amount of left trim
    if minimalTrim > 0 and minimalTrim < Infinity

      # Trim same amount of left space on each line
      lines = for line in lines
        line = line.substring(minimalTrim, line.length)
        line

    lines

  # Parse the given lines and adds the result
  # to the result object.
  #
  # @param [Array<String>] lines the lines to parse
  #
  parseTags: (lines) ->
    comment = []

    while (line = lines.shift()) isnt undefined

      # Look ahead
      unless /^@example|@overload|@method/.exec line
        while /^\s{2}\S+/.test(lines[0])
          line += lines.shift().substring(1)

      if property = /^@property\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @property = property[1]
        lines.push property[2]

      else if returnValue = /^@return\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @returnValue =
          type: returnValue[1]
          desc: Markdown.convert(returnValue[2], true)

      else if returnValue = /^@return\s+(.+)/i.exec line
        @returnValue =
          type: '?'
          desc: Markdown.convert(returnValue[1], true)

      else if throwValue = /^@throw\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @throwValue or= []
        @throwValue.push
          type: throwValue[1]
          desc: Markdown.convert(throwValue[2], true)

      else if throwValue = /^@throw\s+(.+)/i.exec line
        @throwValue or= []
        @throwValue.push
          type: '?'
          desc: Markdown.convert(throwValue[1], true)

      else if param = /^@param\s+\(see ((?:[$A-Za-z_\x7f-\uffff][$.\w\x7f-\uffff]*)?[#.][$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)\)/i.exec line
        @params or= []
        @params.push
          reference: param[1]

      else if param = /^@param\s+([$A-Za-z_\x7f-\uffff][$.\w\x7f-\uffff]*)\s+\(see ((?:[$A-Za-z_\x7f-\uffff][$.\w\x7f-\uffff]*)?[#.][$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)\)/i.exec line
        @params or= []
        @params.push
          name: param[1]
          reference: param[2]

      else if param = /^@param\s+([^ ]+)\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @params or= []
        @params.push
          type: param[2]
          name: param[1]
          desc: Markdown.convert(param[3] || '', true)

      else if param = /^@param\s+[\[\{](.+?)[\]\}]\s+([^ ]+)(?:\s+(.+))?/i.exec line
        @params or= []
        @params.push
          type: param[1]
          name: param[2]
          desc: Markdown.convert(param[3] || '', true)

      else if option = /^@option\s+([^ ]+)\s+[\[\{](.+?)[\]\}]\s+([^ ]+)(?:\s+(.+))?/i.exec line
        @paramsOptions or= {}
        @paramsOptions[option[1]] or= []

        @paramsOptions[option[1]].push
          type: option[2]
          name: option[3]
          desc: Markdown.convert(option[4] || '', true)

      else if option = /^@option\s+([^ ]+)\s+([^ ]+)\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @paramsOptions or= {}
        @paramsOptions[option[1]] or= []

        @paramsOptions[option[1]].push
          type: option[3]
          name: option[2]
          desc: Markdown.convert(option[4] || '', true)

      else if see = /^@see\s+([^\s]+)(?:\s+(.+))?/i.exec line
        @see or= []
        @see.push
          reference: see[1]
          label: Markdown.convert(see[2], true)

      else if author = /^@author\s+(.+)/i.exec line
        @authors or= []
        @authors.push Markdown.convert(author[1], true)

      else if copyright = /^@copyright\s+(.+)/i.exec line
        @copyright = Markdown.convert(copyright[1], true)

      else if note = /^@note\s+(.+)/i.exec line
        @notes or= []
        @notes.push Markdown.convert(note[1], true)

      else if todo = /^@todo\s+(.+)/i.exec line
        @todos or= []
        @todos.push Markdown.convert(todo[1], true)

      else if example = /^@example(?:\s+(.+))?/i.exec line
        title = example[1] || ''
        code = []

        while /^\s{2}.*/.test(lines[0]) or (/^$/.test(lines[0]) and /^\s{2}.*/.test(lines[1]))
          code.push lines.shift().substring(2)

        if code.length isnt 0
          @examples or= []
          @examples.push
            title: title
            code: code.join '\n'

      else if abstract = /^@abstract(?:\s+(.+))?/i.exec line
        @abstract = Markdown.convert(abstract[1] || '', true)

      else if /^@private/.exec line
        @private = true

      else if since = /^@since\s+(.+)/i.exec line
        @since = Markdown.convert(since[1], true)

      else if version = /^@version\s+(.+)/i.exec line
        @version = Markdown.convert(version[1], true)

      else if deprecated = /^@deprecated\s+(.*)/i.exec line
        @deprecated = Markdown.convert(deprecated[1], true)

      else if mixin = /^@mixin/i.exec line
        @mixin = true

      else if concern = /^@concern\s+(.+)/i.exec line
        @concerns or= []
        @concerns.push concern[1]

      else if include = /^@include\s+(.+)/i.exec line
        @includeMixins or= []
        @includeMixins.push include[1]

      else if extend = /^@extend\s+(.+)/i.exec line
        @extendMixins or= []
        @extendMixins.push extend[1]

      else if overload = /^@overload\s+(.+)/i.exec line
        signature = overload[1]
        innerComment = []

        while /^\s{2}.*/.test(lines[0])
          innerComment.push lines.shift().substring(2)

        if innerComment.length isnt 0
          @overloads or= []

          doc = {}
          @parseTags.call doc, innerComment

          @overloads.push
            signature: signature.replace(/([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)(.+)/, (str, name, params) -> "<strong>#{ name }</strong>#{ params }")
            comment: doc.comment
            summary: doc.summary
            params: doc.params
            options: doc.paramsOptions
            returnValue: doc.returnValue

      else if method = /^@method\s+(.+)/i.exec line
        signature = method[1]
        innerComment = []

        while /^\s{2}.*/.test(lines[0])
          innerComment.push lines.shift().substring(2)

        if innerComment.length isnt 0
          @methods or= []

          doc = {}
          @parseTags.call doc, innerComment

          @methods.push
            signature: signature
            comment: doc.comment
            summary: doc.summary
            params: doc.params
            options: doc.paramsOptions
            private: doc.private
            abstract: doc.abstract
            deprecated: doc.deprecated
            version: doc.version
            since: doc.since
            see: doc.see
            returnValue: doc.returnValue
            notes: doc.notes
            todos: doc.todos
            examples: doc.examples
            authors: doc.authors
            hasComment: -> true

      else
        comment.push line

    text = comment.join('\n')
    @comment = Markdown.convert(text)

    sentence = /((?:.|\n)*?[.#][\s$])/.exec(text)
    sentence = sentence[1].replace(/\s*#\s*$/, '') if sentence
    @summary = Markdown.convert(_.str.clean(sentence || text), true)

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    if @node
      json =
        includes: @includeMixins
        extends: @extendMixins
        concerns: @concerns
        abstract: @abstract
        private: @private
        deprecated: @deprecated
        version: @version
        since: @since
        examples: @examples
        todos: @todos
        notes: @notes
        authors: @authors
        copyright: @copyright
        comment: @comment
        summary: @summary
        params: @params
        options: @paramsOptions
        see: @see
        returnValue: @returnValue
        throwValue: @throwValue
        overloads: @overloads
        methods: @methods
        property: @property

      json
