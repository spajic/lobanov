## Next Release

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
