(function() {

  $(document).ready(function() {
    var loadSearch;
    $('#search_frame').hide();
    window.lastSearch = '';
    if (window.top.frames.main) {
      $('body').addClass('frames');
    } else {
      $('body').addClass('noframes');
    }
    $('pre code').each(function(i, e) {
      return hljs.highlightBlock(e, '  ');
    });
    $('#search_frame').on('load', function(event) {
      if ($(this).attr('src')) {
        return $('#search_frame').show();
      }
    });
    $('.frames #content a').each(function() {
      if (/^https?:\/\//i.test($(this).attr('href'))) {
        return $(this).attr('target', '_top');
      }
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
    $('#content.list #search input').keyup(function(event) {
      var search;
      search = $(this).val().toLowerCase();
      if (search.length === 0) {
        $('#content.list ul li').each(function() {
          if ($('#content').hasClass('tree')) {
            $(this).removeClass('result');
            $(this).css('padding-left', $(this).data('padding'));
          }
          return $(this).show();
        });
      } else {
        $('#content.list ul li').each(function() {
          var padding;
          if ($(this).find('a').text().toLowerCase().indexOf(search) === -1) {
            return $(this).hide();
          } else {
            if ($('#content').hasClass('tree')) {
              $(this).addClass('result');
              padding = $(this).css('padding-left');
              if (padding !== '0px') {
                $(this).data('padding', padding);
              }
              $(this).css('padding-left', 0);
            }
            return $(this).show();
          }
        });
      }
      return window.createStripes();
    });
    $('#fuzzySearch input').keyup(function(event) {
      var data, highlights, index, items, match, matches, path, resultList, text, _i, _len;
      text = $(this).val();
      resultList = $('#fuzzySearch ol');
      if (event.keyCode === 13) {
        return location.href = $('#fuzzySearch ol li.selected a').attr('href');
      } else if (event.keyCode === 38) {
        items = resultList.children();
        index = items.index($('#fuzzySearch ol li.selected'));
        $(items.get(index)).removeClass('selected');
        index -= 1;
        if (index === -1) {
          index = items.length - 1;
        }
        return $(items.get(index)).addClass('selected');
      } else if (event.keyCode === 40) {
        items = resultList.children();
        index = items.index($('#fuzzySearch ol li.selected'));
        $(items.get(index)).removeClass('selected');
        index += 1;
        if (index === items.length) {
          index = 0;
        }
        return $(items.get(index)).addClass('selected');
      } else if (text && text !== lastSearch) {
        window.lastSearch = text;
        resultList.empty();
        path = $('#base').attr('data-path');
        matches = fuzzy(text, _.pluck(searchData, 't'), {
          limit: 25
        });
        highlights = fuzzy(text, _.pluck(searchData, 't'), {
          pre: '<span>',
          post: '</span>',
          limit: 25
        });
        for (index = _i = 0, _len = matches.length; _i < _len; index = ++_i) {
          match = matches[index];
          data = _.find(searchData, function(d) {
            return d.t === match;
          });
          resultList.append($("<li><a href='" + path + data.p + "'>" + highlights[index] + "</a>" + (data.h ? "<small>(" + data.h + ")</small>" : '') + "</li>"));
        }
        $('#fuzzySearch ol li:first').addClass('selected');
        $('#fuzzySearch').height(resultList.height() + 45);
        return $('#fuzzySearch ol li').each(function(i, el) {
          if (i % 2 === 0) {
            return $(el).addClass('stripe');
          } else {
            return $(el).removeClass('stripe');
          }
        });
      } else if (text !== lastSearch) {
        resultList.empty();
        return $('#fuzzySearch').height(45);
      }
    });
    $('body #content.list ul').on('click', 'li', function(event) {
      var link;
      link = $(this).find('a:not(.toggle)').attr('href');
      if (link) {
        if ($('body').hasClass('noframes')) {
          if (link !== '#') {
            window.parent.location.href = link;
          }
        } else {
          if (link !== '#') {
            top.frames['main'].location.href = link;
          }
        }
      }
      return event.preventDefault();
    });
    $('#content.tree ul > ul').each(function() {
      return $(this).prev().prepend($('<a href="#" class="toggle"></a>'));
    });
    window.createStripes = function() {
      return $('#content.list li:visible').each(function(i, el) {
        if (i % 2 === 0) {
          return $(el).addClass('stripe');
        } else {
          return $(el).removeClass('stripe');
        }
      });
    };
    $('#content.tree a.toggle').click(function() {
      $(this).toggleClass('collapsed');
      $(this).parent().next().toggle();
      return window.createStripes();
    });
    $('a.frames').click(function(event) {
      location.href = $(this).attr('href');
      return event.preventDefault();
    });
    $('a.noframes').click(function(event) {
      parent.location.href = location.href;
      return event.preventDefault();
    });
    window.indentTree = function(el, width) {
      return $(el).find('> ul').each(function() {
        $(this).find('> li').css('padding-left', "" + width + "px");
        return window.indentTree($(this), width + 20);
      });
    };
    $('#filecontents').each(function() {
      var ancestors, depth, heading, i, index, level, list, nav, target, _i, _j, _len, _ref, _ref1;
      nav = $('nav.toc');
      target = nav;
      level = 0;
      ancestors = [];
      _ref = $('h2,h3,h4,h5,h6', this);
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        heading = _ref[index];
        heading = $(heading);
        heading.before($("<a name='toc_" + index + "'></a>"));
        depth = parseInt(heading.get(0).tagName.substring(1));
        if (depth > level) {
          list = $('<ol></ol>');
          target.append(list);
          ancestors.push(target);
          target = list;
          level = depth;
        } else if (depth < level) {
          for (i = _j = 0, _ref1 = level - depth; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            target = ancestors.pop();
          }
          if (!target) {
            target = $('nav.toc ol:first');
          }
          level = depth;
        }
        target.append($("<li><a href='#toc_" + index + "'>" + (heading.text()) + "</a></li>"));
      }
      if ($('ol', nav).length === 0) {
        return nav.hide();
      }
    });
    $('a.hide_toc').click(function() {
      return $('nav.toc').toggleClass('hidden');
    });
    $('a.float_toc').click(function() {
      $('nav.toc').toggleClass('inline');
      return $(this).text($('nav.toc').hasClass('inline') ? 'float' : 'left');
    });
    indentTree($('#content.list > ul'), 20);
    createStripes();
    loadSearch = function(url, link) {
      if (parent.frames.list) {
        if (!/#{ url }$/.test(parent.frames.list.location.href)) {
          return parent.frames.list.location.href = url;
        }
      } else if (parent) {
        return parent.$("#search #" + link).click();
      } else {
        return $("#search #" + link).click();
      }
    };
    key.filter = function(e) {
      var tagname;
      tagname = (e.target || e.srcElement).tagName;
      return tagname !== 'INPUT' || e.keyCode === 27 || e.ctrlKey === true;
    };
    key('s', function(e) {
      $('#search input').focus().select();
      if (parent.frames.list) {
        parent.frames.list.$('#search input').focus().select();
      }
      return e.preventDefault();
    });
    key('esc', function() {
      if (parent.frames.list) {
        parent.frames.list.$('#search input').blur();
        parent.frames.main.$('#help').hide();
        return parent.frames.main.$('#fuzzySearch').hide();
      } else if (parent) {
        parent.$("#search .active").click();
        parent.$('#help').hide();
        return parent.$('#fuzzySearch').hide();
      } else {
        $('#search input').blur();
        $('#help').hide();
        return $('#fuzzySearch').hide();
      }
    });
    key('⌃+l', function() {
      var body;
      body = $(parent.document.body);
      if (body.data('toggled')) {
        parent.document.body.cols = '20%, *';
        return body.data('toggled', false);
      } else {
        parent.document.body.cols = '0, *';
        return body.data('toggled', true);
      }
    });
    key('⌃+c', function() {
      return loadSearch('class_list.html', 'class_list_link');
    });
    key('⌃+m', function() {
      return loadSearch('method_list.html', 'method_list_link');
    });
    key('⌃+i', function() {
      return loadSearch('mixin_list.html', 'mixin_list_link');
    });
    key('⌃+f', function() {
      return loadSearch('file_list.html', 'file_list_link');
    });
    key('⌃+e', function() {
      return loadSearch('extra_list.html', 'extra_list_link');
    });
    key('⌃+h', function() {
      if (parent.frames.main) {
        return parent.frames.main.$('#help').toggle();
      } else if (parent) {
        return parent.$('#help').toggle();
      } else {
        return $('#help').toggle();
      }
    });
    return key('⌃+t', function(e) {
      $('#fuzzySearch').toggle();
      $('#fuzzySearch input').focus().select();
      if (parent.frames.main) {
        parent.frames.main.$('#fuzzySearch').show();
        parent.frames.main.$('#fuzzySearch input').focus().select();
      }
      return e.preventDefault();
    });
  });

}).call(this);
