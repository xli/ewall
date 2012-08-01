class CardChange
  attr_reader :type, :card, :from_position
  def initialize(change)
    @type, @card, @position, @from_position = change.type, change.item, change.position, change.from_position
  end

  def data
    {
      'class' => "change change-#{@type}",
      'data-change-type' => @type,
      'data-change-position' => @position,
      'data-change-from-position' => @from_position,
      'data-content' => data_content << "\nDouble Click to see details."
    }
  end

  def data_content
    case @type
    when 'add'
      "New card on the wall."
    when 'move'
      "Moved from highlighted column."
    when 'removed'
      "Has been taken away."
    end
  end

  def to_s
    card = "card(#{@card.identifier || @card} at #{@position.inspect})"
    from = if from_position
      " from #{from_position.inspect}"
    end
    "#<Change>[#{@type} #{card}#{from}]"
  end
end
