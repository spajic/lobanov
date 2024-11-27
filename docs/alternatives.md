# Alternatives

### expego/rspec-openapi

https://github.com/exoego/rspec-openapi

Overall very nice project, it has many things done just right.

Key differences:
- it does not validate spec to conform with schema, it always updates schema
- it relies on running all specs to generate a single large openapi bundle
- it suppose to exclude specs from schema generation with `openapi: false`, rather than include with `:lobanov`
- it does not generate structured representation with multiple files, just one huge bundle

Questions:
- does it really work with controller specs?

Some points:
- Generate OpenAPI schema from RSpec request specs (there is a setting RSpec::OpenAPI.example_types)
- stars: 273
- Generate openapi from specs without requiring any special DSL
- Keeps manual modifications on merging automated changes!
- Usage: `OPENAPI=1 bundle exec rspec`
- For specs `type: :request`
- Support generating multiple schema files splitting by spec file prefix (and maybe by other logic based on example's properties)
- Support refs and automatically refactors to components given ref to registered component
- You can exclude spec from generation with `openapi: false` tag (`lobanov` goes the opposite way)
- some attributes can be overwritten via RSpec metadata options (`lobanov` has zero DSL)
- has very reasonable Settings to configure all aspects of openapi index and other configurables
- does not support `required`: https://github.com/exoego/rspec-openapi/issues/89
- relies on run of all specs and deletes parts of index.yaml that was not covered by tests
- *does not validate schema but rather updates it with merge*
- generates one large file, not a folder with a multi-file structure


### rswag/rswag
https://github.com/rswag/rswag

For me the showstopper here is that you have to effectively *write spec by hand, but in DSL*

For me it is too tedious. And than I tried to work with rswag I very soon get stuck with that DSL - I didn't understand how can I achieve the required result through the DSL.

Questions:
- does it support controller specs?

Some points:
- stars: 1600
- it validates responses to conform with the schema
- supports request-specs
- heavy usage of Swagger-based DSL
- usage: write DSL to describe your API operations -> (it automatically run tests) -> run a rake task to generate swagger files
- effectively you have to *write open-api schema by hand* in the form of DSL

### rspec-rails-swagger


### rspec_api_documentation

### r7kamura/autodoc
That was the inspiration for rspec-openapi

### lurker
