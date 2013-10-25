# @include Mixin
# @extend Mixin
# @concern Concern
#
# @method #x(key, value)
#   Sets a value
#
class Class

# @mixin
Mixin =
  m: ->

# @mixin
Concern =
  ClassMethods:
    cs: ->

  InstanceMethods:
    cd: ->