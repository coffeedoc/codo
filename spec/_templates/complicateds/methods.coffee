# @include Mixin
# @extend Mixin
# @concern Concern
#
# @method #x(key, value)
#   Sets a value
#
class Class
  z: ->

# @mixin
Mixin =
  m: ->

# @mixin
Concern =
  ClassMethods:
    cs: ->

  InstanceMethods:
    cd: ->

class Subclass extends Class
  x: ->

class Subsubclass extends Subclass
  y: ->