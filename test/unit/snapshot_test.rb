require 'test_helper'

class SnapshotTest < ActiveSupport::TestCase
  def test_analysis_similar_cards_by_position
    cards = []
    cards << Card.new(:x => 1, :y => 1, :width => 90, :height => 60)
    cards << Card.new(:x => 1, :y => 2, :width => 90, :height => 60)
    analysis = Analysis::Snapshot.new('snapshot_analysis_path', 'snapshot_path')

    result = analysis.clear_similar_cards_by_position(cards)
    assert_equal 1, result.size

    card1 = Card.new(:x => 1298, :y => 1654, :width => 279, :height => 159, :identifier => 1)
    card2 = Card.new(:x => 1302, :y => 1653, :width => 255, :height => 133, :identifier => 2)
    result = analysis.clear_similar_cards_by_position([card1, card2])
    assert_equal 1, result.size
    assert_equal card1.id, result[0].id
  end
end
