class User
  # @param [String] username the name of the user to add
  # @param [Number] uid the user ID
  # @param [Number] gid the group ID
  constructor: (username, uid, gid) ->

class UserHelper
  # @param (see User#constructor)
  addUser: (username, uid, gid) ->
    new User(username, uid, gid)

  # @param username (see User#constructor)
  addRootUser: (username) ->
    new User(username, 0, 0)
