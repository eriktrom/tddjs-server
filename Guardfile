coffee_files = ->{watch(%r{coffee/.+\.coffee})}

guard('process',
      name: 'compile coffee files',
      command: 'coffee -o js/ -cbl coffee/'
      ) do
  coffee_files.()
end

# guard 'process', name: 'run node tests', dont_stop: true, stop_signal: 'KILL',
#       command: 'mocha' do
#   coffee_files.()
# end

# :env => {"ENV1" => "value 1", "ENV2" => "value 2"},