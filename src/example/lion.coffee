# A dangerous lion. Take care.
#
# @author Simba
#
class Example.Animal.Lion extends Example.Animal

  # Move the lion fast
  #
  # @param [String] direction the moving direction
  # @param [Number] speed the moving speed
  #
  move: (direction, speed) ->
    super({ diection: direction, speed: speed })
