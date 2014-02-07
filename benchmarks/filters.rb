# Usage: bundle exec ruby benchmarks/filters.rb

# TODO: Benchmark errors.
# TODO: Special cases for values and filters (see other TODOs).
# TODO: Parse (and graph) the output.
# TODO: Automate benchmarks across time (i.e., commits).

require 'active_interaction'
require 'active_support/inflector'
require 'benchmark'

filters = ActiveInteraction::Filter
  .send(:const_get, :CLASSES)
  .reject { |_, v| v.name =~ /\bAbstract/ }

# rubocop:disable all
VALUES = {
  array:     [Array.new], # TODO
  boolean:   [false, '0', 'false', true, '1', 'true'],
  date:      [Date.new, Date.new.to_s],
  date_time: [DateTime.new, DateTime.new.to_s],
  file:      [File.new(__FILE__), Struct.new(:tempfile).new(File.new(__FILE__))],
  float:     [0.0, '0.0', 0],
  hash:      [Hash.new], # TODO
  integer:   [0, '0', 0.0],
  model:     [Object.new], # TODO: Reconstantizing.
  string:    [''], # TODO: Without strip.
  symbol:    [:'', ''],
  time:      [Time.at(0), Time.at(0).to_s, 0] # TODO: TimeWithZone
}
# rubocop:enable all

missing_filters = filters.keys - VALUES.keys
fail "Missing filters: #{missing_filters}" unless missing_filters.empty?

Benchmark.bmbm do |bm|
  n = Integer(ARGV.pop || 10_000)

  bm.report('baseline') do
    n.times { 100.times.reduce('') { |a, e| a + (e % 255).chr } }
  end

  VALUES.each do |slug, values|
    filter = ActiveInteraction::Filter.factory(slug).new(slug, class: Object)

    values.each do |value|
      bm.report("#{slug}.cast(#{value.inspect})") do
        n.times do
          filter.cast(value)
        end
      end
    end
  end
end
