Environment = require '../../../lib/environment'
Method = require '../../../lib/entities/mixin'

describe 'Mixin', ->

  describe 'effective methods', ->

    it 'get listed for inclusion', ->
      environment = Environment.read('spec/_templates/mixins/mixin_methods.coffee')
      expect(environment.entities[1].effectiveInclusionMethods()).toEqual(
        [
          { name: 'helper', type: 'dynamic', parameters: [] },
          { name: 'another', type: 'dynamic', parameters: [ 'a', 'b' ] },
          {
            name: 'withDefault',
            type: 'dynamic',
            parameters: [
              'a = 2',
              'c',
              'd = \'hi\'',
              'd',
              'e = {\n  a: 2\n}',
              'f = new TestClassMethods()'
            ]
          },
          {
            name: 'nowWithSpalt',
            type: 'dynamic',
            parameters: [ 'foo', 'bar...' ]
          },
          { name: 'set', type: 'dynamic', parameters: [ 'key', 'value' ] }
        ]
      )

    it 'get listed for extension', ->
      environment = Environment.read('spec/_templates/mixins/mixin_methods.coffee')
      expect(environment.entities[1].effectiveExtensionMethods()).toEqual(
        [
          { name: 'helper', type: 'static', parameters: [] },
          { name: 'another', type: 'static', parameters: [ 'a', 'b' ] },
          {
            name: 'withDefault',
            type: 'static',
            parameters: [
              'a = 2',
              'c',
              'd = \'hi\'',
              'd',
              'e = {\n  a: 2\n}',
              'f = new TestClassMethods()'
            ]
          },
          {
            name: 'nowWithSpalt',
            type: 'static',
            parameters: [ 'foo', 'bar...' ]
          },
          { name: 'set', type: 'static', parameters: [ 'key', 'value' ] }
        ]
      )

    it 'get listed for concern', ->
      environment = Environment.read('spec/_templates/mixins/concern.coffee')
      expect(environment.entities[1].effectiveConcernMethods()).toEqual(
        [
          { name: 'a', type: 'static', parameters: [ 'a', 'b', 'c' ] },
          { name: 'z', type: 'static', parameters: [ 'x', 'y', 'z' ] },
          { name: 'hi', type: 'dynamic', parameters: [ 'to' ] },
          { name: 'goodbye', type: 'dynamic', parameters: [ 'to' ] } ]
      )