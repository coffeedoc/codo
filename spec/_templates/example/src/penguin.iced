# A iced penguin.
#
# @author Iced
# @see http://en.wikipedia.org/wiki/Penguin
# @include Example.AngryAnimal
# @extend MissingMixin
#
class Example.Animal.Penguin extends Example.Animal

  # Maximum speed in MPH
  @MAX_SPEED = 100

  # Move the penguin fast
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
