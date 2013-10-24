module.exports = class Method extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.constructor.name == 'Code'

  constructor: (@environment, @file, @node) ->
    @name = [node.variable.base.value]
    @name.push prop.name.value for prop in @node.variable.properties

    if @name[0] == 'this'
      @selfish = true
      @name    = @name.slice(1)

    if @name[0] == 'module' && @name[1] == 'exports'
      @name = @name.slice(2)

    if @name[0] == 'exports'
      @name = @name.slice(1)

    @name = @name.join('.')

    @documentation = @node.documentation

    @parameters = @node.value.params.map (node) ->
      new Parameter(node)

  toJSON: ->
    {
      file:          @file.path
      name:          @name
      documentation: @documentation?.toJSON()
      selfish:       @selfish
      type:          @type
      parameters:    @parameters.map (x) -> x.toJSON()
    }


class Parameter
  constructor: (@node) ->
    @name = @fetchName()
    @splat = !!@node.splat
    @default = @fetchDefault()

  fetchName: ->
    # Normal attribute `do: (it) ->`
    name = @node.name.value

    # Named parameters a la python:
    #  `make_fac : ({numerator, divisor}) ->`
    # Also works for class constructors:
    #  `constructor : ( { @name, @key, opts }) ->
    unless name
      if (o = @node.name.objects)?
        vars = for v in o
          if v.base.value is 'this' then v.properties[0].name.value
          else v.base.value
        name = "{#{vars.join ', '}}"

    # Assigned attributes `do: (@it) ->`
    unless name
      if @node.name.properties
        name = @node.name.properties[0]?.name.value

    name

  fetchDefault: ->
    try
      @node.value?.compile
        indent: ''

    catch error
      if @node?.value?.base?.value is 'this'
        value = @node.value.properties[0]?.name.compile
          indent: ''

        "@#{value}"

  toJSON: ->
    {
      name: @name
      splat: @splat
      default: @default
    }