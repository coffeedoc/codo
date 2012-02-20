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

  # Navigate form a search list
  #
  $('body.noframes #content.list ul').on 'click', 'li', (event) ->
    window.parent.location.href = $(@).find('a').attr('href')
    event.preventDefault()

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
