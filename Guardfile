group :codo do
  # CoffeeScript for the codo library
  guard :coffeescript, :input => 'src', :output => 'lib'

  # Run Jasmine specs
  guard :shell do
    watch(%r{src|spec}) { `jasmine-node --coffee --color spec/parser_spec.coffee` }
  end
end

group :theme do
  # CoffeeScript for the default template
  guard :coffeescript, :input => 'theme/default/src/coffee', :output => 'theme/default/lib/scripts'

  # Compile the Compass style sheets
  guard :compass, :configuration_file => 'config/compass.rb' do
    watch(%r{^theme\/default\/src\/styles\/(.*)\.scss})
  end

  # Pack assets with Jammit for NPM distribution
  guard :jammit, :public_root => 'theme/default' do
    watch(/^theme\/default\/lib\/scripts\/(.*)\.js$/)
    watch(/^theme\/default\/lib\/styles\/(.*)\.css$/)
  end

  # Pack assets with Jammit for LiveReload
  guard :jammit, :public_root => 'doc' do
    watch(/^theme\/default\/lib\/scripts\/(.*)\.js$/)
    watch(/^theme\/default\/lib\/styles\/(.*)\.css$/)
  end

  # Load changes with LiveReload into browser
  guard :livereload do
    watch(%r{^doc\/assets\/codo\.css$}) { 'doc/assets/codo.css' }
    watch(%r{^doc\/assets\/codo\.js}) { 'doc/assets/codo.js' }
  end
end
