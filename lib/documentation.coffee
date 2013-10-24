Markdown  = require './markdown'
_         = require 'underscore'
_.str     = require 'underscore.string'

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
      unless /^@example|@overload|@method/.exec line
        while /^\s{2}\S+/.test(lines[0])
          line += lines.shift().substring(1)

      if property = /^@property\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @property = property[1]
        lines.push property[2]

      else if returns = /^@return\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @returns =
          type: returns[1]
          desc: Markdown.convert(returns[2], true)

      else if returns = /^@return\s+(.+)/i.exec line
        @returns =
          type: '?'
          desc: Markdown.convert(returns[1], true)

      else if throws = /^@throw\s+[\[\{](.+?)[\]\}](?:\s+(.+))?/i.exec line
        @throws or= []
        @throws.push
          type: throws[1]
          desc: Markdown.convert(throws[2], true)

      else if throws = /^@throw\s+(.+)/i.exec line
        @throws or= []
        @throws.push
          type: '?'
          desc: Markdown.convert(throws[1], true)

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
        @includes or= []
        @includes.push include[1]

      else if extend = /^@extend\s+(.+)/i.exec line
        @extends or= []
        @extends.push extend[1]

      else if overload = /^@overload\s+(.+)/i.exec line
        signature = overload[1]
        innerComment = []

        while /^\s{2}.*/.test(lines[0]) or /^\s*$/.test(lines[0])
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
            returns: doc.returns

      else if method = /^@method\s+(.+)/i.exec line
        signature = method[1]
        innerComment = []

        while /^\s{2}.*/.test(lines[0]) or /^\s*$/.test(lines[0])
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
            returns: doc.returns
            notes: doc.notes
            todos: doc.todos
            examples: doc.examples
            authors: doc.authors

      else
        comment.push line

    text = comment.join('\n')
    @comment = Markdown.convert(text)

    sentence = /((?:.|\n)*?[.#][\s$])/.exec(text)
    sentence = sentence[1].replace(/\s*#\s*$/, '') if sentence
    @summary = Markdown.convert(_.str.clean(sentence || text), true)

  toJSON: ->
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

      methods: @methods
      property: @property
    }