# A dangerous lion. Take care.
#
# @author Simba
# @see http://en.wikipedia.org/wiki/Lion
#
class Example.Animal.Lion extends Example.Animal

  # Maximum speed in MPH
  @MAX_SPEED = 50

  # The Animal name
  get awards: -> @_awards
  set awards: (@_awards) ->

  # Move the lion fast
  #
  # @param [String] direction the moving direction
  # @param [Number] speed the moving speed
  #
  move: (direction, speed) ->
    super({ diection: direction, speed: speed })

  # Escape at maximum speed.
  #
  # @param (see #move)
  #
  escape: (direction) ->
    @move(direction, @MAX_SPEED)
