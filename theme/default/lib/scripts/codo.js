(function() {

  $(document).ready(function() {
    return $('pre code').each(function(i, e) {
      return hljs.highlightBlock(e, '  ');
    });
  });

}).call(this);
