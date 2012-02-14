guard :coffeescript, :input => 'src', :output => 'lib'

guard 'process', :name => 'Jasmine specs', :command => 'jasmine-node --coffee --color spec/parser_spec.coffee' do
  watch(%r{src|spec})
end
