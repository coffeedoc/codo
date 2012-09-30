class Example.Overload

  # This is a generic Store set method.
  #
  # @overload set(key, value)
  #   Sets a value on key
  #   @param [Symbol] key describe key param
  #   @param [Object] value describe value param
  #   @param [Object] options the options
  #   @option options test [String] the test option
  #
  # @overload set(value)
  #   Sets a value on the default key `:foo`
  #   @param [Object] value describe value param
  #   @return [Boolean] true when success
  #
  set: (args...) ->
