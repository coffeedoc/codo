Parameter = require './parameter'
Meta      = require '../_meta'

module.exports = class Meta.Method

  @override: (options, overrides) ->
    options[key] = value for key, value of overrides
    options

  @fromMethodEntity: (entity, overrides={}) ->
    options =
      name: entity.name.match(/[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*/)?[0]
      kind: entity.kind || ''
      bound: entity.bound
      parameters: entity.parameters.map (x) -> x.toString()
      documentation: entity.documentation
    new @(@override options, overrides)

  @fromDocumentationMethod: (entry, overrides={}) ->
    kind = switch entry.signature[0]
      when '#'
        'dynamic'
      when '.'
        'static'

    options =
      name: entry.signature.replace /^[\#\.]?["']?([^\("']+)\(.+/, '$1'
      kind: kind || ''
      parameters: Parameter.fromSignature(entry.signature).map (x) -> x.toString()
      documentation: entry.documentation
    new @(@override options, overrides)

  constructor: (options={}) ->
    @constructor.override @, options

  effectiveOverloads: ->
    return @_effectiveOverloads if @_effectiveOverloads?

    @_effectiveOverloads = []

    if @documentation?.overloads
      for overload in @documentation.overloads
        @_effectiveOverloads.push(Method.fromDocumentationMethod overload)
    else
      @_effectiveOverloads.push(@)

    @_effectiveOverloads

  kindSignature: ->
    switch @kind
      when 'dynamic'
        '#'
      when 'static'
        '.'
      else
        '~'

  shortSignature: ->
    @kindSignature() + @name

  typeSignature: ->
    '('+(@documentation?.returns?.type || 'void')+')'

  paramsSignature: ->
    '('+@parameters.join(', ')+')'

  inspect: ->
    {
      name: @name,
      kind: @kind,
      bound: @bound,
      parameters: @parameters
    }
