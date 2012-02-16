(function() {

  $(document).ready(function() {
    $('pre code').each(function(i, e) {
      return hljs.highlightBlock(e, '  ');
    });
    $('#search_frame').on('load', function(event) {
      return $(this).show();
    });
    $('#search input').focus();
    $('#search a').click(function(event) {
      var _this = this;
      event.preventDefault();
      if ($(this).hasClass('active')) {
        $(this).removeClass('active');
        return $('#search_frame').hide();
      } else {
        $('#search a').removeClass('active');
        $('#search_frame').one('load', function() {
          return $(_this).addClass('active');
        });
        return $('#search_frame').attr('src', $(this).attr('href'));
      }
    });
    $('#content.list ul').on('click', 'li', function(event) {
      window.parent.location.href = $(this).find('a').attr('href');
      return event.preventDefault();
    });
    return $('#content.list #search input').keyup(function(event) {
      var search;
      search = $(this).val().toLowerCase();
      if (search.length === 0) {
        return $('#content.list ul li').show();
      } else {
        return $('#content.list ul li').each(function() {
          if ($(this).find('a').text().toLowerCase().indexOf(search) === -1) {
            return $(this).hide();
          } else {
            return $(this).show();
          }
        });
      }
    });
  });

}).call(this);
