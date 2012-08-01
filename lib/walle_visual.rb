
require 'walle_visual/opencv_helper'
require 'walle_visual/card_wall'
require 'walle_visual/surf'

module WalleVisual
  include OpenCVHelper

  def card_wall(image_path)
    CardWall.new(load_image(image_path))
  end
  module_function :card_wall, :load_image
end

