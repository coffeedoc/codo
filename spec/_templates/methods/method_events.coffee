class Example.Events

  # This is a generic Events emit method.
  #
  # @event theBasic.One
  # @event theWeirdOne Omg this event is so weird o_O
  # @event theComplicatedOne
  #   This is the complicated event yo
  #   @param [String] the incredible string
  #
  # This should be more description for the method itself, and events
  # shouldn't have messed it up.
  #
  emit: (args...) ->
