Environment = require '../../../lib/environment'
Method = require '../../../lib/entities/mixin'

describe 'Mixin', ->

  describe 'effective methods', ->

    it 'get listed for inclusion', ->
      environment = Environment.read('spec/_templates/mixins/mixin_methods.coffee')
      methods     = environment.entities[1].effectiveInclusionMethods().map (m) -> m.inspect()

      expect(methods).toEqual(
        [
          { name: 'helper', kind: 'dynamic', bound: false, parameters: [] },
          { name: 'another', kind: 'dynamic', bound: false, parameters: [ 'a', 'b' ] },
          {
            name: 'withDefault',
            kind: 'dynamic',
            bound: false,
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
            kind: 'dynamic',
            bound: false,
            parameters: [ 'foo', 'bar...' ]
          },
          { name: 'set', kind: 'dynamic', parameters: [ 'key', 'value' ] }
        ]
      )

    it 'get listed for extension', ->
      environment = Environment.read('spec/_templates/mixins/mixin_methods.coffee')
      methods     = environment.entities[1].effectiveExtensionMethods().map (m) -> m.inspect()

      expect(methods).toEqual(
        [
          { name: 'helper', kind: 'static', bound: false, parameters: [] },
          { name: 'another', kind: 'static', bound: false, parameters: [ 'a', 'b' ] },
          {
            name: 'withDefault',
            kind: 'static',
            bound: false,
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
            kind: 'static',
            bound: false,
            parameters: [ 'foo', 'bar...' ]
          },
          { name: 'set', kind: 'static', parameters: [ 'key', 'value' ] }
        ]
      )

    it 'get listed for concern', ->
      environment = Environment.read('spec/_templates/mixins/concern.coffee')
      methods     = environment.entities[1].effectiveConcernMethods().map (m) -> m.inspect()

      expect(methods).toEqual(
        [
          { name: 'a', kind: 'static', bound: false, parameters: [ 'a', 'b', 'c' ] },
          { name: 'z', kind: 'static', bound: false, parameters: [ 'x', 'y', 'z' ] },
          { name: 'hi', kind: 'dynamic', bound: false, parameters: [ 'to' ] },
          { name: 'goodbye', kind: 'dynamic', bound: false, parameters: [ 'to' ] } ]
      )