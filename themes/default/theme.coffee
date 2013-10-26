Templater = require './lib/templater'

module.exports = class Theme

  @compile: (environment) ->
    @templater = new Templater(environment)
    @templater.compileAsset('javascript/application.js')