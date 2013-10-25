Parameter = require './parameter'

module.exports = class Method

  @override: (options, overrides) ->
    options[key] = value for key, value of overrides
    options

  @fromMethodEntity: (entity, overrides={}) ->
    options =
      name: entity.name
      type: entity.type
      parameters: entity.parameters.map (x) -> x.toString()

    new @(@override options, overrides)

  @fromDocumentationMethod: (entry, overrides={}) ->
    type = switch entry.signature[0]
      when '#'
        'dynamic'
      when '.'
        'static'

    options =
      name: entry.signature.replace /^.([^\(]+)\(.+/, '$1'
      type: type
      parameters: Parameter.fromSignature(entry.signature).map (x) -> x.toString()

    new @(@override options, overrides)

  constructor: (options={}) ->
    @constructor.override @, options