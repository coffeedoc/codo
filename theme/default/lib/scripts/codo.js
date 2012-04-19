(function() {

  $(document).ready(function() {
    var loadSearch;
    $('#search_frame').hide();
    if (window.top.frames.main) {
      $('body').addClass('frames');
    } else {
      $('body').addClass('noframes');
    }
    $('pre code').each(function(i, e) {
      return hljs.highlightBlock(e, '  ');
    });
    $('#search_frame').on('load', function(event) {
      return $('#search_frame').show();
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
              if (padding !== '0px') $(this).data('padding', padding);
              $(this).css('padding-left', 0);
            }
            return $(this).show();
          }
        });
      }
      return window.createStripes();
    });
    $('#commandt input').keyup(function(event) {
      var match, path, result, resultList, results, search, searches, text, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
      text = $(this).val().toLowerCase();
      resultList = $('#commandt ol').empty();
      if (text) {
        path = $('#base').attr('data-path');
        results = [];
        searches = [
          RegExp("(" + text + ")"), RegExp("" + (_.map(text.split(''), function(c) {
            return "(" + c + ")";
          }).join('.+?'))), RegExp("(" + text + ")", "i"), RegExp("" + (_.map(text.split(''), function(c) {
            return "(" + c + ")";
          }).join('.+?')), "i")
        ];
        for (_i = 0, _len = searches.length; _i < _len; _i++) {
          search = searches[_i];
          _ref = _.filter(window.searchData, function(data) {
            return search.test(data.t);
          });
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            result = _ref[_j];
            result.search = search;
            results.push(result);
          }
        }
        _ref2 = _.unique(results);
        for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
          result = _ref2[_k];
          match = result.t.replace(result.search, function(txt) {
            return "<span>" + txt + "</span>";
          });
          resultList.prepend($("<li><a href='" + path + result.p + "'>" + match + "</a>" + (result.h ? "<small>(" + result.h + ")</small>" : '') + "</li>"));
        }
      }
      return $('#commandt').height(resultList.height() + 45);
    });
    $('body #content.list ul').on('click', 'li', function(event) {
      var link;
      link = $(this).find('a:not(.toggle)').attr('href');
      if (link) {
        if ($('body').hasClass('noframes')) {
          if (link !== '#') window.parent.location.href = link;
        } else {
          if (link !== '#') top.frames['main'].location.href = link;
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
      var ancestors, depth, heading, i, index, level, list, nav, target, _len, _ref, _ref2;
      nav = $('nav.toc');
      target = nav;
      level = 0;
      ancestors = [];
      _ref = $('h2,h3,h4,h5,h6', this);
      for (index = 0, _len = _ref.length; index < _len; index++) {
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
          for (i = 0, _ref2 = level - depth; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
            target = ancestors.pop();
          }
          if (!target) target = $('nav.toc ol:first');
          level = depth;
        }
        target.append($("<li><a href='#toc_" + index + "'>" + (heading.text()) + "</a></li>"));
      }
      if ($('ol', nav).length === 0) return nav.hide();
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
      tagname = (event.target || event.srcElement).tagName;
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
        return parent.frames.main.$('#commandt').hide();
      } else if (parent) {
        parent.$("#search .active").click();
        parent.$('#help').hide();
        return parent.$('#commandt').hide();
      } else {
        $('#search input').blur();
        $('#help').hide();
        return $('#commandt').hide();
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
      $('#commandt').toggle();
      $('#commandt input').focus().select();
      if (parent.frames.main) {
        parent.frames.main.$('#commandt').show();
        parent.frames.main.$('#commandt input').focus().select();
      }
      return e.preventDefault();
    });
  });

}).call(this);
