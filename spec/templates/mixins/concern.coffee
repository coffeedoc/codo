# This is my concern
# @mixin
Example.Mixins.Concern =

  ClassMethods:
    # @param [String] a This is the a parameter
    # @param [String] b This is the a parameter
    # @param [String] c This is the a parameter
    a: (a, b, c) ->

    # @param [String] x This is the x parameter
    # @param [String] y This is the y parameter
    # @param [String] z This is the z parameter
    z: (x, y, z) ->

  InstanceMethods:
    # Say hi
    # @param [String] to the name
    hi: (to) ->
    # Say goodbye
    # @param [String] to the name
    goodbye: (to) ->

# @concern Example.Mixins.Concern
class Example.Concern
