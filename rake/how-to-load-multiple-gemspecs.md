# How to load multiple gemspecs (the omnirepo feature)

## Why?

This is the base for supporting multiple gems in the same repository. This is important, as although it makes sense to publish separately, one develops against each gem, and specific versioning is required. 

Use-Case: the celluloid verse (using their own weird git submoduling), rails (using a variation of this)

## How?


```ruby
def gemspecs
  @gemspecs = begin
    basedir = Pathname.pwd
    gemspec_paths = Dir[File.join(basedir, "**", "{,*}.gemspec")]
    # love me some bundla
    gspecs = gemspec_paths.map { |path| Bundler.load_gemspec(path) }
    gspecs
  end
end

def name
  gemspecs.first.name
end

```

In Gemfiles, declare them separately

```ruby
# Gemfile
gemspec(path: "./firstgem")
gemspec(path: "./secondgem")
gemspec(path: "./thirdgem")
gemspec(path: "./forthgem")
``` 

If you're using rspec, you'll want to load the specs separately

```ruby
# as rake task
desc "run all specs"
RSpec::Core::RakeTask.new(:testall) do |t|
  pattern = gemspecs.map(&:name).join(',')
  t.pattern = t.pattern.insert(0, "{#{pattern}}/") # go to subdir
  t.rspec_opts = "--require ./{#{pattern}}/spec/spec_helper.rb" # load separate gemspec
end
