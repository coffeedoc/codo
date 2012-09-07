# Property test class. It's almost the most difficult
# part to come up with stupid examples.
#
module.exports = class Person

  # Language helpers
  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  # The persons name
  get name: -> @_name || ''
  set name: (@_name) ->

  # The persons relationship status
  get born: -> @_relationships || 'single'

  # The persons confession
  set confession: (@_confession) ->

  # This should not be swallowed
  test: ->
