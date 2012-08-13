class Card < ActiveRecord::Base
  belongs_to :snapshot
  attr_accessible :identifier, :positive, :image, :x, :y, :height, :width
  scope :positive, lambda { where("positive = ?", true) }
  scope :negative, lambda { where("positive = ?", false) }
  scope :unknown, where("positive IS NULL")
  scope :positive_or_unkunwn, lambda { where("positive is not ?", false)}
  scope :not_identified, where('identifier IS NULL OR identifier = ""')
  scope :identified, where('identifier IS NOT NULL AND identifier != ""')

  def area
    height * width
  end

  def mix_area(card)
    mixed_x = [x, card.x].max
    mixed_y = [y, card.y].max
    mixed_right_x = [card.right_x, right_x].min
    mixed_bottom_y = [card.bottom_y, bottom_y].min
    mixed_width = mixed_right_x - mixed_x
    return 0 if mixed_width <= 0
    mixed_height = mixed_bottom_y - mixed_y
    return 0 if mixed_height <= 0

    mixed_width * mixed_height
  end

  def right_x
    x + width
  end

  def bottom_y
    y + height
  end

  def title
    identifier.blank? ? 'Not identified' : identifier
  end

  def data
    {
      'data-identifier' => identifier,
      'data-x' => x,
      'data-y' => y,
      'data-height' => height,
      'data-width' => width,
      'data-positive' => positive,
      'title' => title,
      'data-content' => 'Double click to see details.',
      'data-url' => "/walls/#{snapshot.wall_id}/snapshots/#{snapshot.id}/cards/#{self.id}"
    }
  end

  def image_path
    File.join(Rails.public_path, self.image)
  end

  def gray_image
    OpenCV::IplImage.load(image_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  def new_card?
    positive.nil?
  end
end
