Environment = require '../../../lib/environment'
Method = require '../../../lib/entities/mixin'

describe 'Class', ->

  it 'lists effective methods', ->

    environment = Environment.read('spec/_templates/complicateds/methods.coffee')
    methods     = environment.entities[1].effectiveMethods()

    expect(methods[0].inspect()).toEqual { name: 'z', kind: 'dynamic', bound: false, parameters: [] }
    expect(methods[1].inspect()).toEqual { name : 'x', kind : 'dynamic', parameters : [ 'key', 'value' ] }

  it 'lists inherited methods', ->

    environment = Environment.read('spec/_templates/complicateds/methods.coffee')
    methods     = environment.entities[12].inheritedMethods().map (x) -> x.entity.inspect()

    expect(methods).toEqual(
      [
        { name: 'x', kind: 'dynamic', bound: false, parameters: [  ] },
        { name: 'z', kind: 'dynamic', bound: false, parameters: [  ] },
        { name: 'm', kind: 'dynamic', bound: false, parameters: [  ] },
        { name: 'cs', kind: 'static', bound: false, parameters: [  ] },
        { name: 'cd', kind: 'dynamic', bound: false, parameters: [  ] }
      ]
    )

  it 'lists inherited variables', ->

    environment = Environment.read('spec/_templates/complicateds/variables.coffee')
    variables   = environment.entities[5].inheritedVariables().map (x) -> x.entity.inspect()

    expect(variables).toEqual(
      [
        {
          file: 'spec/_templates/complicateds/variables.coffee',
          name: 'z',
          constant: false,
          value: "'456'",
          kind: 'dynamic'
        }
      ]
    )