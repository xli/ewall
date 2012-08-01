require 'statsample'

module Grid
  class Row
    attr_reader :top_y, :bottom_y

    def initialize(item)
      @data = []
      self << item
    end

    def <<(item)
      @data << item
      @top_y = quartiles_meam(@data.map(&:y))
      @bottom_y = quartiles_meam(@data.map{|item| item.y + item.height})
    end

    def inbound_y?(y)
      @top_y <= y && y <= @bottom_y
    end

    def include?(item)
      @data.include?(item)
    end

    def height
      @bottom_y - @top_y
    end

    private
    def quartiles_meam(array)
      quartiles(array).to_scale.mean
    end

    def quartiles(array)
      return array if array.size < 7
      lower = (array.size - 3)/4
      upper = lower * 3 + 3
      array[lower..upper]
    end
  end
end
