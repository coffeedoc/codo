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
      $('#content.list ul li').show()
    else
      $('#content.list ul li').each ->
        if $(@).find('a').text().toLowerCase().indexOf(search) is -1
          $(@).hide()
        else
          $(@).show()

    window.createStripes()

  # Navigate form a search list
  #
  $('body #content.list ul').on 'click', 'li', (event) ->
    link = $(@).find('a').attr('href')

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

  indentTree $('#content.list > ul'), 20
  createStripes()
