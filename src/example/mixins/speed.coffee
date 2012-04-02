# This module adds speed measurements to animals
#
# @mixin
#
Example.Mixins.Speed =

  # Get the distance the animal will put back in a certain time.
  #
  # @param [Integer] time Number of seconds
  # @return [Integer] The distance the animal will pass during the given time
  #
  distance: (time) ->
    5 * time
