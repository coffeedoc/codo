$(document).ready ->

  # Add frame markers
  #
  if window.top.frames.main
    $('body').addClass 'frames'
  else
    $('body').addClass 'noframes'

  # Code Highlighting
  #
  $('pre code').each (i, e) -> hljs.highlightBlock e, '  '

  # Show search box when loaded
  #
  $('#search_frame').on 'load', (event) -> $(@).show()

  # Focus the list search
  #
  $('#search input').focus()

  # Search Tabs
  #
  $('#search a').click (event) ->
    event.preventDefault()

    if $(@).hasClass 'active'
      $(@).removeClass 'active'
      $('#search_frame').hide()
    else
      $('#search a').removeClass 'active'
      $('#search_frame').one 'load', => $(@).addClass 'active'
      $('#search_frame').attr('src', $(@).attr('href'))

  # Search list
  #
  $('#content.list #search input').keyup (event) ->
    search = $(@).val().toLowerCase()

    if search.length is 0
      $('#content.list ul li').each ->
        if $('#content').hasClass 'tree'
          $(@).removeClass 'result'
          $(@).css 'padding-left', $(@).data 'padding'
        $(@).show()
    else
      $('#content.list ul li').each ->
        if $(@).find('a').text().toLowerCase().indexOf(search) is -1
          $(@).hide()
        else
          if $('#content').hasClass 'tree'
            $(@).addClass 'result'
            $(@).data 'padding', $(@).css('padding-left')
            $(@).css 'padding-left', 0
          $(@).show()

    window.createStripes()

  # Navigate from a search list
  #
  $('body #content.list ul').on 'click', 'li', (event) ->
    link = $(@).find('a:not(.toggle)').attr('href')

    if link
      if $('body').hasClass 'noframes'
        window.parent.location.href = link unless link is '#'
      else
        top.frames['main'].location.href = link unless link is '#'

    event.preventDefault()

  # Add tree arrow links
  #
  $('#content.tree ul > ul').each ->
    $(@).prev().prepend $('<a href="#" class="toggle"></a>')

  # Create stripes
  #
  window.createStripes = ->
    $('#content.list li:visible').each (i, el) ->
      if i % 2 is 0 then $(el).addClass('stripe') else $(el).removeClass('stripe')

  # Collapse/expand sub trees
  #
  $('#content.tree a.toggle').click ->
    $(@).toggleClass 'collapsed'
    $(@).parent().next().toggle()
    window.createStripes()

  # Switch to frame mode
  #
  $('a.frames').click (event) ->
    location.href = $(@).attr 'href'
    event.preventDefault()

  # Switch to no frame mode
  #
  $('a.noframes').click (event) ->
    parent.location.href = location.href
    event.preventDefault()

  # Indent nested Lists
  #
  window.indentTree = (el, width) ->
    $(el).find('> ul').each ->
      $(@).find('> li').css 'padding-left', "#{ width }px"
      window.indentTree $(@), width + 20

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

  # Toggle the TOC visibility
  $('a.hide_toc').click -> $('nav.toc').toggleClass 'hidden'

  # Toggle the float position status between floating and inline
  $('a.float_toc').click ->
    $('nav.toc').toggleClass 'inline'
    $(@).text if $('nav.toc').hasClass 'inline' then 'float' else 'left'

  indentTree $('#content.list > ul'), 20
  createStripes()
