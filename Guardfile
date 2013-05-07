guard('process',
      name: 'compile coffee files',
      command: 'coffee -o js/ -cbl coffee/'
      ) do
  watch(%r{coffee/.+\.coffee})
end

guard 'process', name: 'run node tests', stop_signal: 'KILL',
      command: 'mocha --compilers coffee:coffee-script' do
  # we would just watch the coffee files, which was working, but I noticed
  # sometimes it wasn't picking up the changes the way mocha on its own was,
  # so perhaphs, to make sure that we don't run the test before compiling the
  # the new js, run the tests only when js/*.js files change or when the
  # coffeescript only test files are changed, but NOT when application(yet to
  # be compiled) coffee files change
  watch(%r{test/.+\.coffee})
  watch(%r{js/.+\.js})
end

# :env => {"ENV1" => "value 1", "ENV2" => "value 2"},