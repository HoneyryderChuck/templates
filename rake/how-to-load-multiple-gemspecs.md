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
