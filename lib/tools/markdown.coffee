marked = require 'marked'
Tools  = require '../_tools'

marked.setOptions(
  sanitize: true
)

# It looks like all the markdown libraries for node doesn't get
# GitHub flavored markdown right. This helper class post-processes
# the best available output from the marked library to conform to
# GHM. In addition the allowed tags can be limited.
#
module.exports = class Tools.Markdown

  # Tags to keep when parsing is limited
  @limitedTags: 'a,abbr,acronym,b,big,cite,code,del,em,i,ins,sub,sup,span,small,strike,strong,q,tt,u'

  # Convert markdown to Html. If the param `limit`
  # is true, then all unwanted elements are stripped from the
  # result and also all existing newlines.
  #
  # @param [String] markdown the markdown markup
  # @param [Boolean] limit if elements should be limited
  #
  @convert: (markdown, limit = false, allowed = Markdown.limitedTags) ->
    return if markdown is undefined

    html = marked(markdown)

    if limit
      html = html.replace(/\n/, ' ')
      html = Markdown.limit(html, allowed)

    # Remove newlines around open and closing paragraph tags
    html = html.replace /(?:\n+)?<(\/?p)>(?:\n+)?/mg, '<$1>'

    # Add '.html' to relative markdown links
    html = html.replace /href="(?!https?:\/\/)(.*\.md)"/mg, 'href="$1.html"'

    html

  # Strips all unwanted tag from the html
  #
  # @param [String] html the Html to clean
  # @param [String] allowed the comma separated list of allowed tags
  # @return [String] the cleaned Html
  #
  @limit: (html, allowed) ->
    allowed = allowed.split ','

    replace = (html) ->
      result = html.replace /<([a-z0-9]+)\s*(?:\s[^>]+)?>([\s\S]+?)<\/\1>/g, (match, tag, text) ->
        if allowed.indexOf(tag) is -1 then text else match
      if result == html
        result
      else
        replace(result)
    replace(html)

