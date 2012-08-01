require 'grid/row'
require 'grid/diff'

module Grid
  class EmptyCell < Struct.new(:x, :y, :width, :height)
  end

  class Base
    include Diff
    attr_reader :columns
    def initialize(columns)
      @columns = columns
    end

    def heads
      @columns.map(&:head)
    end

    def fill_blank_cells
      items = @columns.map(&:body).flatten.sort_by(&:y)
      items.inject([]) do |rows, item|
        if rows.empty? || !rows.last.inbound_y?(item.y)
          rows << Row.new(item)
        else
          rows.last << item
        end
        rows
      end.each_with_index do |row, index|
        @columns.reject{|c| c.body.size <= index}.select { |column| !row.include?(column.body[index]) }.each do |column|
          column.body.insert(index, EmptyCell.new(column.left_x, row.top_y, column.width, row.height))
        end
      end
      self
    end

    def diff(grid)
      column_items_diff(columns, grid.columns)
    end
  end
end
