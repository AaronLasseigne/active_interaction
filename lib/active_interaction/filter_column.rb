# coding: utf-8

module ActiveInteraction
  #
  class FilterColumn
    TYPE_MAPPING = {
      array:     :string,
      boolean:   :boolean,
      date:      :date,
      date_time: :datetime,
      file:      :file,
      float:     :float,
      hash:      :string,
      integer:   :integer,
      model:     :string,
      string:    :string,
      symbol:    :string,
      time:      :datetime
    }.freeze

    attr_reader :limit, :type

    def initialize(type)
      @type = TYPE_MAPPING.fetch(type)
    end

    def number?
      [:integer, :float].include?(type)
    end

    def text?
      type == :string
    end
  end
end
