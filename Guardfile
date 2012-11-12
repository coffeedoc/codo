notification :gntp

group :codo do
  # CoffeeScript for the codo library
  guard :coffeescript, input: 'src', output: 'lib', noop: true

  # Run Jasmine specs
  guard :shell do
    jasmine_node = File.expand_path('../node_modules/jasmine-node/bin/jasmine-node', __FILE__)
    watch(%r{src|spec}) { `#{jasmine_node} --coffee --color spec/parser_spec.coffee` }
  end

  # Generate codo doc
  guard :shell do
    watch(%r{src|theme}) { `./bin/codo` }
  end
end

group :theme do
  # CoffeeScript for the default template
  guard :coffeescript, input: 'theme/default/src/coffee', output: 'theme/default/lib/scripts'

  # Compile the Compass style sheets
  guard :compass, configuration_file: 'config/compass.rb' do
    watch(%r{^theme\/default\/src\/styles\/(.*)\.scss})
  end

  # Pack assets with Jammit for NPM distribution
  guard :jammit, hide_success: true, public_root: 'theme/default' do
    watch(/^theme\/default\/lib\/scripts\/(.*)\.js$/)
    watch(/^theme\/default\/lib\/styles\/(.*)\.css$/)
  end

  # Pack assets with Jammit for LiveReload
  guard :jammit, public_root: 'doc' do
    watch(/^theme\/default\/lib\/scripts\/(.*)\.js$/)
    watch(/^theme\/default\/lib\/styles\/(.*)\.css$/)
  end

  # Load changes with LiveReload into browser
  guard :livereload do
    watch(%r{^doc\/(.+)$})
  end
end
