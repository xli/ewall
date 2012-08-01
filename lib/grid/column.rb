module Grid
  class Column
    def self.contains(item)
      lambda {|column| column.inbound_x?(item.x)}
    end
    attr_reader :head, :body

    def initialize(head)
      @head = head
      @body = []
    end

    def <<(item)
      @body << item
    end

    def inbound_x?(x)
      x >= left_x && x < right_x
    end

    def distance(x)
      (x - left_x).abs
    end

    def size
      @body.size + 1
    end

    def left_x
      @head.x
    end

    def right_x
      @head.x + @head.width
    end

    def width
      @head.width
    end
  end
end