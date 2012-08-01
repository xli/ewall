require 'forwardable'

module WalleVisual
  class Rect
    extend Forwardable
    def_delegators :@rect, :x, :y, :width, :height, :top_left, :bottom_right
    def initialize(contour)
      @contour = contour
      @box = contour.min_area_rect2
      @rotate90 = @box.size.height > @box.size.width
      @rect = convert_to_rect(@box, @rotate90)
    end

    def contains?(rect)
      top_left.x < rect.top_left.x && top_left.y < rect.top_left.y &&
        bottom_right.x > rect.bottom_right.x && bottom_right.y > rect.bottom_right.y
    end

    def area
      @area ||= width * height
    end

    def crop(image)
      bounding_rect = @contour.bounding_rect
      image
        .subrect(bounding_rect)
        .warp_affine(rotation_mat(bounding_rect))
        .subrect(rect_relative_to(bounding_rect))
    end

    def draw(img, color)
      # img.poly_line!([@rect.points], :color => color, :is_closed => true)
      img.poly_line!([@box.points], :color => color, :is_closed => true)
    end

    def to_a
      [x, y, width, height]
    end

    def to_s
      to_a.inspect
    end

    def inspect
      "Rect#{to_s}"
    end

    private
    def rotation_mat(bounding_rect)
      center = OpenCV::CvPoint.new(@box.center.x - bounding_rect.x, @box.center.y - bounding_rect.y)
      angle = @rotate90 ? 90 + @box.angle : @box.angle
      OpenCV::CvMat.rotation_matrix2D(center, angle, 1.0)
    end

    def rect_relative_to(bounding_rect)
      x = [@rect.x - bounding_rect.x, 0].max
      y = [@rect.y - bounding_rect.y, 0].max
      width = [bounding_rect.width - x, @rect.width].min
      height = [bounding_rect.height - y, @rect.height].min
      OpenCV::CvRect.new(x, y, width, height)
    end

    def convert_to_rect(box, rotate90)
      width = rotate90 ? box.size.height : box.size.width
      height = rotate90 ? box.size.width : box.size.height
      x = box.center.x - width/2
      y = box.center.y - height/2
      OpenCV::CvRect.new(x, y, width, height)
    end
  end
end
