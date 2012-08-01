module SnapshotsHelper
  def render_cards(snapshot, cards)
    render :partial => 'snapshots/card', :collection => cards
  end
  def change(changes, card)
    if changes && change = changes.find {|c| c.item.identifier == card.identifier}
      CardChange.new(change).data
    else
      {}
    end
  end

  def auto_complete_suggestion_cards
    @auto_complete_suggestion_cards ||= @wall.cards.positive.uniq_by(&:identifier)
  end
end
