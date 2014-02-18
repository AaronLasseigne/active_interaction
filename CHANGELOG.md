# [Master][]

- Allow callable defaults.
- Only set instance variables for attributes with readers defined.
- Support `:only` and `:except` options simultaneously with `import_filters`.
  Previously this raised an `ArgumentError`.
- Support passing a single symbol to `:only` and `:except`. Previously an Array
  was required.
- Speed up many filters by caching class constants.
- Add support for callbacks around `execute`.

# [1.0.4][] (2014-02-11)

- Add translations to the gem specification.

# ~~[1.0.3][] (2014-02-11)~~

- Fix a bug that caused invalid strings to be parsed as `nil` instead of
  raising an error when `Time.zone` was set.
- Fix bug that prevented loading I18n translations.

# [1.0.2][] (2014-02-07)

- Stop creating duplicate errors on subsequent calls to `valid?`.

# [1.0.1][] (2014-02-04)

- Short circuit `valid?` after successfully running an interaction.
- Fix a bug that prevented merging interpolated symbolic errors.
- Use `:invalid_type` instead of `:invalid` as I18n key for type errors.
- Fix a bug that skipped setting up accessors for imported filters.

# [1.0.0][] (2014-01-21)

- **Replace `Filters` with a hash.** To iterate over `Filter` objects, use
  `Interaction.filters.values`.
- Rename `Filter#has_default?` to `Filter#default?`.
- Add `respond_to_missing?` to complement `method_missing` calls.
- Add predicate methods for checking if an input was passed.
- When adding a filter that shares a name with an existing filter, it will now
  replace the existing one instead of adding a duplicate.
- Allow fetching filters by name.
- Allow import filters from another interaction with `import_filters`.

# [0.10.2][] (2014-01-02)

- Fix a bug that marked Time instances as invalid if Time.zone was set.

# [0.10.1][] (2013-12-20)

- Fix bug that prevented parsing strings as times when ActiveSupport was
  available.

# [0.10.0][] (2013-12-19)

- Support casting "true" and "false" as booleans.
- Fix bug that allowed subclasses to mutate the filters on their superclasses.

# [0.9.1][] (2013-12-17)

- Fix I18n deprecation warning.
- Raise `ArgumentError` when running an interaction with non-hash inputs.
- For compatibility with `ActiveRecord::Errors`, support indifferent access of
  `ActiveInteraction::Errors`.
- Fix losing filters when using inheritance.

# [0.9.0][] (2013-12-02)

- Add experimental composition implementation
  (`ActiveInteraction::Base#compose`).
- Remove `ActiveInteraction::Pipeline`.

# [0.8.0][] (2013-11-14)

- Add ability to document interactions and filters.

# [0.7.0][] (2013-11-14)

- Add ability to chain a series of interactions together with
  `ActiveInteraction::Pipeline`.

# [0.6.1][] (2013-11-14)

- Re-release. Forgot to merge into master.

# ~~[0.6.0][] (2013-11-14)~~

- **Error class now end with `Error`.**
- **By default, strip unlisted keys from hashes. To retain the old behavior,
  set `strip: false` on a hash filter.**
- **Prevent specifying defaults (other than `nil` or `{}`) on hash filters. Set
  defaults on the nested filters instead.**
- Add ability to introspect interactions with `filters`.
- Fix bug that prevented listing multiple attributes in a hash filter.
- Allow getting all of the user-supplied inputs in an interaction with
  `inputs`.
- Fix bug that prevented hash filters from being nested in array filters.
- Replace `allow_nil: true` with `default: nil`.
- Add a symbol filter.
- Allow adding symbolic errors with `errors.add_sym` and retrieving them with
  `errors.symbolic`.

# [0.5.0][] (2013-10-16)

- Allow adding errors in `execute` method with `errors.add`.
- Prevent manually setting the outcome's result.

# [0.4.0][] (2013-08-15)

- Support i18n translations.

# [0.3.0][] (2013-08-07)

- Give better error messages for nested attributes.
- Use default value when given an explicit `nil`.
- Allow nested default values.

# [0.2.2][] (2013-08-07)

- Fix support for `ActiveSupport::TimeWithZone`.

# [0.2.1][] (2013-08-06)

- Fix setting a default value on more than one attribute at a time.

# [0.2.0][] (2013-07-16)

- Wrap interactions in ActiveRecord transactions if they're available.
- Add option to strip string values, which is enabled by default.
- Add support for strptime format strings on Date, DateTime, and Time filters.

# [0.1.3][] (2013-07-16)

- Fix bug that prevented `attr_accessor`s from working.
- Handle unconfigured timezones.
- Use RDoc as YARD's Markdown provider instead of kramdown.

# [0.1.2][] (2013-07-14)

- `execute` will now have the filtered version of the values passed
  to `run` or `run!` as was intended.

# [0.1.1][] (2013-07-13)

- Correct gemspec dependencies on activemodel.

# ~~[0.1.0][] (2013-07-12)~~

- Initial release.

  [master]: https://github.com/orgsync/active_interaction/compare/v1.0.4...master
  [1.0.4]: https://github.com/orgsync/active_interaction/compare/v1.0.3...v1.0.4
  [1.0.3]: https://github.com/orgsync/active_interaction/compare/v1.0.2...v1.0.3
  [1.0.2]: https://github.com/orgsync/active_interaction/compare/v1.0.1...v1.0.2
  [1.0.1]: https://github.com/orgsync/active_interaction/compare/v1.0.0...v1.0.1
  [1.0.0]: https://github.com/orgsync/active_interaction/compare/v0.10.2...v1.0.0
  [0.10.2]: https://github.com/orgsync/active_interaction/compare/v0.10.1...v0.10.2
  [0.10.1]: https://github.com/orgsync/active_interaction/compare/v0.10.0...v0.10.1
  [0.10.0]: https://github.com/orgsync/active_interaction/compare/v0.9.1...v0.10.0
  [0.9.1]: https://github.com/orgsync/active_interaction/compare/v0.9.0...v0.9.1
  [0.9.0]: https://github.com/orgsync/active_interaction/compare/v0.8.0...v0.9.0
  [0.8.0]: https://github.com/orgsync/active_interaction/compare/v0.7.0...v0.8.0
  [0.7.0]: https://github.com/orgsync/active_interaction/compare/v0.6.1...v0.7.0
  [0.6.1]: https://github.com/orgsync/active_interaction/compare/v0.6.0...v0.6.1
  [0.6.0]: https://github.com/orgsync/active_interaction/compare/v0.5.0...v0.6.0
  [0.5.0]: https://github.com/orgsync/active_interaction/compare/v0.4.0...v0.5.0
  [0.4.0]: https://github.com/orgsync/active_interaction/compare/v0.3.0...v0.4.0
  [0.3.0]: https://github.com/orgsync/active_interaction/compare/v0.2.2...v0.3.0
  [0.2.2]: https://github.com/orgsync/active_interaction/compare/v0.2.1...v0.2.2
  [0.2.1]: https://github.com/orgsync/active_interaction/compare/v0.2.0...v0.2.1
  [0.2.0]: https://github.com/orgsync/active_interaction/compare/v0.1.3...v0.2.0
  [0.1.3]: https://github.com/orgsync/active_interaction/compare/v0.1.2...v0.1.3
  [0.1.2]: https://github.com/orgsync/active_interaction/compare/v0.1.1...v0.1.2
  [0.1.1]: https://github.com/orgsync/active_interaction/compare/v0.1.0...v0.1.1
  [0.1.0]: https://github.com/orgsync/active_interaction/compare/62f999b...v0.1.0
