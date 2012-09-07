marked = require 'marked'

# It looks like all the markdown libraries for node doesn't get
# GitHub flavored markdown right. This helper class post-processes
# the best available output from the marked library to conform to
# GHM. In addition the allowed tags can be limited.
#
module.exports = class Markdown

  # Tags to keep when parsing is limited
  @limitedTags: 'a,abbr,acronym,b,big,cite,code,del,em,i,ins,sub,sup,span,small,strike,strong,q,tt,u'

  # Convert markdown to Html. If the param `limit`
  # is true, then all unwanted elements are stripped from the
  # result.
  #
  # @param [String] markdown the markdown markup
  # @param [Boolean] limit if elements should be limited
  #
  @convert: (markdown, limit = false, allowed = Markdown.limitedTags) ->
    return if markdown is undefined

    html = marked(markdown)

    # Cleanup newlines
    html = html.replace />\n+/mg, '>'
    html = html.replace /\n+</mg, '<'

    # Convert newlines, but not within code blocks
    html = html.replace /\n/mg, '<br />'
    html = html.replace /<pre>(.+?)<\/pre>/mg, (match) -> match.replace /<br \/>/mg, "\n"

    html = Markdown.limit(html, allowed) if limit

    html

  # Strips all unwanted tag from the html
  #
  # @param [String] html the Html to clean
  # @param [String] allowed the comma separated list of allowed tags
  # @return [String] the cleaned Html
  #
  @limit: (html, allowed) ->
    allowed = allowed.split ','

    html.replace /<([a-z]+)>(.+?)<\/\1>/, (match, tag, text) ->
      if allowed.indexOf(tag) is -1 then text else match
