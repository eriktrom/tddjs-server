coffee_files = ->{watch("coffee/**/*.coffee")}

guard('process',
      name: 'compile coffee files',
      command: 'coffee -o ./ -cbl ./coffee/'
      ) do
  coffee_files.()
end

guard 'process', name: 'run node tests',
      command: 'mocha' do
  coffee_files.()
end

# :env => {"ENV1" => "value 1", "ENV2" => "value 2"},