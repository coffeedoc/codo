#
# @method #set(key, value)
#   Sets a value
#   @param [String] key describe key param
#   @param [Object] value describe value param
#   @option value [String] string
#   @option value [Integer] number
#   @option value [Object] whatever
#
# @mixin
Foo =

  helper: ->

  another: (a, b) ->

  withDefault: (a = 2, c, d = 'hi', d, e = { a: 2 }, f = new TestClassMethods()) ->

  nowWithSpalt: (foo, bar...) ->
