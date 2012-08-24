module ApplicationHelper
  def format_time(time)
    time.strftime('%l %p, %b %e %z')
  end

  def full_time_format(time)
    time.strftime("%d %b %Y %I:%M%p %z")
  end

  def card_image_data(card)
    card_url = wall_snapshot_card_path(@wall, @wall.card_snapshot(card), card)
    {
      'data-identifier' => card.identifier,
      'data-x' => card.x,
      'data-y' => card.y,
      'data-height' => card.height,
      'data-width' => card.width,
      'data-positive' => card.positive,
      'title' => card.title,
      'data-content' => 'Double click to see details.',
      'data-url' => card_url
    }
  end
end
