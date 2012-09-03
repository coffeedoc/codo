# Taken from: https://github.com/stratuseditor/fuzzy-filter/blob/master/index.coffee

# Public: Filter a list of items.
#
# pattern - The fuzzy String to match against.
# items   - An Array of String.
# options - (optional)
#         * pre         - String to insert before matching text.
#         * post        - String to insert after matching text.
#         * limit       - Integer maximum number of results.
#         * separator   - String separator. Match against the last
#                         section of the String by default.
#         * ignorecase  - Boolean (default: true).
#         * ignorespace - Boolean (default: true).
#         * separate    - Boolean (default: false). If set to true, the
#                         function returns an array of an array of strings,
#                         where each array is
#                         [beforeLastSeparator, afterLastSeparator].
#                         If set, `separator` must also be passed.
#
# Note: If `pre` is passed, you also have to pass `post` (and vice-versa).
#
# Examples
#
#   fuzzy = require 'fuzzy-filter'
#   fuzzy "cs", ["cheese", "pickles", "crackers", "pirate attack", "cs!!"]
#   # => ["cs!!", "cheese", "crackers"]
#
#   fuzzy "cs", ["cheese", "pickles", "crackers", "pirate attack", "cs!!"],
#     pre:  "<b>"
#     post: "</b>"
#   # => ["<b>cs</b>!!", "<b>c</b>hee<b>s</b>e", "<b>c</b>racker<b>s</b>"]
#
#   fuzzy "cs", ["cookies", "cheese/pie", "fried/cheese", "cheese/cookies"],
#     pre:       "<b>"
#     post:      "</b>"
#     separator: "/"
#   # => [ "<b>c</b>ookie<b>s</b>"
#   #    , "fried/<b>c</b>hee<b>s</b>e"
#   #    , "cheese/<b>c</b>ookie<b>s</b>" ]
#
#   fuzzy "cs/", ["cookies", "cheese/pie", "fried/cheese", "cheese/cookies"],
#     pre:       "<b>"
#     post:      "</b>"
#     separator: "/"
#   # => [ "<b>c</b>hee<b>s</b>e/pie"
#   #    , "<b>c</b>hee<b>s</b>e/cookies" ]
#
#   fuzzy "cs/p", ["cookies", "cheese/pie", "fried/cheese", "cheese/cookies"],
#     pre:       "<b>"
#     post:      "</b>"
#     separator: "/"
#   # => ["<b>c</b>hee<b>s</b>e/<b>p</b>ie"]
#
#   fuzzy "cs/p", ["cookies", "cheese/pie", "fried/cheese", "cheese/cookies"],
#     pre:       "<b>"
#     post:      "</b>"
#     separator: "/"
#     separate:  true
#   # => [ ["<b>c</b>hee<b>s</b>e", "<b>p</b>ie"] ]
#
# Returns an Array of String.
window.fuzzy = (pattern, items, options={}) ->
  {pre, post, limit, separator, ignorecase, ignorespace, separate} = options
  ignorecase  ?= true
  ignorespace ?= true
  separate    ?= false

  # `separate` requires a separator.
  if separate && !separator
    throw new Error "You must pass a separator when options.separate is true."

  pattern     = pattern.replace /\s/g, "" if ignorespace
  matches     = []
  flags       = (ignorecase && "i") || ""
  doHighlight = pre && post

  # Internal:
  # before - The matched text before the last separator.
  # after  - The matched text after the last separator.
  # method - "unshift" or "push"
  addMatch = (before, after, method) ->
    if separate
      matches[method] [before, after]
    else
      if before
        matches[method] before + separator + after
      else
        matches[method] after


  # Internal: Add a match to the end of the matches Array.
  # Returns nothing.
  appendMatch = (before, after) ->
    addMatch before, after, "push"

  # Internal: Prepend a match to the matches Array.
  # Returns nothing.
  prependMatch = (before, after) ->
    addMatch before, after, "unshift"

  if separator
    preParts    = pattern.split separator
    postPart    = preParts.pop()
    prePart     = preParts.join separator
    inner       = _.map preParts, ((p) -> makePattern(p))
    inner       = inner.join ".*?#{ separator }.*?"
    preSepRegex = new RegExp "^.*?#{ inner }.*?$", flags
  else
    preParts     = false
    postPart     = pattern
    preSepRegex  = false
  postSepRegex = new RegExp "^.*?#{ makePattern(postPart) }.*$", flags

  for item in items
    break if matches.length == limit
    hasTextBeforeSeparator = separator && !!~item.indexOf(separator)

    # Match the beginning of the item.
    if !hasTextBeforeSeparator && item.indexOf(pattern) == 0
      if doHighlight
        len = pattern.length
        prependMatch "", pre + item.slice(0, len) + post + item.slice(len)
      else
        prependMatch "", item
      continue

    if hasTextBeforeSeparator
      parts   = item.split separator
      preSep  = parts[0..-2].join separator
      postSep = _.last parts
    else
      preSep  = ""
      postSep = item

    # Match the part before the last separator.
    isMatch   = !preSepRegex  || preSepRegex.test(preSep)
    # Match the part after the last separator.
    isMatch &&= !postSepRegex || postSepRegex.test(postSep)
    continue unless isMatch

    if doHighlight
      after = surroundMatch postSep, postPart, pre, post, ignorecase
      if hasTextBeforeSeparator
        before = surroundMatch preSep, prePart, pre, post, ignorecase
        appendMatch before, after
      else
        appendMatch "", after
    else
      appendMatch preSep, postSep

  return matches



# Internal:
#
# Returns a String to be turned into a RegExp.
makePattern = (pattern) ->
  chars = pattern.split ""
  regex = []
  for c in chars
    c = if c is "\\" then "\\\\" else c
    regex.push "([#{ c }])"
  return regex.join "[^/]*?"


# Internal:
#
# Examples
#
#   surroundMatch "cheese", "cs", "<b>", "</b>"
#   # => "<b>c</b>hee<b>s</b>e"
#
# Returns String.
surroundMatch = (string, pattern, pre, post, ignorecase) ->
  done     = ""
  pattern  = pattern.split ""
  nextChar = pattern.shift()
  for c in string.split("")
    if nextChar
      sameChar = false
      if ignorecase && c.toLowerCase() == nextChar.toLowerCase()
        sameChar = true
      else if !ignorecase && c == nextChar
        sameChar = true

      if sameChar
        done    += "#{pre}#{c}#{post}"
        nextChar = pattern.shift()
        continue

    done += c
  return done
