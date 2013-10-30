TreeBuilder = require '../../../../themes/default/lib/tree_builder'

describe 'Tree Builder', ->

  it 'builds proper tree', ->

    data = [
      {name: 'foo.bar'},
      {name: 'foo.bar.baz'},
      {name: 'foo.baz'},
      {name: 'dummy'}
    ]

    builder = new TreeBuilder data, (entry) ->
      path = entry.name.split('.')
      [path.pop(), path]

    expect(builder.tree).toEqual [
      {
        name:'foo',
        children:[
          {
            name:'bar',
            children:[
              {
                name:'baz',
                children:[],
                entity:{
                  name:'foo.bar.baz'
                }
              }
            ],
            entity:{
              name:'foo.bar'
            }
          },
          {
            name:'baz',
            children:[],
            entity:{
              name:'foo.baz'
            }
          }
        ],
        entity:undefined
      },
      {
        name:'dummy',
        children:[],
        entity:{
          name:'dummy'
        }
      }
    ]