require 'opencv'

module WalleVisual
  module OpenCVHelper
    include OpenCV

    def draw_rects(img, rects)
      rects.each { |rect| rect.draw(img, CvColor::Red) }
      img
    end

    def load_image(file)
      IplImage.load(file, OpenCV::CV_LOAD_IMAGE_ANYCOLOR | OpenCV::CV_LOAD_IMAGE_ANYDEPTH)
    end

    def load_as_gray_image(file)
      IplImage.load(file, CV_LOAD_IMAGE_GRAYSCALE)
    end

    def reduce_color(img, div=64)
      mask = (0xFF<<Math.log2(div)) % 256
      img.rows.times do |j|
        img.cols.times do |i|
          pixel = img[j,i]
          pixel[0] = pixel[0].to_i & mask + div/2
          pixel[1] = pixel[1].to_i & mask + div/2
          pixel[2] = pixel[2].to_i & mask + div/2
          img[j,i] = pixel
        end
      end
      img
    end

    def show_image(img)
      @window ||= GUI::Window.new('show image')
      @window.show img
      GUI::wait_key
    end
    def resize(img, width=1024, height=768)
      img.resize(CvSize.new(width, height))
    end
  end
end
