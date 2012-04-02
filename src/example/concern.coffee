# This is my concern
# @mixin
Example.Concerns.ConcernA =

  ClassMethods:
    # @param [String] a This is the a parameter
    # @param [String] b This is the a parameter
    # @param [String] c This is the a parameter
    a: (a, b, c) ->

  InstanceMethods:
    # Say hi
    # @param [String] to the name
    hi: (to) ->

# This is my concern
# @mixin
Example.Concerns.ConcernB =

  ClassMethods:
    # @param [String] x This is the x parameter
    # @param [String] y This is the y parameter
    # @param [String] z This is the z parameter
    z: (x, y, z) ->

  InstanceMethods:
    # Say goodbye
    # @param [String] to the name
    goodbye: (to) ->

# @concern Example.Concerns.ConcernA
# @concern Example.Concerns.ConcernB
class Example.Concern
