$ ->

  $('#search_frame').hide()
  window.lastSearch = ''

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

