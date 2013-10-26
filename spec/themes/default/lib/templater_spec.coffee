Environment = require '../../../../lib/environment'
Templater = require '../../../../themes/default/lib/templater'

describe 'Templater', ->

  it 'parses all the templates', ->

    templater = new Templater(new Environment)
    expect(Object.keys(templater.JST)).toEqual(
      [ 'class.hamlc',
        'class_list.hamlc',
        'extra.hamlc',
        'extra_list.hamlc',
        'file.hamlc',
        'file_list.hamlc',
        'frames.hamlc',
        'index.hamlc',
        'method_list.hamlc',
        'mixin.hamlc',
        'mixin_list.hamlc',
        'partials/doc.hamlc',
        'partials/footer.hamlc',
        'partials/head.hamlc',
        'partials/header.hamlc',
        'partials/list_nav.hamlc',
        'partials/method_list.hamlc',
        'partials/method_summary.hamlc' ]
    )