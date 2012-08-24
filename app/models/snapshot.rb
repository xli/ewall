class Snapshot < ActiveRecord::Base
  belongs_to :wall
  has_many :cards, :dependent => :delete_all

  attr_accessible :image, :taken_at, :height, :in_analysis, :width

  def duplicate_cards
    sql = cards.identified.select("identifier, count(identifier) as count")
      .group("identifier")
      .having("count(identifier) > ?", 1)
      .to_sql
    self.class.connection.select_all(sql)
  end

  def analyzed?
    in_analysis.nil? || in_analysis == 100
  end

  def timestamp
    taken_at || created_at
  end

  def grid
    Grid.build(cards.positive_or_unkunwn.to_a)
  end

  def analysis!
    Time.zone = self.wall.time_zone
    self.update_attribute(:in_analysis, 5)

    self.cards = Analysis::Snapshot.new(wall.snapshot_analysis_path(self), wall.snapshot_path(self)).cards
    self.update_attribute(:in_analysis, 10)

    identified_cards = wall.snapshots[0..4].map{|s| s.cards.positive.identified}.flatten.uniq_by(&:identifier)
    self.update_attribute(:in_analysis, 15)

    matcher = WalleVisual::ImageMatcher.new(identified_cards.map(&self.wall.card_image_path))
    self.update_attribute(:in_analysis, 20)

    size = self.cards.size
    card_matchs = self.cards.each_with_index.map do |card, index|
      if match_index = matcher.match(wall.card_image_path[card])
        card.update_attribute(:identifier, identified_cards[match_index].identifier)
      end
      self.update_attribute(:in_analysis, 20 + index * 80/size)
    end
  ensure
    self.update_attribute(:in_analysis, 100)
  end
end
