# Master

# 0.2.0

- Wrap interactions in ActiveRecord transactions if they're available.
- Add option to strip string values, which is enabled by default.
- Add support for strptime format strings on Date, DateTime, and Time filters.

# 0.1.3

- Fix bug that prevented `attr_accessor`s from working.
- Handle unconfigured timezones.
- Use RDoc as YARD's Markdown provider instead of kramdown.

# 0.1.2

- `execute` will now have the filtered version of the values passed
  to `run` or `run!` as was intended.

# 0.1.1

- Correct gemspec dependencies on activemodel.

# 0.1.0

- Initial release.
