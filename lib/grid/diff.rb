require 'grid/change'

module Grid
  module Diff
    class Item
      attr_reader :origin_item, :position
      def initialize(origin_item, position)
        @origin_item, @position = origin_item, position
      end
      def identifier
        origin_item.identifier
      end
      def identified?
        !identifier.to_s.empty?
      end
      def ==(another)
        identifier == another.identifier
      end
      alias :eql? :==
      def hash
        identifier.hash
      end
      def column_index
        position[0]
      end
      def row_index
        position[1]
      end
    end

    def column_items_diff(columns1, columns2)
      changes = []
      items1 = items(columns1)
      items2 = items(columns2)
      (items1 - items2).each do |item|
        changes << Change.new('add', item.origin_item, item.position)
      end
      (items2 - items1).each do |item|
        changes << Change.new('removed', item.origin_item, item.position)
      end
      (items1 & items2).each do |item|
        item1 = item
        item2 = items2.find {|c| c == item}
        if item1.column_index != item2.column_index
          changes << Change.new('move', item1.origin_item, item1.position, item2.position)
        end
      end
      changes
    end
    private
    def items(columns)
      columns.each_with_index.map do |column, column_index|
        column.body.each_with_index.map do |item, row_index|
          Item.new(item, [column_index, row_index])
        end
      end.flatten.select(&:identified?)
    end
  end
end
