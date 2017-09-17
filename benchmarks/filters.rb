require 'active_interaction'
require 'benchmark/ips'

VALUES = {
  array: [],
  boolean: false,
  date: Date.new,
  date_time: DateTime.new,
  decimal: BigDecimal(0),
  file: StringIO.new,
  float: 0.0,
  hash: {},
  integer: 0,
  interface: Object.new,
  object: Object.new,
  string: '',
  symbol: :'',
  time: Time.at(0)
}.freeze

Benchmark.ips do |bm|
  bm.report('lambda') { -> {}.call }

  VALUES.each do |type, value|
    interaction = Class.new(ActiveInteraction::Base) do
      def execute; end
    end
    interaction.public_send(type, type)

    bm.report(type) { interaction.run!(type => value) }
  end
end
