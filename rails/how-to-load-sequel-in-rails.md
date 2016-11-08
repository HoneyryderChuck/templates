# Sequel on Rails

## Why?

Because one day you decided you had enough of Active Record, and you want to do something about it and live with the (arguable) lack of add-ons. 

Stuff you can do with Sequel you can't do with AR:

* Postgresql 9.5 insert on conflict update
* Limit columns loaded, both in main instance as in the relations(!!)
* Composite Primary Keys
* Non-Model SQL manipulation

## How?

First, `sequel-rails` is your friend. It adds most of the rake tasks you need.

Second, remove all your migrations. You won't need them, I assume, as you'll only interested in the schema. 

The database table to store migration information (schema_migrations) will have to be updated. Follow the steps:

* empty the table
* delete `version` column
* add `filename:text` column and set it as primary key

After this, create some migration (the generator should work) and run `rake db:migrate`. 


After that:

```ruby
# Gemfile

%w(actionmailer actionpack actionview activejob activesupport railties).each do |subrails|
   gem subrails,          '4.2.7.1'
end
gem 'sequel',         '~> 4.35'


# config/application.rb
...
 
require 'rails'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'sprockets/railtie'

...

config.generators do |g|
  g.orm :sequel
  ...
end
...

# this is a collection of sequel plugins you can add so certain expectations from AR you had still work
# sequel loads plain vanilla, and some of the more complex features are opt-in
config.sequel.after_connect = proc do
  Sequel::Model.db.loggers << Rails.logger
 
  # touches timestamp columns on save
  Sequel::Model.plugin :timestamps, update_on_create: true

  # adds validation helpers ala AR (with a bit of different syntax)
  Sequel::Model.plugin :validation_helpers

  # so you can do car.brand? to know if it is set
  Sequel::Model.plugin :boolean_readers

  # sequel persists relations when you add stuff by default. this plugin delays it until you save.
  Sequel::Model.plugin :delay_add_association

  # to add default values to new instances
  Sequel::Model.plugin :defaults_setter

  # without this, most rails form helpers and such don't work
  Sequel::Model.plugin :active_model

  # inner join model instances will have weird values without this
  Sequel::Model.plugin :table_select

  # support for postgres array columns
  Sequel::Model.db.extension(:pg_array)

  # support for pagination, kaminari and will_paginate are rails-specific
  Sequel::Model.db.extension(:pagination)
  
  # enum columns, works fairly better than rails
  Sequel::Model.db.extension(:pg_enum)

  # to reset query objects when needed
  Sequel::Model.db.extension(:null_dataset)

  # pg array support
  Sequel.extension(:pg_array_ops)
 
  # don't break on save failed, instead return false like AR. It's controversial, I know. 
  Sequel::Model.raise_on_save_failure = false
end
``` 
