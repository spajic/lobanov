## Next Release

## 0.9.0 (2023-03-16)
### Breaking
* Possibly break Ruby 2.6 compatibility

### New
* Support Ruby 3.0

## 0.8.2 (2023-03-13)
### Fix
* Fix a bug in UPDATE_TAGS in case when initial tags were emtpy.
In that case the resulting tags were `true`.

## 0.8.1 (2023-03-12)
### New
* Allow to UPDATE_TAGS:
set this ENV var and lobanov will update tags of operations.

## 0.8.0 (2023-03-08)
### New
* Group related endpoints with tags

* Update message in case of LOBANOV SCHEMA MISMATCH. 
Print the path to response file.

### Internal
* Make all cucumber scenarios green!
* Improve cucumber specs stability (stop using `Given an empty folder`)
* Add ability to setup a breakpoint in cucumber (`Given a breakpoint`)

## 0.7.4 (2023-02-22)

* Some users have different results of BundleSchema. They have trailing spaces. 
Add the postprocess step to BundleSchema and delete trailing spaces there.

## 0.7.3 (2023-02-17)

* Some bugs were found on 3commas specs after update to 0.7.2. Fix them here 

## 0.7.2 (2023-02-17)

* Support relative refs and registered components in Lobanov::Support::BundleSchema

## 0.7.1 (2023-02-13)

* Add support to bundle openapi schema into single file via Lobanov::Support (and without swagger-cli)

## 0.7.0 (2023-02-06)

* Add experimental support for multiple schemas (not only frontend/api-backend-specification and wapi)

## 0.6.5 (2023-02-06)

* Fix hardcoded path for frontend/api-backend-specification  (because of the issue some files were generated in hardcoded folder instead of configured folder)

## 0.6.4 (2022-06-08)

### Fixed

* Fix validation in case when all required properties are present but nulls.
* Fix output of MissingTypeOrExampleError: when group (examples / types) is empty it is omitted from output.

### Fixed

* Fix a crash when generating example for array and value is numeric.

## 0.6.3 (2022-05-27)

### Fixed

* Fix a crash when generating example for array and value is numeric.

## 0.6.2 (2022-05-26)

### Fixed

* Allow array to be empty when it has minItems: 0.

## 0.6.1 (2022-05-26)

### Fixed

* Fix validation fail for empty response (render json: {}). Missing examples and missing types error was raised.

## 0.6.0 (2022-05-24)

### Fixed

* Fix unreadable output of MissingTypeOrExampleError and replace useless stacktrace with (ノಠ益ಠ)ノ彡┻━┻

## 0.5.1 (2022-05-13)

### Fixed

* Fix a crash in case when field is optional and nullable in stored schema and in fact null.

## 0.5.0 (2022-05-10)

### New

* Support enums in schemas. Do not fail if enum is present in stored schema. Check that actual value belongs to enum.

## 0.4.1 (2022-05-06)

### Fixed

* Fixed version.rb to match release tag

## 0.4.0 (2022-05-06)

### Fixed

* Allow case than attr is nullable in stored schema, but present in new schema

## 0.3.0 (2022-04-19)

* `FORCE_LOBANOV` env variable added to force schemes rebuilding for all specs running with lobanov tag.
* Configured with standard rubocop code style. Considerable refactoring has been made.

## 0.2.0 (2022-04-09)

* Validation was added to make it mandatory to specify types and examples for fields in the existing response scheme.
