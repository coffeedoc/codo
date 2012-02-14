class App.TestMethodDocumentation extends App.Doc

  # Do it!
  #
  # @see {#undo} for more information
  #
  # @param [String] it The thing to do
  # @param [Object] options The do options
  # @option options [String] speed The speed
  # @option options [Number] repeat How wany time to repeat
  # @option options [Array<Tasks>] tasks The tasks to do
  # @return [Boolean] When successful executed
  #
  do: (it, options) ->
