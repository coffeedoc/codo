# CoffeeScript for the codo library
guard :coffeescript, :input => 'src', :output => 'lib'

# CoffeeScript for the default template
guard :coffeescript, :input => 'theme/default/src/coffee', :output => 'theme/default/lib/scripts'

# Compile the Compass style sheets
guard :compass, :configuration_file => 'config/compass.rb' do
  watch(%r{^theme\/default\/src\/styles\/(.*)\.scss})
end

# Pack assets with Jammit
guard :jammit, :public_root => 'theme/default' do
  watch(/^theme\/default\/lib\/scripts\/(.*)\.js$/)
  watch(/^theme\/default\/lib\/styles\/(.*)\.css$/)
end

# Run Jasmine specs
guard :shell do
  watch(%r{src|spec}) { `jasmine-node --coffee --color spec/parser_spec.coffee` }
end
