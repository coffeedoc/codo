$(document).ready ->
  $('pre code').each (i, e) -> hljs.highlightBlock e, '  '
