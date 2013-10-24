# The greeting
GREETING = 'Hay'

# Says hello to a person
#
# @param [String] name the name of the persion
#
hello = (name) ->
  console.log GREETING, name

# Says bye to a person
#
# @param [String] name the name of the persion
#
bye = (name) ->
  console.log "Bye, bye #{ name }"

# Say hi to a person
#
# @param [String] name the name of the persion
#
module.exports.sayHi = (hi) -> console.log "Hi #{ hi}!"
