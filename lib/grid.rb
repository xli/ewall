require 'grid/base'
require 'grid/column'

module Grid
  def build(data)
    if top_item = data.min_by(&:y)
      head_bottom = top_item.y + top_item.height
      heads = data.select {|item| item.y < head_bottom}
      body = (data - heads)

      columns = heads.sort_by(&:x).inject([]) do |columns, head|
        if columns.last && columns.last.inbound_x?(head.x)
          warn "Overlap detected when building grid heads: "
          warn "  column: #{columns.last.inspect}"
          warn "  head: #{head.inspect}"
          columns
        else
          columns << Column.new(head)
        end
      end

      body.each do |item|
        column = columns.min_by{|column| column.distance(item.x)}
        column << item
      end
      Base.new(columns)
    end
  end
  extend self
end
