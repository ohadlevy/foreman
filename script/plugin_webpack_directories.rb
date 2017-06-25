#! /usr/bin/env ruby

require 'bundler'
require 'json'

PLUGIN_NAME_REGEXP = /foreman*|katello*/

# Only works for local dependencies
paths = {}
Bundler.load.specs.each do |dep|
  # skip other rails engines that are not plugins
  # TOOD: Consider using the plugin registeration api?
  next unless dep.name =~ PLUGIN_NAME_REGEXP
  bundle = "#{dep.to_spec.full_gem_path}/webpack/index.js"
  # some plugings share the same base directory (tasks-core and tasks, REX etc)
  # skip the plugin if its path is already included
  next if paths.values.include?(bundle)
  paths[dep.name] = bundle if File.exist?(bundle)
end

puts paths.to_json
