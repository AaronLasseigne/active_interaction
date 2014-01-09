# coding: utf-8

shared_context 'concerns' do |concern|
  let(:klass) { Class.new { include concern } }

  subject(:instance) { klass.new }
end
