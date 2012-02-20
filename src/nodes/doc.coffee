marked = require 'marked'
_      = require 'underscore'
_.str  = require 'underscore.string'

# A documentation node is responsible for parsing
# the comments for known tags.
#
module.exports = class Doc

  # Construct a documentation
  #
  # @param [Object] node the comment node
  # @param [Object] options the parser options
  #
  constructor: (@node, @options) ->
    try
      if @node
        comment = []
        lines = @node.comment.split '\n'

        while (line = lines.shift()) isnt undefined

          # Look ahead
          unless /^@example/.exec line
            while /^\s{2}\w+/.test(lines[0])
              line += lines.shift().substring(1)

          # TODO: @overload

          if returnValue = /^@return\s+\[(.*?)\](\s+(.*))?/.exec line
            @returnValue =
              type: returnValue[1]
              desc: returnValue[3]

          else if param = /^@param\s+([^ ]*)\s+\[(.*?)\]\s+(.*)/.exec line
            @params or= []
            @params.push
              type: param[2]
              name: param[1]
              desc: param[3]

          else if param = /^@param\s+\[(.*?)\]\s+([^ ]*)\s+(.*)/.exec line
            @params or= []
            @params.push
              type: param[1]
              name: param[2]
              desc: param[3]

          else if option = /^@option\s+([^ ]*)\s+\[(.*?)\]\s+([^ ]*)\s+(.*)/.exec line
            @paramsOptions or= {}
            @paramsOptions[option[1]] or= []

            @paramsOptions[option[1]].push
              type: option[2]
              name: option[3]
              desc: option[4]

          else if see = /^@see\s+(.*)/.exec line
            @see or= []
            @see.push see[1]

          else if author = /^@author\s+(.*)/.exec line
            @authors or= []
            @authors.push author[1]

          else if note = /^@note\s+(.*)/.exec line
            @notes or= []
            @notes.push note[1]

          else if todo = /^@todo\s+(.*)/.exec line
            @todos or= []
            @todos.push todo[1]

          else if example = /^@example\s+(.*)/.exec line
            title = example[1]
            code = []

            while /^\s{2}.*/.test(lines[0])
              code.push lines.shift().substring(2)

            if code.length isnt 0
              @examples or= []
              @examples.push
                title: title
                code: code.join '\n'

          else if abstract = /^@abstract\s?(.*)/.exec line
            @abstract = abstract[1]

          else if /^@private/.exec line
            @private = true

          else if since = /^@since\s+(.*)/.exec line
            @since = since[1]

          else if version = /^@version\s+(.*)/.exec line
            @version = version[1]

          else if deprecated = /^@deprecated\s+(.*)/.exec line
            @deprecated = deprecated[1]

          else
            comment.push line

        text = comment.join('\n')
        @summary = _.str.clean(/((?:.|\n)*?\.)/.exec(text)?[1] || text)
        @comment = marked(text)

    catch error
      console.warn('Create doc error:', @node, error) if @options.verbose

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    if @node
      json =
        abstract: @abstract
        private: @private
        deprecated: @deprecated
        version: @version
        since: @since
        examples: @examples
        todos: @todos
        notes: @notes
        authors: @authors
        comment: @comment
        summary: @summary
        params: @params
        options: @paramsOptions
        see: @see
        returnValue: @returnValue

      json
