require "bundler"

# prerequisite to have Gemfile.lock in working directory
bundle = Bundler::LockfileParser.new(Bundler.read_file('Gemfile.lock'))

gem_name_version_map = bundle.specs.map { |spec|
  [
    spec.name,
    spec.version.to_s,
  ]
}

STDOUT.puts gem_name_version_map.map { |pair| pair.join("-") }
