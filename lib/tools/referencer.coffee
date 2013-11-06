Tools = require '../_tools'

module.exports = class Tools.Referencer

  constructor: (@environment) ->

  resolve: (text, replacer) ->
    # Make curly braces within code blocks undetectable
    text = text.replace /\`[^\`]*\`/mg, (match) -> match.replace(/\{/mg, "\u0091").replace(/\}/mg, "\u0092")

    # Search for references and replace them
    text = text.replace /\{([^\}]*)\}/gm, (match, link) =>
      link  = link.split(' ')
      href  = link.shift()
      label = link.join(' ')

      replacement = @environment.reference(href)

      if replacement != href || /\:\/\/\w+((\:\d+)?\/\S*)?/.test(href)
        replacer replacement, label || href
      else
        match

    # Restore curly braces within code blocks
    text = text.replace /\`[^\`]*\`/mg, (match) -> match.replace(/\u0091/mg, '{').replace(/\u0092/mg, '}')
