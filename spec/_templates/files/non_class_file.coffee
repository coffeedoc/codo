# The greeting
GREETING = 'Hay'

# Hey, check this out!
module.exports = FOO = 'Foo constant!'

# Says hello to a person
#
# @param [String] name the name of the person
#
hello = (name) ->
  console.log GREETING, name

# Says bye to a person
#
# @param [String] name the name of the person
#
bye = (name) ->
  console.log "Bye, bye #{ name }"

# Say hi to a person
#
# @param [String] name the name of the person
#
module.exports.sayHi = (hi) -> console.log "Hi #{ hi}!"

# A fooer for fooing foos.
#
# @note Foo
module.exports = foo = (foos) ->
  logger.info 'Fooing...'