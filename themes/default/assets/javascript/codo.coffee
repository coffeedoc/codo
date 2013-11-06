$ ->

  # Highlight code
  $('pre code').each (i, e) -> hljs.highlightBlock e, '  '

  # Show external links in the main doc to avoid frame blocking by X-Frame-Options.
  $('#content a').each -> $(@).attr('target', '_top') if /^https?:\/\//i.test $(@).attr('href')