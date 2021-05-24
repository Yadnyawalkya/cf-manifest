require "bundler"

# prerequisite to have Gemfile in working directory
bundle = Bundler::Definition.build('Gemfile', nil, {}).dependencies

for item in bundle do
    STDOUT.puts item.to_s.sub(' ', '-')
end
