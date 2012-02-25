class App.TestMethodDocumentation extends App.Doc

  # Do it!
  #
  # @see #undo for more information
  #
  # @private
  # @param [String] it The thing to do
  # @param again [Boolean] Do it again
  # @param [Object] options The do options
  # @option options [String] speed The speed
  # @option options [Number] repeat How wany time to repeat
  # @option options [Array<Tasks>] tasks The tasks to do
  # @return [Boolean] When successful executed
  #
  do: (it, again, options) ->

  # Do it!
  #
  # @see {#undo} for more information
  #
  # @private
  # @param [String] it The thing to do
  # @param [Object] options The do options
  # @option options [String] speed The speed
  # @option options [Number] repeat How wany time to repeat
  # @option options [Array<Tasks>] tasks The tasks to do
  # @return [Boolean] When successful executed
  #
  @lets_do_it = (it, options) ->
