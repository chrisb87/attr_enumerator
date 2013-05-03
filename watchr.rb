#!/usr/bin/env watchr

def run(cmd)
  full_command = "bundle exec rspec #{cmd}"
  puts(full_command)
  system(full_command)
end

def run_all
  run("spec")
end

watch( '^lib/(.*)\.rb'         ) { |m| run("spec/%s_spec.rb" % m[1]) }
watch( '^spec/spec_helper\.rb' ) { run_all }
watch( '^spec.*/.*_spec\.rb'   ) { |m| run(m[0]) }

puts "watchr ready"
