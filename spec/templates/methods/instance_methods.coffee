class TestInstanceMethods

  helper: ->

  another: (param, obj) ->

  anotherWithValues: (param = 123, obj = { a: 1 }, yup, comp = new TestInstanceMethods()) ->

  nowWithSpalt: (foo, bar...) ->

  bound: =>

  # This is not exposed to the outside world.
  internalToClassClosure = -> alert 'internal!'
