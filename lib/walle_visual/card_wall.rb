require 'yaml'
require 'fileutils'
require 'walle_visual/opencv_helper'
require 'walle_visual/contours'
require 'walle_visual/rect'

module WalleVisual
  class CardWall
    include OpenCVHelper

    def initialize(image)
      @image = image
    end

    def detect_contours(low=50, high=110)
      contours = @image.split.map{|c| [c, c.threshold(104, 255, :binary_inv)]}.flatten.map do |one_channel|
        edges = one_channel.canny(low, high)
        edges = edges.dilate
        edges.find_contours(:mode => CV_RETR_LIST, :method => CV_CHAIN_APPROX_SIMPLE)
      end
      Contours.new contours
    end

    def find_all
      rects = detect_contours.map {|cnt| Rect.new cnt}
      rects = rects.reject(&tiny_rects)
      rects = rects.select(&similar_rects(rects))
      rects = rects.reject(&nested_rect_container(rects))
      rects.uniq(&:to_a)
    end

    def save_to(dir)
      filepath = file_in_dir(dir)
      data = {image_height: @image.height, image_width: @image.width, rects: []}

      rects = find_all
      draw_rects(@image.copy, rects).save_image(filepath['all_rects.png'])

      rects.each_with_index do |rect, i|
        if img = rect.crop(@image)
          filepath["rect_#{i}.png"].tap do |file|
            img.save_image(file)
            data[:rects] << {rect: rect.to_a, file: file}
          end
        end
      end
      save_to_file(filepath['rects.yml'], YAML.dump(data))
    end

    private
    def file_in_dir(dir)
      dir = File.expand_path(dir)
      FileUtils.mkdir_p(dir)
      lambda {|f| File.join(dir, f)}
    end
    def save_to_file(file, data)
      File.open(file, 'w') { |io| io.write data }
    end

    def nested_rect_container(rects)
      lambda {|rect| rects.any?{|c| rect != c && rect.contains?(c)}}
    end

    def tiny_rects(width_threshold=nil, height_threshold=nil)
      width_threshold ||= @image.width * 0.03
      height_threshold ||= @image.height * 0.03
      lambda {|rect| rect.width < width_threshold || rect.height < height_threshold}
    end

    def similar_rects(rects)
      width = middle(rects, :width, 0.2, 0.5)
      height = middle(rects, :height, 0.2, 0.5)
      lambda do |rect|
        width.call(rect) && height.call(rect)
      end
    end

    def middle(rects, attribute, l, h)
      rects = rects.sort_by(&attribute)
      middle = rects[rects.size/2]
      threshold = middle.send(attribute).to_f
      lambda do |rect|
        distance = rect.send(attribute) - threshold
        distance > 0 ? distance < threshold * h : distance > -threshold * l
      end
    end
  end
end
