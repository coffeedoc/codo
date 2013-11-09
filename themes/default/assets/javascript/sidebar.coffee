$ ->

  # Create stripes
  window.createStripes = ->
    $('#content.list li:visible').each (i, el) ->
      if i % 2 is 0 then $(el).addClass('stripe') else $(el).removeClass('stripe')

  # Indent nested Lists
  window.indentTree = (el, width) ->
    $(el).find('> ul').each ->
      $(@).find('> li').css 'padding-left', "#{ width }px"
      window.indentTree $(@), width + 20


  #
  # Add tree arrow links
  #
  $('#content.tree ul > ul').each ->
    $(@).prev().prepend $('<a href="#" class="toggle"></a>')

  #
  # Search List
  #
  $('#search input').keyup (event) ->
    search = $(@).val().toLowerCase()

    if search.length == 0
      $('#content.list ul li').each ->
        if $('#content').hasClass 'tree'
          $(@).removeClass 'result'
          $(@).css 'padding-left', $(@).data 'padding'
        $(@).show()
    else
      $('#content.list ul li').each ->
        if $(@).find('a').text().toLowerCase().indexOf(search) == -1
          $(@).hide()
        else
          if $('#content').hasClass 'tree'
            $(@).addClass 'result'
            padding = $(@).css('padding-left')
            $(@).data 'padding', padding unless padding == '0px'
            $(@).css 'padding-left', 0
          $(@).show()

    window.createStripes()

  #
  # Navigate from a Search List
  #
  $('body #content.list ul').on 'click', 'li', (event) ->
    link = $(@).find('a:not(.toggle)').attr('href')
    top.frames['main'].location.href = link if link && link != '#'
    event.preventDefault()

  #
  # Collapse/expand sub trees
  #
  $('#content.tree a.toggle').click ->
    $(@).toggleClass 'collapsed'
    $(@).parent().next().toggle()
    window.createStripes()

  #
  # Initialize
  #
  indentTree $('#content.list > ul'), 20
  createStripes()