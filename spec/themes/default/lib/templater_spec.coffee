Environment = require '../../../../lib/environment'
Templater = require '../../../../themes/default/lib/templater'

describe 'Templater', ->

  it 'parses all the templates', ->

    templater = new Templater(new Environment)

    expect(Object.keys(templater.JST)).toEqual(
      [
        'alphabetical_index',
        'class',
        'class_list',
        'extra',
        'extra_list',
        'file',
        'file_list',
        'frames',
        'layout/footer',
        'layout/header',
        'layout/intro',
        'method_list',
        'mixin',
        'mixin_list',
        'partials/documentation',
        'partials/list_nav',
        'partials/method_list',
        'partials/method_signature',
        'partials/method_summary',
        'partials/type_link',
        'partials/variable_list'
      ]
    )