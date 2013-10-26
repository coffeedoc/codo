Environment = require '../../../lib/environment'
Method = require '../../../lib/entities/mixin'

describe 'Class', ->

  it 'lists effective methods', ->

    environment = Environment.read('spec/_templates/complicateds/effective_methods.coffee')
    expect(environment.entities[1].effectiveMethods()).toEqual(
      [ 
        { name: 'x', type: 'dynamic', parameters: [ 'key', 'value' ] },
        { name: 'm', type: 'dynamic', parameters: [  ] },
        { name: 'm', type: 'static', parameters: [  ] },
        { name: 'cs', type: 'static', parameters: [  ] },
        { name: 'cd', type: 'dynamic', parameters : [  ] }
      ]
    )
