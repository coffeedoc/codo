###
Base class for all animals.

@note This is not used for codo, its purpose is to show
  all possible tags within a class.

@todo Provide more examples

@example How to subclass an animal
  class Lion extends Animal
    move: (direction, speed): ->

@abstract Each animal implementation must inherit from {Animal}

@author Michael Kessler
@deprecated This class is not used anymore
@version 0.2.0
@since 0.1.0
###
class Example.Animal

  ###
  The Answer to the Ultimate Question of Life, the Universe, and Everything
  ###
  @ANSWER = 42

  ###
  Construct a new animal.

  @todo Clean up
  @param [String] name the name of the animal
  @param [Date] birthDate when the animal was born
  ###
  constructor: (@name, @birthDate = new Date()) ->

  ###
  Move the animal.

  @example Move an animal
    new Lion('Simba').move('south', 12)

  @abstract
  @param [Object] options the moving options
  @option options [String] direction the moving direction
  @option options [Number] speed the speed in mph
  ###
  move: (options = {}) ->

  ###
  Copulate another animal.

  @note Don't take it seriously

  @private
  @author Michael Kessler
  @param [Animal] animal the partner animal
  @return [Boolean] true when success
  @deprecated Do not copulate
  @version 0.2.0
  @since 0.1.0
  ###
  copulate: (animal) =>

  ###
  Moves all animal into the ark.

  @return [Boolean] true when all in Ark
  ###
  @enterArk: ->
