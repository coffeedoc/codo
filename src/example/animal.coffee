# Base class for all animals.
#
# @note This is not used for codo, its purpose is to show
#   all possible tags within a class, even when it makes no sense at all.
#   For example this reference test to {Example.Animal.Lion#move}
#
# @todo Provide more examples with {Example.Animal.Lion}
#
# @example How to subclass an {Example.Animal}
#   class Lion extends Animal
#     move: (direction, speed): ->
#
# @abstract Each animal implementation must inherit from {Example.Animal}
#
# @author Michael Kessler
# @deprecated This class is not used anymore, use {Example.Animal.Lion}
# @version 0.2.0
# @since 0.1.0
# @private
# @see Example.Animal.Lion
# @see Example.Animal.Lion#move
# @see Example.Animal.enterArk Enter the Ark
# @include Example.Mixins.Speed
# @extend Example.Mixins.Herd
#
class Example.Animal

  # Language helpers
  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  # The Answer to the Ultimate Question of Life, the Universe, and Everything
  @ANSWER = 42

  # @property [String] The Animal name
  get name: -> @_name || 'unknown'
  set name: (@_name) ->

  # @property [String] The Animal color
  get color: -> @_color

  # Construct a new animal.
  #
  # @todo Clean up
  # @param [String] name the name of the {Example.Animal}
  # @param [Date] birthDate when the animal was born
  #
  constructor: (@name, @birthDate = new Date()) ->

  # Move the animal.
  #
  # @example Move an animal
  #   new Lion('Simba').move('south', 12)
  #
  # @abstract
  # @param [Object] options the moving options
  # @option options [String] direction the {#move} direction
  # @option options [Number] speed the speed in mph
  # @see .enterArk
  #
  move: (options = {}) ->

  # Copulate another animal.
  #
  # @note Don't take it seriously
  #
  # @private
  # @author Michael Kessler
  # @param [Example.Animal] animal the partner animal
  # @return [Boolean] true when success, test an {Example.Animal}
  # @deprecated Do not copulate, use {Example.Animal.Lion}
  # @version 0.2.0
  # @since 0.1.0
  #
  copulate: (animal) =>

  # Moves all animals into the ark.
  #
  # @return [Boolean] true when all in Ark
  # @see #move
  #
  @enterArk: ->
