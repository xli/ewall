module WalleVisual
  class Contours
    include Enumerable
    def initialize(contours)
      @contours = contours
    end

    def each(&block)
      @contours.each do |contour|
        loop do
          break unless contour
          block.call(contour)
          contour = contour.h_next
        end
      end
    end
  end
end
