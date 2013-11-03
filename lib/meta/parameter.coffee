CoffeeScript = require 'coffee-script'
Meta         = require '../_meta'

module.exports = class Meta.Parameter

  @fromNode: (node) ->
    new @ @fetchName(node), !!node.splat, @fetchDefault(node)

  @fromSignature: (signature) ->
    signature = signature.replace /^.([^\(]+)/, "x="
    nodes = CoffeeScript.nodes("#{signature} ->").expressions[0].value.params
    nodes.map (node) => @fromNode(node)

  @fetchName: (node) ->
    # Normal attribute `do: (it) ->`
    name = node.name.value

    # Named parameters a la python:
    #  `make_fac : ({numerator, divisor}) ->`
    # Also works for class constructors:
    #  `constructor : ( { @name, @key, opts }) ->
    unless name
      if (o = node.name.objects)?
        vars = for v in o
          if v.base.value is 'this' then v.properties[0].name.value
          else v.base.value
        name = "{#{vars.join ', '}}"

    # Assigned attributes `do: (@it) ->`
    unless name
      if node.name.properties
        name = node.name.properties[0]?.name.value

    name

  @fetchDefault: (node) ->
    try
      node.value?.compile
        indent: ''

    catch error
      if node?.value?.base?.value is 'this'
        value = node.value.properties[0]?.name.compile
          indent: ''

        "@#{value}"

  constructor: (@name, @splat, @default) ->

  toString: ->
    splat = '...' if @splat
    defauld = " = #{@default}" if @default

    [@name, splat, defauld].join('')

  inspect: ->
    {
      name: @name
      splat: @splat
      default: @default
    }