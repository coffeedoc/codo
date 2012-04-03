class Example.Methods.Overload

  # This is a generic Store set method.
  #
  # @overload set(key, value)
  #   Sets a value on key
  #   @param [Symbol] key describe key param
  #   @param [Object] value describe value param
  #
  # @overload set(value)
  #   Sets a value on the default key `:foo`
  #   @param [Object] value describe value param
  #   @return [Boolean] true when success
  #
  set: (args...) ->
