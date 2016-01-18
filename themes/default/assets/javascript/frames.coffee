$ ->
  if $('frameset').length > 0
    parser = document.createElement('a')
    parser.href = location.href
    starter = parser.hash.substr(1)

    if starter.length > 0
      $('#content')[0].contentWindow.location.href = starter

    $('#content').load ->
      hash = encodeURI(@contentWindow.location.href)

      if history.pushState
        history.replaceState(null, document.title, '#'+hash);
      else
        location.hash = hash