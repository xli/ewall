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

  def snapshot_uri
    File.join('', wall.snapshots_uri, image.to_s)
  end

  def all_rects_uri
    File.join('', analysis_uri, 'all_rects.png')
  end

  def snapshot_analysis_path
    path(analysis_uri)
  end

  def snapshot_path
    path(snapshot_uri)
  end

  def timestamp
    taken_at || created_at
  end

  def grid
    Grid.build(cards.positive_or_unkunwn.to_a)
  end

  def analysis!
    self.update_attribute(:in_analysis, 5)

    self.cards = Analysis::Snapshot.new(snapshot_analysis_path, snapshot_path).cards
    self.update_attribute(:in_analysis, 10)

    identified_cards = wall.snapshots[0..4].map{|s| s.cards.positive.identified}.flatten.uniq_by(&:identifier)
    self.update_attribute(:in_analysis, 15)

    identified_surf_cards = Analysis::SURFCard.surf(identified_cards)
    self.update_attribute(:in_analysis, 20)

    size = self.cards.size
    card_matchs = self.cards.each_with_index.map do |card, index|
      if surf_card = Analysis::SURFCard.surf([card]).first
        if mc = surf_card.match(identified_surf_cards).max_by(&:score).try(:card)
          card.update_attribute(:identifier, mc.identifier)
        end
      end
      self.update_attribute(:in_analysis, 20 + index.to_f/size * 80)
    end
  ensure
    self.update_attribute(:in_analysis, 100)
  end

  private
  def path(uri)
    File.join(Rails.public_path, uri)
  end

  def analysis_uri
    File.join(wall.snapshots_uri, [strip(image), 'analysis'].join('_'))
  end

  def strip(name)
    name.to_s.downcase.gsub(/[\W]/, '_')
  end
end
