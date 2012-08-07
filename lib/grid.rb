require 'grid/base'
require 'grid/column'

module Grid
  def build(data)
    if top_item = data.min_by(&:y)
      head_bottom = top_item.y + top_item.height
      heads = data.select {|item| item.y < head_bottom}
      body = (data - heads)

      columns = heads.sort_by(&:x).map { |head| Column.new(head) }

      body.each do |item|
        column = columns.min_by{|column| column.distance(item.x)}
        column << item
      end
      Base.new(columns)
    end
  end
  extend self
end
