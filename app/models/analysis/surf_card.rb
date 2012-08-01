module Analysis
  class SURFCard
    class Match
      attr_reader :card, :score
      def initialize(card, score)
        @card, @score = card, score
      end
    end

    def self.find_similar_card(card, sample_cards)
      card = SURFCard.surf([card]).first
      SURFCard.surf(sample_cards).map { |ic| ic.match(card) }.compact.max_by(&:score).try(&:card)
    end

    def self.surf(cards)
      cards.map{|c| self.new(c)}.select(&:surf)
    end

    def initialize(card)
      @card = card
    end

    def identifier
      @card.identifier
    end

    def surf
      @surf ||= WalleVisual::SURF.new.surf(@card.image_path)
    end

    def match(card)
      if score = WalleVisual::SURF.new.match(card.surf, surf)
        Match.new self, score
      end
    end
  end

end
