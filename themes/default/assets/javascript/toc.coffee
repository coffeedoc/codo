$ ->

  #
  # Create file TOC from the headings
  #
  $('#filecontents').each ->
    nav = $('nav.toc')
    target = nav
    level = 0
    ancestors = []

    for heading, index in $('h2,h3,h4,h5,h6', @)
      heading = $(heading)
      heading.before $("<a name='toc_#{ index }'></a>")

      depth = parseInt heading.get(0).tagName.substring(1)

      # Create a nested list
      if depth > level
        list = $('<ol></ol>')
        target.append list
        ancestors.push target

        target = list
        level = depth

      # Go up one list level
      else if depth < level
        target = ancestors.pop() for i in [0...level - depth]
        target = $('nav.toc ol:first') unless target
        level = depth

      target.append $("<li><a href='#toc_#{ index }'>#{ heading.text() }</a></li>")

    nav.hide() if $('ol', nav).length is 0

  #
  # Toggle the TOC visibility
  #
  $('a.hide_toc').click -> $('nav.toc').toggleClass 'hidden'

  #
  # Toggle the float position status between floating and inline
  #
  $('a.float_toc').click ->
    $('nav.toc').toggleClass 'inline'
    $(@).text if $('nav.toc').hasClass 'inline' then 'float' else 'left'
