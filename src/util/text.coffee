# Global text helpers
#
module.exports =

  # Whitespace helper function
  #
  # @param [Number] n the number if indents
  # @return [String] the indention string
  #
  whitespace: (n) ->
    n = n * 2
    a = []
    while a.length < n
      a.push ' '
    a.join ''
