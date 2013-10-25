# This class has virtual methods, which doesn't
# exist in the source but appears in the documentation.
#
# @method #set(key, value)
#   Sets a value
#   @param [String] key describe key param
#   @param [Object] value describe value param
#   @option value [String] string
#   @option value [Integer] number
#   @option value [Object] whatever
#
# @method .get(key)
#   Gets a value
#   @param [String] key describe key param
#   @return [Object] describe value param
#
# @method #delete({key, passion}, foo='bar')
#   Deletes a key from the data.
#
#   Another line
#
#   @param [String] key describe key param
#
#   @example Delete a key.
#     emv = new Example.Methods.Virtual
#     emv.set 'foo', 'bar'
#     val = emv.get 'foo'
#
#     # now, proclaim you're done with foo.
#     emv.delete 'foo'
#
# This line should be part of the class description, and the method declaration
# shouldn't have messed it up.
#
class Example.Methods.Virtual
