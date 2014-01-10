module.exports = class Documentation

  constructor: (comment) ->
    @parseTags(comment)
  
  # Parse the given lines and adds the result
  # to the result object.
  #
  # @param [Array<String>] lines the lines to parse
  #
  parseTags: (lines) ->
    comment = []

    while (line = lines.shift()) isnt undefined

      # Look ahead
      unless /^@example|@overload|@method|@event/.exec line
        while /^\s{2}\S+/.test(lines[0])
          line += lines.shift().substring(1)

      if property = /^@nodoc/i.exec line
        @nodoc = true

      if property = /^@property\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @property = property[1]
        lines.push property[2]

      else if returns = /^@return\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @returns =
          type: returns[1]
          description: returns[2]

      else if returns = /^@return\s+(.+)/i.exec line
        @returns =
          type: '?'
          description: returns[1]

      else if throws = /^@throw\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @throws ?= []
        @throws.push
          type: throws[1]
          description: throws[2]

      else if throws = /^@throw\s+(.+)/i.exec line
        @throws ?= []
        @throws.push
          type: '?'
          description: throws[1]

      else if param = /^@param\s+([^ ]+)\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @params ?= []
        @params.push
          type: param[2]
          name: param[1]
          description: param[3]

      else if param = /^@param\s+[\[\{](.+?)[\]\}]\s+([^ ]+)(?:\s+(.+))?/i.exec line
        @params ?= []
        @params.push
          type: param[1]
          name: param[2]
          description: param[3]

      else if option = /^@option\s+([^ ]+)\s+[\[\{](.+?)[\]\}]\s+([^ ]+)(?:\s+(.+))?/i.exec line
        @options ?= {}
        @options[option[1]] ?= []

        @options[option[1]].push
          type: option[2]
          name: option[3]
          description: option[4]

      else if option = /^@option\s+([^ ]+)\s+([^ ]+)\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @options ?= {}
        @options[option[1]] ?= []

        @options[option[1]].push
          type: option[3]
          name: option[2]
          description: option[4]

      else if see = /^@see\s+([^\s]+)(?:\s+(.+))?/i.exec line
        @see ?= []
        @see.push
          reference: see[1]
          label: see[2]

      else if author = /^@author\s+(.+)/i.exec line
        @authors ?= []
        @authors.push author[1] || ''

      else if copyright = /^@copyright\s+(.+)/i.exec line
        @copyright = copyright[1] || ''

      else if note = /^@note\s+(.+)/i.exec line
        @notes ?= []
        @notes.push note[1] || ''

      else if todo = /^@todo\s+(.+)/i.exec line
        @todos ?= []
        @todos.push todo[1] || ''

      else if example = /^@example(?:\s+(.+))?/i.exec line
        title = example[1] || ''
        code = []

        while /^\s{2}.*/.test(lines[0]) or (/^$/.test(lines[0]) and /^\s{2}.*/.test(lines[1]))
          code.push lines.shift().substring(2)

        if code.length isnt 0
          @examples ?= []
          @examples.push
            title: title
            code: code.join '\n'

      else if abstract = /^@abstract(?:\s+(.+))?/i.exec line
        @abstract = abstract[1] || ''

      else if /^@private/.exec line
        @private = true

      else if since = /^@since\s+(.+)/i.exec line
        @since = since[1] || ''

      else if version = /^@version\s+(.+)/i.exec line
        @version = version[1] || ''

      else if deprecated = /^@deprecated(\s+)?(.*)/i.exec line
        @deprecated = deprecated[2] || ''

      else if mixin = /^@mixin/i.exec line
        @mixin = true

      else if concern = /^@concern\s+(.+)/i.exec line
        @concerns ?= []
        @concerns.push concern[1]

      else if include = /^@include\s+(.+)/i.exec line
        @includes ?= []
        @includes.push include[1]

      else if extend = /^@extend\s+(.+)/i.exec line
        @extends ?= []
        @extends.push extend[1]

      else if event = /^@event\s+(\S+)(\s+(.+))?/i.exec line
        @events ?= []

        innerComment = []
        innerComment.push(event[2]) if event[2]
        doc = {}

        while /^\s{2}.*/.test(lines[0]) || /^\s*$/.test(lines[0])
          innerComment.push lines.shift().substring(2)

        @parseTags.call(doc, innerComment) if innerComment

        @events.push
          name: event[1]
          documentation: doc

      else if overload = /^@overload\s+(.+)/i.exec line
        signature = overload[1]
        innerComment = []

        while /^\s{2}.*/.test(lines[0]) || /^\s*$/.test(lines[0])
          innerComment.push lines.shift().substring(2)

        if innerComment.length != 0
          @overloads ?= []

          doc = {}
          @parseTags.call doc, innerComment

          @overloads.push
            signature: signature
            documentation: doc

      else if method = /^@method\s+(.+)/i.exec line
        signature = method[1]
        innerComment = []

        while /^\s{2}.*/.test(lines[0]) or /^\s*$/.test(lines[0])
          innerComment.push lines.shift().substring(2)

        if innerComment.length isnt 0
          @methods ?= []

          doc = {}
          @parseTags.call doc, innerComment

          @methods.push
            signature: signature
            documentation: doc
      else
        comment.push line

    text = comment.join('\n')
    @comment = text.trim()

    sentence = /((?:.|\n)*?[.#][\s$])/.exec(text)
    sentence = sentence[1].replace(/\s*#\s*$/, '') if sentence
    @summary = (sentence || text || '').trim()

  inspect: ->
    {
      comment: @comment
      summary: @summary
      notes: @notes
      see: @see

      abstract: @abstract
      private: @private
      deprecated: @deprecated
      version: @version
      since: @since

      authors: @authors
      copyright: @copyright
      todos: @todos

      includes: @includes
      extends: @extends
      concerns: @concerns
      
      examples: @examples
      
      params: @params
      options: @options
      returns: @returns
      throws: @throws
      overloads: @overloads

      events: @events
      methods: @methods
      property: @property
    }