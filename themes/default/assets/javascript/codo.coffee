$(document).ready ->

  $('#search_frame').hide()
  window.lastSearch = ''

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
  $('#search_frame').on 'load', (event) ->
    if $(@).attr 'src'
      $('#search_frame').show()


  # Show external links in the main doc to
  # avoid frame blocking by X-Frame-Options.
  #
  $('.frames #content a').each ->
    $(@).attr('target', '_top') if /^https?:\/\//i.test $(@).attr('href')

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
            padding = $(@).css('padding-left')
            $(@).data 'padding', padding unless padding is '0px'
            $(@).css 'padding-left', 0
          $(@).show()

    window.createStripes()

  # Global fuzzy search
  #
  $('#fuzzySearch input').keyup (event) ->
    text = $(@).val()
    resultList = $('#fuzzySearch ol')

    if event.keyCode is 13
      location.href = $('#fuzzySearch ol li.selected a').attr 'href'

    else if event.keyCode is 38
      items = resultList.children()
      index = items.index($('#fuzzySearch ol li.selected'))
      $(items.get(index)).removeClass 'selected'
      index -= 1
      index = items.length - 1 if index is -1
      $(items.get(index)).addClass 'selected'

    else if event.keyCode is 40
      items = resultList.children()
      index = items.index($('#fuzzySearch ol li.selected'))
      $(items.get(index)).removeClass 'selected'
      index += 1
      index = 0 if index is items.length
      $(items.get(index)).addClass 'selected'

    else if text && text isnt lastSearch
      window.lastSearch = text
      resultList.empty()
      path = $('#base').attr 'data-path'
      matches = fuzzy text, _.pluck(searchData, 't'), { limit: 25 }
      highlights = fuzzy text, _.pluck(searchData, 't'), { pre: '<span>', post: '</span>', limit: 25 }

      for match, index in matches
        data = _.find(searchData, (d) -> d.t is match)
        resultList.append $("<li><a href='#{ path }#{ data.p }'>#{ highlights[index] }</a>#{ if data.h then "<small>(#{ data.h })</small>" else '' }</li>")

      $('#fuzzySearch ol li:first').addClass 'selected'
      $('#fuzzySearch').height(resultList.height() + 45)
      $('#fuzzySearch ol li').each (i, el) ->
        if i % 2 is 0 then $(el).addClass('stripe') else $(el).removeClass('stripe')

    else if text isnt lastSearch
      resultList.empty()
      $('#fuzzySearch').height(45)

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

  loadSearch = (url, link) ->
    if parent.frames.list
      parent.frames.list.location.href = url unless /#{ url }$/.test parent.frames.list.location.href
    else if parent
      parent.$("#search ##{ link }").click()
    else
      $("#search ##{ link }").click()

  # Allow ESC to blur #search
  key.filter = (e) ->
    tagname = (e.target || e.srcElement).tagName
    tagname isnt 'INPUT' || e.keyCode is 27 || e.ctrlKey is true

  # Focus search input
  key 's', (e) ->
    $('#search input').focus().select()

    if parent.frames.list
      parent.frames.list.$('#search input').focus().select()

    e.preventDefault()

  # Unblur the search input
  key 'esc', ->

    if parent.frames.list
      parent.frames.list.$('#search input').blur()
      parent.frames.main.$('#help').hide()
      parent.frames.main.$('#fuzzySearch').hide()
    else if parent
      parent.$("#search .active").click()
      parent.$('#help').hide()
      parent.$('#fuzzySearch').hide()
    else
      $('#search input').blur()
      $('#help').hide()
      $('#fuzzySearch').hide()

  # Hide list navigation
  # FIXME: Manually resize the frame confuses the toggle
  key '⌃+l', ->
    body = $(parent.document.body)

    if body.data('toggled')
      parent.document.body.cols = '20%, *'
      body.data 'toggled', false
    else
      parent.document.body.cols = '0, *'
      body.data 'toggled', true

  # List navigation
  key '⌃+c', -> loadSearch 'class_list.html', 'class_list_link'
  key '⌃+m', -> loadSearch 'method_list.html', 'method_list_link'
  key '⌃+i', -> loadSearch 'mixin_list.html', 'mixin_list_link'
  key '⌃+f', -> loadSearch 'file_list.html', 'file_list_link'
  key '⌃+e', -> loadSearch 'extra_list.html', 'extra_list_link'

  # Show help
  key '⌃+h', ->
    if parent.frames.main
      parent.frames.main.$('#help').toggle()
    else if parent
      parent.$('#help').toggle()
    else
      $('#help').toggle()

  # Fuzzy class search
  key '⌃+t', (e) ->

    $('#fuzzySearch').toggle()
    $('#fuzzySearch input').focus().select()

    if parent.frames.main
      parent.frames.main.$('#fuzzySearch').show()
      parent.frames.main.$('#fuzzySearch input').focus().select()

    e.preventDefault()
