(function() {
  var makePattern, surroundMatch;

  window.fuzzy = function(pattern, items, options) {
    var addMatch, after, appendMatch, before, doHighlight, flags, hasTextBeforeSeparator, ignorecase, ignorespace, inner, isMatch, item, len, limit, matches, parts, post, postPart, postSep, postSepRegex, pre, prePart, preParts, preSep, preSepRegex, prependMatch, separate, separator, _i, _len;
    if (options == null) {
      options = {};
    }
    pre = options.pre, post = options.post, limit = options.limit, separator = options.separator, ignorecase = options.ignorecase, ignorespace = options.ignorespace, separate = options.separate;
    if (ignorecase == null) {
      ignorecase = true;
    }
    if (ignorespace == null) {
      ignorespace = true;
    }
    if (separate == null) {
      separate = false;
    }
    if (separate && !separator) {
      throw new Error("You must pass a separator when options.separate is true.");
    }
    if (ignorespace) {
      pattern = pattern.replace(/\s/g, "");
    }
    matches = [];
    flags = (ignorecase && "i") || "";
    doHighlight = pre && post;
    addMatch = function(before, after, method) {
      if (separate) {
        return matches[method]([before, after]);
      } else {
        if (before) {
          return matches[method](before + separator + after);
        } else {
          return matches[method](after);
        }
      }
    };
    appendMatch = function(before, after) {
      return addMatch(before, after, "push");
    };
    prependMatch = function(before, after) {
      return addMatch(before, after, "unshift");
    };
    if (separator) {
      preParts = pattern.split(separator);
      postPart = preParts.pop();
      prePart = preParts.join(separator);
      inner = _.map(preParts, (function(p) {
        return makePattern(p);
      }));
      inner = inner.join(".*?" + separator + ".*?");
      preSepRegex = new RegExp("^.*?" + inner + ".*?$", flags);
    } else {
      preParts = false;
      postPart = pattern;
      preSepRegex = false;
    }
    postSepRegex = new RegExp("^.*?" + (makePattern(postPart)) + ".*$", flags);
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      item = items[_i];
      if (matches.length === limit) {
        break;
      }
      hasTextBeforeSeparator = separator && !!~item.indexOf(separator);
      if (!hasTextBeforeSeparator && item.indexOf(pattern) === 0) {
        if (doHighlight) {
          len = pattern.length;
          prependMatch("", pre + item.slice(0, len) + post + item.slice(len));
        } else {
          prependMatch("", item);
        }
        continue;
      }
      if (hasTextBeforeSeparator) {
        parts = item.split(separator);
        preSep = parts.slice(0, -1).join(separator);
        postSep = _.last(parts);
      } else {
        preSep = "";
        postSep = item;
      }
      isMatch = !preSepRegex || preSepRegex.test(preSep);
      isMatch && (isMatch = !postSepRegex || postSepRegex.test(postSep));
      if (!isMatch) {
        continue;
      }
      if (doHighlight) {
        after = surroundMatch(postSep, postPart, pre, post, ignorecase);
        if (hasTextBeforeSeparator) {
          before = surroundMatch(preSep, prePart, pre, post, ignorecase);
          appendMatch(before, after);
        } else {
          appendMatch("", after);
        }
      } else {
        appendMatch(preSep, postSep);
      }
    }
    return matches;
  };

  makePattern = function(pattern) {
    var c, chars, regex, _i, _len;
    chars = pattern.split("");
    regex = [];
    for (_i = 0, _len = chars.length; _i < _len; _i++) {
      c = chars[_i];
      c = c === "\\" ? "\\\\" : c;
      regex.push("([" + c + "])");
    }
    return regex.join("[^/]*?");
  };

  surroundMatch = function(string, pattern, pre, post, ignorecase) {
    var c, done, nextChar, sameChar, _i, _len, _ref;
    done = "";
    pattern = pattern.split("");
    nextChar = pattern.shift();
    _ref = string.split("");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      if (nextChar) {
        sameChar = false;
        if (ignorecase && c.toLowerCase() === nextChar.toLowerCase()) {
          sameChar = true;
        } else if (!ignorecase && c === nextChar) {
          sameChar = true;
        }
        if (sameChar) {
          done += "" + pre + c + post;
          nextChar = pattern.shift();
          continue;
        }
      }
      done += c;
    }
    return done;
  };

}).call(this);
