# [Master][]

- Remove `ActiveInteraction::Pipeline`.

# [0.8.0][] (2013-11-14)

- Add ability to document interactions and filters.

# [0.7.0][] (2013-11-14)

- Add ability to chain a series of interactions together with
  `ActiveInteraction::Pipeline`.

# [0.6.1][] (2013-11-14)

- Re-release. Forgot to merge into master.

# [0.6.0][] (2013-11-14)

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

# [0.1.0][] (2013-07-12)

- Initial release.

  [master]: https://github.com/orgsync/active_interaction/compare/v0.8.0...master
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
