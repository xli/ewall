class Snapshot < ActiveRecord::Base
  belongs_to :wall
  has_many :cards, :dependent => :delete_all
  attr_accessible :image, :taken_at
  after_create :ensure_root_directory

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
    "/#{File.join(uri, image.to_s)}"
  end

  def all_rects_uri
    "/#{File.join(analysis_uri, 'all_rects.png')}"
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
      matchs = if surf_card = Analysis::SURFCard.surf([card]).first
        identified_surf_cards.map { |ic| ic.match(surf_card) }.compact
      end
      self.update_attribute(:in_analysis, 20 + index.to_f/size * 70)
      matchs && matchs.size > 0 ? [card, matchs] : nil
    end.compact.group_by {|card, matchs| matchs.size == 1 ? 'one' : 'multiple'}

    matched_cards = []
    Array(card_matchs['one']).each do |card, matchs|
      match = matchs.first
      matched_cards << match.card
      card.update_attribute(:identifier, match.card.identifier)
    end
    self.update_attribute(:in_analysis, 95)

    Array(card_matchs['multiple']).each do |card, matchs|
      if match = matchs.reject{|m| matched_cards.include?(m.card)}.max_by(&:score)
        matched_cards << match.card
        card.update_attribute(:identifier, match.card.identifier)
      end
    end
  ensure
    self.update_attribute(:in_analysis, 100)
  end

  private
  def path(uri)
    File.join(Rails.public_path, uri)
  end

  def ensure_root_directory
    FileUtils.mkdir_p(path(uri))
  end

  def analysis_uri
    File.join(uri, [strip(image), 'analysis'].join('_'))
  end

  def uri
    File.join('snapshots', strip(wall.name))
  end
  def strip(name)
    name.to_s.downcase.gsub(/[\W]/, '_')
  end
end
