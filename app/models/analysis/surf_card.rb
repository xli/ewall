module Analysis
  class SURFCard
    class Match
      attr_reader :card, :score
      def initialize(card, score)
        @card, @score = card, score
      end
    end

    def self.surf(cards)
      Array(cards).map{|c| self.new(c)}.select(&:surf)
    end

    def initialize(card)
      @card = card
      @tool = WalleVisual::SURF.new
    end

    def identifier
      @card.identifier
    end

    def surf
      @surf ||= @tool.surf(@card.image_path)
    end

    def match(arg)
      case arg
      when SURFCard
        if score = @tool.match(arg.surf, surf)
          Match.new self, score
        end
      when Array
        arg.map { |ic| ic.match(self) }.compact
      else
        raise "Unsupported argument: #{arg.inspect}"
      end
    end
  end

end
