#
# This class is SO DOCUMENTED! Seriously, Just look at that! This is so incredible!
#
# It even has some links: {http://www.google.com Google for instance} {OverDocumentedClass}
# {OverDocumentedClass itself} {http://www.github.com} {OverDocumentedMixin~mixed_method}
# {Casper The ghost!}
#
# @abstract It's so abstract! ^_^ {http://www.github.com}
# @author The great Yoda {http://www.github.com}
# @include OverDocumentedMixin
# @include Casper
# @extend OverDocumentedMixin
# @extend Casper
# @copyright The great Yoda {http://www.github.com}
# @deprecated Don't use this anymore!!11
# @example Foobar
#   foo = bar
# @note Never fortget this thing! {http://www.github.com}
# @method #virtual_method({a, b})
#   This is the virtual method ZOMG
# @private
# @see www.github.com
# @since 1.0
# @todo Run with the wolves {http://www.github.com}
# @version 1.1
class OverDocumentedClass

  # The constant that is SO DOCUMENTED as well (I feel sick about it)
  # @abstract It's so abstract! ^_^ {http://www.github.com}
  # @author The great Yoda {http://www.github.com}
  # @copyright The great Yoda {http://www.github.com}
  # @deprecated Don't use this anymore!!11
  # @example Foobar
  #   foo = bar
  # @note Never fortget this thing! {http://www.github.com}
  # @private
  # @see www.github.com
  # @since 1.0
  # @todo Run with the wolves {http://www.github.com}
  # @version 1.1
  CONSTANT:
    foo: 'bar'

  # @abstract It's so abstract! ^_^ {http://www.github.com}
  # @author The great Yoda {http://www.github.com}
  # @copyright The great Yoda {http://www.github.com}
  # @deprecated Don't use this anymore!!11
  # @example Foobar
  #   foo = bar
  # @note Never fortget this thing! {http://www.github.com}
  # @private
  # @see www.github.com
  # @since 1.0
  # @todo Run with the wolves {http://www.github.com}
  # @version 1.1
  # @throw [OverDocumentedClass] EXCEPTION OMG
  # @return [OverDocumentedClass] RETVAL OMG
  # @param [String] foo                 The first parameter
  # @param [Integer] bar                The second parameter (all of a sudden)
  # @option options [String] option     The only option (wtf?)
  # @event simpleEvent
  # @event notSoSimpleEvent             Having description
  # @event complicatedEvent
  #   Having description and parameters
  #   @param [String]                   The string
  @class_method: (foo, bar, options={}) ->

  # @abstract It's so abstract! ^_^ {http://www.github.com}
  # @author The great Yoda {http://www.github.com}
  # @copyright The great Yoda {http://www.github.com}
  # @deprecated Don't use this anymore!!11
  # @example Foobar
  #   foo = bar
  # @note Never fortget this thing! {http://www.github.com}
  # @private
  # @see www.github.com
  # @since 1.0
  # @todo Run with the wolves {http://www.github.com}
  # @version 1.1
  # @throw [String] EXCEPTION OMG
  # @return [String] RETVAL OMG
  # @overload #instance_method(foo, bar)
  #   Obviously you can omit the last parameter
  # @overload #instance_method(foo, bar, options)
  #   Or you can set it!
  instance_method: (foo, bar, options={}) ->