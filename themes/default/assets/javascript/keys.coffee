$ ->

  loadSearch = (url, link) ->
    parent.frames.list.location.href = url unless /#{ url }$/.test parent.frames.list.location.href

  # Allow ESC to blur #search
  key.filter = (e) ->
    tagname = (e.target || e.srcElement).tagName
    tagname isnt 'INPUT' || e.keyCode is 27 || e.ctrlKey is true

  # Focus search input
  key 's', (e) ->
    e.preventDefault()

    try
      parent.frames.list.$('#search input').focus().select()

    try
      $('#search input').focus().select()

  # Unblur the search input
  key 'esc', ->
    try
      parent.frames.list.$('#search input').blur()
      parent.frames.main.$('#help').hide()
      parent.frames.main.$('#fuzzySearch').hide()

    try
      parent.$("#search .active").click()
      parent.$('#help').hide()
      parent.$('#fuzzySearch').hide()

    try
      $('#search input').blur()
      $('#help').hide()
      $('#fuzzySearch').hide()

  # Hide list navigation
  # FIXME: Manually resize the frame confuses the toggle
  key 'l', ->
    body = $(parent.document.body)

    if body.data('toggled')
      parent.document.body.cols = '25%, *'
      body.data 'toggled', false
    else
      parent.document.body.cols = '0, *'
      body.data 'toggled', true

  # List navigation
  key 'c', -> loadSearch 'class_list.html', 'class_list_link'
  key 'm', -> loadSearch 'method_list.html', 'method_list_link'
  key 'i', -> loadSearch 'mixin_list.html', 'mixin_list_link'
  key 'f', -> loadSearch 'file_list.html', 'file_list_link'
  key 'e', -> loadSearch 'extra_list.html', 'extra_list_link'

  # Show help
  key 'h', ->
    try
      parent.frames.main.$('#help').toggle()
    catch
      try
        $('#help').toggle()

  # Fuzzy class search
  key 't', (e) ->
    e.preventDefault()

    try
      $('#fuzzySearch').toggle()
      $('#fuzzySearch input').focus().select()

    try
      parent.frames.main.$('#fuzzySearch').show()
      parent.frames.main.$('#fuzzySearch input').focus().select()