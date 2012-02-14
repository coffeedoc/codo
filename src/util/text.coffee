# Global text helpers
#
module.exports =

  # Whitespace helper function
  #
  # @param [Number] n the number of spaces
  # @return [String] the space string
  #
  whitespace: (n) ->
    a = []
    while a.length < n
      a.push ' '
    a.join ''
