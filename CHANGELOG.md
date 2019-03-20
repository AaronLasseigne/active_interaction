# [3.7.1][] (2019-03-20)

## Fixed

- [#455][] Switch to `BigDecimal()` to avoid warnings in Ruby 2.6.
- [#457][] When using an after callback on `execute` the `:if` option does not see composed errors.

# [3.7.0][] (2019-02-10)

## Added

- [#454][] Support for Rails 6.

## Fixed

- [#435][] Errors using the `:message` option were not properly merged.

# [3.6.2][] (2018-08-21)

## Fixed

- [#411][] Cache the result of outcome validations. This also resolves duplicate callbacks on composed interactions.

# [3.6.1][] (2017-11-12)

## Fixed

- [#429][] Pass details on translated detailed errors.

# [3.6.0][] (2017-10-20)

## Added

- [#422][] A new `record` filter that accepts an object or calls a finder (e.g. `find`) for the value passed. This is particularly useful for ActiveRecord objects.
- [#420][] A `converter` option on the `object` filter that allows the value passed to be manually converted into an object of the correct type.

# [3.5.3][] (2017-09-28)

## Fixed

- [#425][] where `given?` did not properly handle string keys for hashes with nested content

# [3.5.2][] (2017-06-08)

## Fixed

- [#417][] - detailed errors added to `:base` are now properly merged

# [3.5.1][] (2017-05-11)

## Fixed

- [#415][]: Reserved input names no longer error. Instead they are ignored. This fixes an issue with Rails 5.1 where `:format` was part of the params input sent to the interaction.

# [3.5.0][] (2017-03-18)

## Added

- [#408][]: `given?` can now check for values in nested hashes within the input

# [3.4.0][] (2016-10-20)

## Added

- [#387][]: Added an option to the `integer` filter to allow specification of a base when converting strings.

## Fixed

- [#384][]: Fixed wrapping `compose` call in an ActiveRecord transaction.

# [3.3.0][] (2016-09-13)

## Added

- [#383][]: Allowed `ActionController::Parameters` as the input to `ActiveInteraction::Base.run`. Previously only `Hash` was allowed.

# [3.2.1][] (2016-08-26)

## Fixed

- [#377][]: Fixed a bug that allowed interactions to define inputs the conflicted with `ActiveInteraction::Base`'s methods.
- [#370][]: Improved the French translation. Thanks, @voondo!

# [3.2.0][] (2016-06-07)

## Added

- [#365][]: Updated boolean filter to accept `"on"` for `true` and `"off"` for `false`. Thanks, @voondo!

# [3.1.1][] (2016-05-31)

## Added

- [#362][]: Added translation for Brazilian Portuguese.

## Fixed

- [#364][]: Fixed a bug that prevented callbacks from being called by composed interactions that failed.

# [3.1.0][] (2016-04-01)

## Added

- [#357][]: Allowed default lambdas to take an optional filter argument.

# [3.0.1][] (2016-01-15)

## Fixed

- [#349][]: Merging errors on `:base` with a message that was a `String` attempted to translate it.

# [3.0.0][] (2016-01-13)

## Changed

- [#333][]: Copy symbolic errors when using `compose`.

## Removed

- [#344][]: Support for Ruby 1.9.3.
- [#346][]: Support for ActiveModel 3.2.

## Upgrading

Symbolic errors from composed interactions are now copied to their
equivalently named filters on the parent interaction. This can cause
some odd cases as noted in the the [README](README.md#errors).

# [2.2.0][] (2015-12-18)

## Added

- [#336][]: Added frozen string pragma for Ruby 2.3.

## Changed

- [#332][]: Changed default lambdas to be evaluated in the interaction's
  binding.

# [2.1.5][] (2015-12-11)

## Added

- [#330][]: Added a French translation.

# [2.1.4][] (2015-11-03)

## Fixed

- [#320][]: Stopped requiring ActiveRecord.

## Added

- [#310][]: Added a warning when a filter is redefined.

## Changed

- [#311][]: Changed the error message when defining the default value for a
  hash.

# [2.1.3][] (2015-10-02)

## Fixed

- [#303][]: Allowed ActiveRecord associations as inputs to array filters.

## Changed

- [#304][]: Improved the error message for object filters when the class does
  not exist.

# [2.1.2][] (2015-09-03)

## Fixed

- [#298][]: Fixed a bug that raised exceptions when passing invalid nested
  values.

# [2.1.1][] (2015-08-04)

## Fixed

- [#296][]: Fixed a bug that silently converted invalid lazy default values to
  `nil` instead of raising an `InvalidDefaultError`.

# [2.1.0][] (2015-07-30)

## Added

- [#295][]: Added `given?` predicate method to see if an input was passed to
  `run`.

# [2.0.1][] (2015-05-27)

## Fixed

- [#286][]: Change `file` filter to check for `rewind` instead of `eof?`.
- [#289][]: Actually removed `model` filter, which was deprecated in v1.6.0.

# [2.0.0][] (2015-05-06)

## Changed

- [#250][]: Replaced symbolic errors with Rails 5-style detailed errors.
- [#269][]: Prevented proc defaults from being eagerly evaluated.
- [#264][]: Renamed `model` filter to `object`.
- [#213][]: Remove transaction support. Database transactions will need to be
  handled manually now.
- [#214][]: Results are returned from invalid outcomes.
- [#164][]: Changed the `hash` filter to use hashes with indifferent access.
- [#236][]: Changed the `file` filter to accept anything that responds to `eof?`.

## Security

- [#215][]: Rather than symbolizing keys all hashes now use indifferent access.
  This takes care of potential but unlikely DoS attacks noted in [#163][].

## Upgrading

Please read through the Changed section for a full list of changes.

The contents of the `execute` method are no longer wrapped in a transaction. You
can manually add a transaction if you need it by using
`ActiveRecord::Base.transaction`. We've also removed the `transaction` method since
it no longer has a use.

```ruby
# v1.6
class Example < ActiveInteraction::Base
  # This is the default.
  transaction true

  def execute
    # ...
  end
end

# v2.0
class Example < ActiveInteraction::Base
  def execute
    ActiveRecord::Base.transaction do
      # ...
    end
  end
end
```

Symbolic errors should now be added with `add` instead of `add_sym`. Additionally,
you can view the errors with `details` instead of `symbolic`. This aligns with the
direction Rails is taking.

```ruby
# v1.6
class Example < ActiveInteraction::Base
  def execute
    errors.add_sym :base, :invalid
    errors.add_sym :base, :custom, '...'
  end
end
Example.run.errors.symbolic
# => {:base=>[:invalid,:custom]}

# v2.0
class Example < ActiveInteraction::Base
  def execute
    errors.add :base, :invalid
    errors.add :base, :custom, message: '...'
  end
end
Example.run.errors.details
# => {:base=>[{:error=>:invalid},{:error=>:custom,:message=>'...'}]}
```

In the `hash` filter we've stopped converting all inputs to symbols and instead we
now convert the hash to a hash with indifferent access. This means hash keys will
display as strings instead of symbols.

```ruby
class Example < ActiveInteraction::Base
  hash :options,
    strip: false

  def execute
    options.keys
  end
end

# v1.6
Example.run!(options: { enable: true })
# => [:enable]

# v2.0
Example.run!(options: { enable: true })
# => ["enable"]
```

We added the ability to return results from invalid interactions. Setting the result to
`nil` was unnecessary. The right way to check for validity is to use `valid?`. This change
allows you to return something from an interaction even if there are errors. This can be
very useful when updating an existing record.

```ruby
class Example < ActiveInteraction::Base
  def execute
    errors.add(:base)
    'something'
  end
end

# v1.6
outcome = Example.run
outcome.valid?
# => false
outcome.result
# => nil

# v2.0
outcome = Example.run
outcome.valid?
# => false
outcome.result
# => "something"
```

When setting a default with a `Proc` is is no longer eagerly evaluated.

```ruby
class Example < ActiveInteraction::Base
  boolean :flag,
    default: -> {
      puts 'defaulting...'
      true
    }

  def execute
    puts 'executing...'
  end
end

# v1.6
# defaulting...
Example.run
# executing...

# v2.0
Example.run
# defaulting...
# executing...
```

# [1.6.1][] (2015-10-02)

## Fixed

- [#303][]: Allowed ActiveRecord associations as inputs to array filters.

# [1.6.0][] (2015-05-06)

## Added

- Added `object` as an alias for `model`.
- Added symbol support to `add`.
- Added `details` as an alternative to `symbolic`.

## Changed

- Deprecated `model` in favor of `object`.
- Deprecated `add_sym` in favor of `add`.
- Deprecated `transaction`.
- Deprecated `symbolic` in favor of `details`.

# [1.5.1][] (2015-04-28)

## Fixed

- [#265][]: Allow `nil` inputs for interface and model filters.
- [#256][]: Improve error messages for nested invalid values.

# [1.5.0][] (2015-02-05)

## Added

- [#248][]: Add `has_attribute?` support to an instance of an interaction.

## Fixed

- [#248][]: Fix support for simple_form gem.

# [1.4.1][] (2014-12-12)

## Fixed

- [#244][]: Fix improperly adding load paths to I18n.

# [1.4.0][] (2014-12-10)

## Changed

- [#239][]: Accept `ActiveRecord::Relation` objects as `array` inputs.

# [1.3.1][] (2014-12-10)

## Fixed

- [#235][]: Fix a bug that prevented custom translations from loading.
- [#224][]: Fix a bug that incorrectly inferred plural class names for filters
  inside arrays.

# [1.3.0][] (2014-08-15)

## Added

- [#178][]: Add an interface filter.
- [#196][]: Add a `type_check` callback that happens before the `validation`
  callback.

# [1.2.5][] (2014-08-15)

## Fixed

- [#207][]: Fix a bug that incorrectly converted plural class names
  to their singular form.
- [#206][]: Fix a bug that caused an i18n deprecation warning.
- [#201][]: Prevented time filters from being initialized with the
  format option when time zones are available.

# [1.2.4][] (2014-08-07)

## Fixed

- [#203][]: Fix a bug that prevented transaction options from being passed to
  subclasses.

# [1.2.3][] (2014-05-12)

## Fixed

- [#192][]: Fix a bug that raised `ActiveRecord::Rollback` when composing even
  when not in a transaction.

# [1.2.2][] (2014-05-07)

## Fixed

- Fix a bug that raised `NameError`s when there were invalid nested hash
  errors.
- Add missing translation for symbol filters.

# [1.2.1][] (2014-05-02)

## Fixed

- [#179][]: Fix a bug that marked model inputs as invalid even if they returned true
  for `object.is_a?(klass)`.

# [1.2.0][] (2014-04-30)

## Added

- [#175][]: Add support for Rails-style date and time parameters like `date(1i)`.
- [#173][]: Add a decimal filter.
- [#155][]: Add support for disabling and modifying transactions through the
  `transaction` helper method.
- [#140][]: Add support for `column_for_attribute` which provides better
  interoperability with gems like Formtastic and Simple Form.

# [1.1.7][] (2014-04-30)

## Fixed

- [#174][]: Fix a bug that leaked validators among all child classes.

# [1.1.6][] (2014-04-29)

## Fixed

- [#36][]: Fix a bug that caused nested hash error messages to be misleading.

# [1.1.5][] (2014-03-31)

## Fixed

- The `transform_keys` method broke backwards compatibility because it's not
  available until Rails 4.0.2.

# [1.1.4][] (2014-03-31)

## Fixed

- Fix an issue where non-stripped hash keys would be incorrectly converted to strings.

# [1.1.3][] (2014-03-31)

## Fixed

- [#165][]: Fix Rubocop errors and pin the version to avoid future issues with new cops
  breaking the build.

## Security

- [#163][]: Fix some denial of service attacks via hash symbolization.

# [1.1.2][] (2014-03-05)

## Fixed

- [#156][]: Don't constantize classes for model filters on initialization. This fixes a
  bug that made those filters dependent on load order.

# [1.1.1][] (2014-03-04)

## Fixed

- [#153][]: Allow merging ActiveModel errors into ActiveInteraction errors with
  `ActiveInteraction::Errors#merge!`.

# [1.1.0][] (2014-02-28)

## Added

- [#116][], [#119][], [#122][]: Speed up many filters by caching class constants.
- [#115][]: Add support for callbacks around `execute`.
- [#136][]: Allow callable defaults.

## Changed

- [#114][]: Support `:only` and `:except` options simultaneously with `import_filters`.
  Previously this raised an `ArgumentError`.
- [#114][]: Support passing a single symbol to `:only` and `:except`. Previously an Array
  was required.

## Security

- [#138][]: Only set instance variables for attributes with readers defined.


# [1.0.5][] (2014-02-25)

## Fixed

- [#143][]: Rollback database changes when `compose` fails.

# [1.0.4][] (2014-02-11)

## Fixed

- Add translations to the gem specification.

# ~~[1.0.3][] (2014-02-11)~~

## Fixed

- [#135][]: Fix a bug that caused invalid strings to be parsed as `nil` instead of
  raising an error when `Time.zone` was set.
- [#134][]: Fix bug that prevented loading I18n translations.

# [1.0.2][] (2014-02-07)

## Fixed

- [#130][]: Stop creating duplicate errors on subsequent calls to `valid?`.

# [1.0.1][] (2014-02-04)

## Fixed

- [#125][]: Short circuit `valid?` after successfully running an interaction.
- [#129][]: Fix a bug that prevented merging interpolated symbolic errors.
- [#128][]: Use `:invalid_type` instead of `:invalid` as I18n key for type errors.
- [#127][]: Fix a bug that skipped setting up accessors for imported filters.

# [1.0.0][] (2014-01-21)

## Added

- [#102][]: Add predicate methods for checking if an input was passed.
- [#103][]: Allow fetching filters by name.
- [#104][]: Allow import filters from another interaction with `import_filters`.

## Changed

- [#111][]: Replace `Filters` with a hash. To iterate over `Filter` objects, use
  `Interaction.filters.values`.
- Rename `Filter#has_default?` to `Filter#default?`.

## Fixed

- [#98][]: Add `respond_to_missing?` to complement `method_missing` calls.
- [#106][]: When adding a filter that shares a name with an existing filter, it will now
  replace the existing one instead of adding a duplicate.

# [0.10.2][] (2014-01-02)

## Fixed

- [#94][]: Fix a bug that marked Time instances as invalid if Time.zone was set.

# [0.10.1][] (2013-12-20)

## Fixed

- [#90][]: Fix bug that prevented parsing strings as times when ActiveSupport was
  available.

# [0.10.0][] (2013-12-19)

## Added

- Support casting "true" and "false" as booleans.

## Fixed

- [#89][]: Fix bug that allowed subclasses to mutate the filters on their superclasses.

# [0.9.1][] (2013-12-17)

## Fixed

- [#84][]: Fix I18n deprecation warning.
- [#82][]: Raise `ArgumentError` when running an interaction with non-hash inputs.
- [#77][]: For compatibility with `ActiveRecord::Errors`, support indifferent access of
  `ActiveInteraction::Errors`.
- [#88][]: Fix losing filters when using inheritance.

# [0.9.0][] (2013-12-02)

## Added

- Add experimental composition implementation (`ActiveInteraction::Base#compose`).

## Removed

- Remove `ActiveInteraction::Pipeline`.

# [0.8.0][] (2013-11-14)

## Added

- [#44][], [#45][]: Add ability to document interactions and filters.

# [0.7.0][] (2013-11-14)

## Added

- [#41][]: Add ability to chain a series of interactions together with
  `ActiveInteraction::Pipeline`.

# [0.6.1][] (2013-11-14)

## Fixed

- Re-release. Forgot to merge into master.

# ~~[0.6.0][] (2013-11-14)~~

## Added

- Add ability to introspect interactions with `filters`.
- [#57][]: Allow getting all of the user-supplied inputs in an interaction with
  `inputs`.
- [#61][]: Add a symbol filter.
- [#58][]: Allow adding symbolic errors with `errors.add_sym` and retrieving them with
  `errors.symbolic`.

## Changed

- Error class now end with `Error`.
- By default, strip unlisted keys from hashes. To retain the old behavior,
  set `strip: false` on a hash filter.
- [#49][]: Prevent specifying defaults (other than `nil` or `{}`) on hash filters. Set
  defaults on the nested filters instead.
- [#66][]: Replace `allow_nil: true` with `default: nil`.

## Fixed

- Fix bug that prevented listing multiple attributes in a hash filter.
- Fix bug that prevented hash filters from being nested in array filters.

# [0.5.0][] (2013-10-16)

## Added

- [#34][]: Allow adding errors in `execute` method with `errors.add`.

## Fixed

- [#56][]: Prevent manually setting the outcome's result.

# [0.4.0][] (2013-08-15)

## Added

- Support i18n translations.

# [0.3.0][] (2013-08-07)

## Added

- [#30][]: Allow nested default values.

## Changed

- [#36][]: Give better error messages for nested attributes.
- [#39][]: Add a more useful invalid interaction error message.
- [#38][]: Use default value when given an explicit `nil`.

# [0.2.2][] (2013-08-07)

## Fixed

- [#40][]: Fix support for `ActiveSupport::TimeWithZone`.

# [0.2.1][] (2013-08-06)

## Fixed

- [#37][]: Fix setting a default value on more than one attribute at a time.

# [0.2.0][] (2013-07-16)

## Added

- [#23][]: Add support for strptime format strings on Date, DateTime, and Time filters.

## Changed

- [#20][]: Wrap interactions in ActiveRecord transactions if they're available.
- [#24][]: Add option to strip string values, which is enabled by default.

# [0.1.3][] (2013-07-16)

## Fixed

- Fix bug that prevented `attr_accessor`s from working.
- Handle unconfigured timezones.
- [#27][]: Use RDoc as YARD's Markdown provider instead of kramdown.

# [0.1.2][] (2013-07-14)

## Fixed

- [#29][]: `execute` will now have the filtered version of the values passed
  to `run` or `run!` as was intended.

# [0.1.1][] (2013-07-13)

## Fixed

- [#28][]: Correct gemspec dependencies on activemodel.

# ~~[0.1.0][] (2013-07-12)~~

- Initial release.

  [3.7.1]: https://github.com/AaronLasseigne/active_interaction/compare/v3.7.0...v3.7.1
  [3.7.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.6.2...v3.7.0
  [3.6.2]: https://github.com/AaronLasseigne/active_interaction/compare/v3.6.1...v3.6.2
  [3.6.1]: https://github.com/AaronLasseigne/active_interaction/compare/v3.6.0...v3.6.1
  [3.6.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.5.3...v3.6.0
  [3.5.3]: https://github.com/AaronLasseigne/active_interaction/compare/v3.5.2...v3.5.3
  [3.5.2]: https://github.com/AaronLasseigne/active_interaction/compare/v3.5.1...v3.5.2
  [3.5.1]: https://github.com/AaronLasseigne/active_interaction/compare/v3.5.0...v3.5.1
  [3.5.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.4.0...v3.5.0
  [3.4.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.3.0...v3.4.0
  [3.3.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.2.1...v3.3.0
  [3.2.1]: https://github.com/AaronLasseigne/active_interaction/compare/v3.2.0...v3.2.1
  [3.2.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.1.1...v3.2.0
  [3.1.1]: https://github.com/AaronLasseigne/active_interaction/compare/v3.1.0...v3.1.1
  [3.1.0]: https://github.com/AaronLasseigne/active_interaction/compare/v3.0.1...v3.1.0
  [3.0.1]: https://github.com/AaronLasseigne/active_interaction/compare/v3.0.0...v3.0.1
  [3.0.0]: https://github.com/AaronLasseigne/active_interaction/compare/v2.2.0...v3.0.0
  [2.2.0]: https://github.com/AaronLasseigne/active_interaction/compare/v2.1.5...v2.2.0
  [2.1.5]: https://github.com/AaronLasseigne/active_interaction/compare/v2.1.4...v2.1.5
  [2.1.4]: https://github.com/AaronLasseigne/active_interaction/compare/v2.1.3...v2.1.4
  [2.1.3]: https://github.com/AaronLasseigne/active_interaction/compare/v2.1.2...v2.1.3
  [2.1.2]: https://github.com/AaronLasseigne/active_interaction/compare/v2.1.1...v2.1.2
  [2.1.1]: https://github.com/AaronLasseigne/active_interaction/compare/v2.1.0...v2.1.1
  [2.1.0]: https://github.com/AaronLasseigne/active_interaction/compare/v2.0.1...v2.1.0
  [2.0.1]: https://github.com/AaronLasseigne/active_interaction/compare/v2.0.0...v2.0.1
  [2.0.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.6.0...v2.0.0
  [1.6.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.6.0...v1.6.1
  [1.6.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.5.1...v1.6.0
  [1.5.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.5.0...v1.5.1
  [1.5.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.4.1...v1.5.0
  [1.4.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.4.0...v1.4.1
  [1.4.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.3.1...v1.4.0
  [1.3.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.3.0...v1.3.1
  [1.3.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.2.5...v1.3.0
  [1.2.5]: https://github.com/AaronLasseigne/active_interaction/compare/v1.2.4...v1.2.5
  [1.2.4]: https://github.com/AaronLasseigne/active_interaction/compare/v1.2.3...v1.2.4
  [1.2.3]: https://github.com/AaronLasseigne/active_interaction/compare/v1.2.2...v1.2.3
  [1.2.2]: https://github.com/AaronLasseigne/active_interaction/compare/v1.2.1...v1.2.2
  [1.2.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.2.0...v1.2.1
  [1.2.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.7...v1.2.0
  [1.1.7]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.6...v1.1.7
  [1.1.6]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.5...v1.1.6
  [1.1.5]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.4...v1.1.5
  [1.1.4]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.3...v1.1.4
  [1.1.3]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.2...v1.1.3
  [1.1.2]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.1...v1.1.2
  [1.1.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.1.0...v1.1.1
  [1.1.0]: https://github.com/AaronLasseigne/active_interaction/compare/v1.0.5...v1.1.0
  [1.0.5]: https://github.com/AaronLasseigne/active_interaction/compare/v1.0.4...v1.0.5
  [1.0.4]: https://github.com/AaronLasseigne/active_interaction/compare/v1.0.3...v1.0.4
  [1.0.3]: https://github.com/AaronLasseigne/active_interaction/compare/v1.0.2...v1.0.3
  [1.0.2]: https://github.com/AaronLasseigne/active_interaction/compare/v1.0.1...v1.0.2
  [1.0.1]: https://github.com/AaronLasseigne/active_interaction/compare/v1.0.0...v1.0.1
  [1.0.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.10.2...v1.0.0
  [0.10.2]: https://github.com/AaronLasseigne/active_interaction/compare/v0.10.1...v0.10.2
  [0.10.1]: https://github.com/AaronLasseigne/active_interaction/compare/v0.10.0...v0.10.1
  [0.10.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.9.1...v0.10.0
  [0.9.1]: https://github.com/AaronLasseigne/active_interaction/compare/v0.9.0...v0.9.1
  [0.9.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.8.0...v0.9.0
  [0.8.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.7.0...v0.8.0
  [0.7.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.6.1...v0.7.0
  [0.6.1]: https://github.com/AaronLasseigne/active_interaction/compare/v0.6.0...v0.6.1
  [0.6.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.5.0...v0.6.0
  [0.5.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.4.0...v0.5.0
  [0.4.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.3.0...v0.4.0
  [0.3.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.2.2...v0.3.0
  [0.2.2]: https://github.com/AaronLasseigne/active_interaction/compare/v0.2.1...v0.2.2
  [0.2.1]: https://github.com/AaronLasseigne/active_interaction/compare/v0.2.0...v0.2.1
  [0.2.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.1.3...v0.2.0
  [0.1.3]: https://github.com/AaronLasseigne/active_interaction/compare/v0.1.2...v0.1.3
  [0.1.2]: https://github.com/AaronLasseigne/active_interaction/compare/v0.1.1...v0.1.2
  [0.1.1]: https://github.com/AaronLasseigne/active_interaction/compare/v0.1.0...v0.1.1
  [0.1.0]: https://github.com/AaronLasseigne/active_interaction/compare/v0.0.0...v0.1.0

  [#20]: https://github.com/AaronLasseigne/active_interaction/issues/20
  [#23]: https://github.com/AaronLasseigne/active_interaction/issues/23
  [#24]: https://github.com/AaronLasseigne/active_interaction/issues/24
  [#27]: https://github.com/AaronLasseigne/active_interaction/issues/27
  [#28]: https://github.com/AaronLasseigne/active_interaction/issues/28
  [#29]: https://github.com/AaronLasseigne/active_interaction/issues/29
  [#30]: https://github.com/AaronLasseigne/active_interaction/issues/30
  [#34]: https://github.com/AaronLasseigne/active_interaction/issues/34
  [#36]: https://github.com/AaronLasseigne/active_interaction/issues/36
  [#37]: https://github.com/AaronLasseigne/active_interaction/issues/37
  [#38]: https://github.com/AaronLasseigne/active_interaction/issues/38
  [#39]: https://github.com/AaronLasseigne/active_interaction/issues/39
  [#40]: https://github.com/AaronLasseigne/active_interaction/issues/40
  [#41]: https://github.com/AaronLasseigne/active_interaction/issues/41
  [#44]: https://github.com/AaronLasseigne/active_interaction/issues/44
  [#45]: https://github.com/AaronLasseigne/active_interaction/issues/45
  [#49]: https://github.com/AaronLasseigne/active_interaction/issues/49
  [#56]: https://github.com/AaronLasseigne/active_interaction/issues/56
  [#57]: https://github.com/AaronLasseigne/active_interaction/issues/57
  [#58]: https://github.com/AaronLasseigne/active_interaction/issues/58
  [#61]: https://github.com/AaronLasseigne/active_interaction/issues/61
  [#66]: https://github.com/AaronLasseigne/active_interaction/issues/66
  [#77]: https://github.com/AaronLasseigne/active_interaction/issues/77
  [#82]: https://github.com/AaronLasseigne/active_interaction/issues/82
  [#84]: https://github.com/AaronLasseigne/active_interaction/issues/84
  [#88]: https://github.com/AaronLasseigne/active_interaction/issues/88
  [#89]: https://github.com/AaronLasseigne/active_interaction/issues/89
  [#90]: https://github.com/AaronLasseigne/active_interaction/issues/90
  [#94]: https://github.com/AaronLasseigne/active_interaction/issues/94
  [#98]: https://github.com/AaronLasseigne/active_interaction/issues/98
  [#102]: https://github.com/AaronLasseigne/active_interaction/issues/102
  [#103]: https://github.com/AaronLasseigne/active_interaction/issues/103
  [#104]: https://github.com/AaronLasseigne/active_interaction/issues/104
  [#106]: https://github.com/AaronLasseigne/active_interaction/issues/106
  [#111]: https://github.com/AaronLasseigne/active_interaction/issues/111
  [#114]: https://github.com/AaronLasseigne/active_interaction/issues/114
  [#115]: https://github.com/AaronLasseigne/active_interaction/issues/115
  [#116]: https://github.com/AaronLasseigne/active_interaction/issues/116
  [#119]: https://github.com/AaronLasseigne/active_interaction/issues/119
  [#122]: https://github.com/AaronLasseigne/active_interaction/issues/122
  [#125]: https://github.com/AaronLasseigne/active_interaction/issues/125
  [#127]: https://github.com/AaronLasseigne/active_interaction/issues/127
  [#128]: https://github.com/AaronLasseigne/active_interaction/issues/128
  [#129]: https://github.com/AaronLasseigne/active_interaction/issues/129
  [#130]: https://github.com/AaronLasseigne/active_interaction/issues/130
  [#134]: https://github.com/AaronLasseigne/active_interaction/issues/134
  [#135]: https://github.com/AaronLasseigne/active_interaction/issues/135
  [#136]: https://github.com/AaronLasseigne/active_interaction/issues/136
  [#138]: https://github.com/AaronLasseigne/active_interaction/issues/138
  [#140]: https://github.com/AaronLasseigne/active_interaction/issues/140
  [#143]: https://github.com/AaronLasseigne/active_interaction/issues/143
  [#153]: https://github.com/AaronLasseigne/active_interaction/issues/153
  [#155]: https://github.com/AaronLasseigne/active_interaction/issues/155
  [#156]: https://github.com/AaronLasseigne/active_interaction/issues/156
  [#163]: https://github.com/AaronLasseigne/active_interaction/issues/163
  [#164]: https://github.com/AaronLasseigne/active_interaction/issues/164
  [#165]: https://github.com/AaronLasseigne/active_interaction/issues/165
  [#173]: https://github.com/AaronLasseigne/active_interaction/issues/173
  [#174]: https://github.com/AaronLasseigne/active_interaction/issues/174
  [#175]: https://github.com/AaronLasseigne/active_interaction/issues/175
  [#178]: https://github.com/AaronLasseigne/active_interaction/issues/178
  [#179]: https://github.com/AaronLasseigne/active_interaction/issues/179
  [#192]: https://github.com/AaronLasseigne/active_interaction/issues/192
  [#196]: https://github.com/AaronLasseigne/active_interaction/issues/196
  [#201]: https://github.com/AaronLasseigne/active_interaction/issues/201
  [#203]: https://github.com/AaronLasseigne/active_interaction/issues/203
  [#206]: https://github.com/AaronLasseigne/active_interaction/issues/206
  [#207]: https://github.com/AaronLasseigne/active_interaction/issues/207
  [#213]: https://github.com/AaronLasseigne/active_interaction/issues/213
  [#214]: https://github.com/AaronLasseigne/active_interaction/issues/214
  [#215]: https://github.com/AaronLasseigne/active_interaction/issues/215
  [#224]: https://github.com/AaronLasseigne/active_interaction/issues/224
  [#235]: https://github.com/AaronLasseigne/active_interaction/issues/235
  [#236]: https://github.com/AaronLasseigne/active_interaction/issues/236
  [#239]: https://github.com/AaronLasseigne/active_interaction/issues/239
  [#244]: https://github.com/AaronLasseigne/active_interaction/issues/244
  [#248]: https://github.com/AaronLasseigne/active_interaction/issues/248
  [#250]: https://github.com/AaronLasseigne/active_interaction/issues/250
  [#256]: https://github.com/AaronLasseigne/active_interaction/issues/256
  [#264]: https://github.com/AaronLasseigne/active_interaction/issues/264
  [#265]: https://github.com/AaronLasseigne/active_interaction/issues/265
  [#269]: https://github.com/AaronLasseigne/active_interaction/issues/269
  [#286]: https://github.com/AaronLasseigne/active_interaction/issues/286
  [#289]: https://github.com/AaronLasseigne/active_interaction/issues/289
  [#295]: https://github.com/AaronLasseigne/active_interaction/issues/295
  [#296]: https://github.com/AaronLasseigne/active_interaction/issues/296
  [#298]: https://github.com/AaronLasseigne/active_interaction/issues/298
  [#303]: https://github.com/AaronLasseigne/active_interaction/issues/303
  [#304]: https://github.com/AaronLasseigne/active_interaction/issues/304
  [#310]: https://github.com/AaronLasseigne/active_interaction/issues/310
  [#311]: https://github.com/AaronLasseigne/active_interaction/issues/311
  [#320]: https://github.com/AaronLasseigne/active_interaction/issues/320
  [#330]: https://github.com/AaronLasseigne/active_interaction/pull/330
  [#332]: https://github.com/AaronLasseigne/active_interaction/pull/332
  [#333]: https://github.com/AaronLasseigne/active_interaction/pull/333
  [#336]: https://github.com/AaronLasseigne/active_interaction/pull/336
  [#344]: https://github.com/AaronLasseigne/active_interaction/pull/344
  [#346]: https://github.com/AaronLasseigne/active_interaction/pull/346
  [#349]: https://github.com/AaronLasseigne/active_interaction/issues/349
  [#357]: https://github.com/AaronLasseigne/active_interaction/issues/357
  [#362]: https://github.com/AaronLasseigne/active_interaction/pull/362
  [#364]: https://github.com/AaronLasseigne/active_interaction/pull/364
  [#365]: https://github.com/AaronLasseigne/active_interaction/pull/365
  [#370]: https://github.com/AaronLasseigne/active_interaction/pull/370
  [#377]: https://github.com/AaronLasseigne/active_interaction/pull/377
  [#383]: https://github.com/AaronLasseigne/active_interaction/pull/383
  [#384]: https://github.com/AaronLasseigne/active_interaction/issues/384
  [#387]: https://github.com/AaronLasseigne/active_interaction/pull/387
  [#408]: https://github.com/AaronLasseigne/active_interaction/issues/408
  [#411]: https://github.com/AaronLasseigne/active_interaction/issues/411
  [#415]: https://github.com/AaronLasseigne/active_interaction/issues/415
  [#417]: https://github.com/AaronLasseigne/active_interaction/issues/417
  [#420]: https://github.com/AaronLasseigne/active_interaction/issues/420
  [#422]: https://github.com/AaronLasseigne/active_interaction/issues/422
  [#425]: https://github.com/AaronLasseigne/active_interaction/issues/425
  [#429]: https://github.com/AaronLasseigne/active_interaction/issues/429
  [#435]: https://github.com/AaronLasseigne/active_interaction/issues/435
  [#454]: https://github.com/AaronLasseigne/active_interaction/pull/454
  [#455]: https://github.com/AaronLasseigne/active_interaction/pull/455
  [#457]: https://github.com/AaronLasseigne/active_interaction/issues/457
