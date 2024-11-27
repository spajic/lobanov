# Lobanov [![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lobanov', github: 'spajic/lobanov', tag: 'v0.0.0' # see Changelog.md
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lobanov

## Why Lobanov
There is a couple of similar projects (see the section and comparison below)

What I see as key strong / unique points of Lobanov:
- Easy to introduce to large codebase. You just add `:lobanov` tag to one spec.
When another.
So you can start small. You can generate schema only for what you want.
- You can run just one spec to update the schema. No need to run all specs.
- It allows to modify schema by hand and keep the changes.
- No DSL. Nothing new to learn, just add `:lobanov` tag and you are all set.
- Ability to generate a directory with convenient structure for manual work
with openapi-schema. And automatically bundle it to single file for export.
- It validates the API response in your spec against stored schema. 
So you can prevent accidental breaking of contract.
- It automatically and consistently generates schema 
with Convention over Configuration approach. 
This leads to a clean and structured result, 
that would be difficult to do by hand, even having developer documentation
on how-to write openapi specs.
- It works both with controller specs and request specs.
- (We plan to) support sinatra to be able to use lobanov with microservices.
- Support for rails 6.1 and (we plan to) rails 7.0


### Flags

#### FORCE_LOBANOV
If this ENV-variable is set, all `:lobanov` tags would work as `:lobanov`

This may be useful in case whey you want to rebuild a bunch of schemas. 

#### UPDATE_TAGS
If this ENV-variable is set, `lobanov` would update tags of operations.

It would affect only operations covered by the specs that would be executed.

It would not validate schema.

It would merge existing tags with tags that would be calculated this time. 

This may be useful when `lobanov` logic of generating tags is being updated.
And you want to incorporate new tags to your schema.

In that case you should launch your complete test suite with `UPDATE_TAGS=1`.

## Alternatives and related projects

see docs/alternatives.md

### Configuration

In config/initializers/lobanov.rb

```ruby
Lobanov.configure do |config|
  config.specification_folder = 'openapi'
  config.namespaces = {
    'wapi' => 'wapi',
    'api/v6' => 'private/v6',
  }
end
```

With the above setup, Lobanov would work as following.

For api-calls to `/wapi/any_resource` it would maintain a subdirectory `openapi/wapi` with all the folders and files, describing this openapi schema.

For api-calls to `/api/v6/any_resource` it would maintain an analogous subdirectory `openapi/private/v6`.

For any other api-calls like `/any/other/root` it would maintain openapi description in the root of `openapi` folder.

## Development

### Publishing of new versions
For now we just use git tags like v0.1.1 and refer to them from Gemfile

We do not push to Rubygems now. 

### Specs

#### Cucumber

First of all, testing for lobanov is a bit intricated.

What we need to test is something like

```
If I have some rails app and some specs and some stored openapi schema
When I run rspec tests
What will be results of the specs run?
And how files will change?
```

To test this behavior we use `Cucumber` scenarios.

To run these scenarios use `bundle exec appraisal rails-61 cucumber` or `bin/cucum your_test_app_name`
To run scenarios for all test apps use `bin/cucum all`

#### Appraisal
Even more, we have to test lobanov with different versions of Rails.

Because the internals on which we rely to hook into rails routes may change.

To achieve this we use [Appraisal gem](https://github.com/thoughtbot/appraisal)

For now we only have rails-61 example app, but we have plans to support rails-7.

Execute `bundle exec appraisal install` to setup appraisal.

#### RSpec unit-tests
And also we have RSpec specs to test Lobanov internals in unit-test fashion.

Run the test suite with `rspec`

#### Generated rspec tests for test apps
And finally it may be useful to launch specs of generated 
test apps.

This may be handy for debug. If cucumber will encounter binding.pry during
it's execution it will halt. So to debug you may launch test-app spec directly. 

```
cd test_apps/rails_61
rspec spec/requests/fruits_controller_spec.rb
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spajic/lobanov.
