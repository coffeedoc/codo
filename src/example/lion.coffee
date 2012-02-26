# A dangerous lion. Take care. It's an {Example.Animal}
#
# @author Simba
# @see http://en.wikipedia.org/wiki/Lion
#
class Example.Animal.Lion extends Example.Animal

  # Move the lion fast
  #
  # @param [String] direction the moving direction
  # @param [Number] speed the moving speed
  #
  move: (direction, speed) ->
    super({ direction: direction, speed: speed })
