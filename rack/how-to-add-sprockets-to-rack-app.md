# Add sprockets

## Why?

Well, if you're not using nodeJS and Webpack. If your stack is ruby, you might want to add framework-independent assets loader. I don't know other than Sprockets. 

Contrary to what they say, Sprockets is not ruby-only (however, it's a pain to load).

## How?

Example is using Sinatra Helpers and Rails Assets (it has rails in name, but it's not rails):

```ruby
# config.ru
require "sinatra/sprockets-helpers"
class AssetsApp < Sinatra::Base
  register Sinatra::Sprockets::Helpers

  # env set
  set :sprockets, Sprockets::Environment.new(root)
  # pref in URL is assets/
  set :assets_prefix, '/assets'
  # digest only in prod
  set :digest_assets, (App.production?)
  # place where to write the digested assets
  set :assets_path, -> { File.join(root, 'public', 'assets') }
  # what to look for
  set :assets_precompile, %w(*.js *.css *.scss *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2 *.html)
  configure do
    %w{javascripts stylesheets images partials}.each do |type|
       sprockets.append_path File.join(root, 'app', 'assets', type)
     end
  end

  # Configure Sprockets::Helpers (if necessary)
  Sprockets::Helpers.configure do |config|
    config.environment = sprockets
    config.prefix      = assets_prefix
    config.digest      = digest_assets
    config.public_path = public_folder
    config.asset_host  = ENV["ASSET_DOMAIN"] if production?
    config.protocol    = :relative
  
    # Force to debug mode in development mode
    config.debug       = development?
    configure :production do
      sprockets.css_compressor = :sass
      sprockets.js_compressor = :uglifier
    end


    # Actual Rails Assets integration, everything else is Sprockets
    if defined?(RailsAssets)
      RailsAssets.load_paths.each do |path|
        settings.sprockets.append_path(path)
      end
    end
  end
end


class MyApp < Sinatra::Base
  helpers Sprockets::Helpers

  get "/" do
    erb :indx
  end
end

map Assets.assets_prefix do
  run Assets.sprockets
end

# taram!

run MyApp

__END__
layout.erb

!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>MyApp</title>
    <link rel="stylesheet" href="<%= stylesheet_path 'application' %>">
    <script src="<%= javascript_path 'application' %>"></script>
  </head>
  <body>
    <%= yield %>
  </body>
</html>

index.erb
<div>

</div>
```

