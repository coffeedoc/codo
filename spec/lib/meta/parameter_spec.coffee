Parameter = require '../../../lib/meta/parameter'

describe 'Parameter', ->

  describe 'signature parsing', ->
    it 'understands basic stuff', ->

      expect(
        Parameter.fromSignature('#foo(a,b)').map (x) -> x.inspect()
      ).toEqual [
        {
          name: 'a'
          splat: false
        },
        {
          name: 'b',
          splat: false
        }
      ]

    it 'understands complex stuff', ->

      expect(
        Parameter.fromSignature('#foo({a,b}, x="test", y...)').map (x) -> x.inspect()
      ).toEqual [
        {
          name: '{a, b}'
          splat: false
        },
        {
          name: 'x',
          splat: false
          default: '"test"'
        },
        {
          name: 'y'
          splat: true
        }
      ]
