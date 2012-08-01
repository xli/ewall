
module Analysis
  class Snapshot
    def initialize(snapshot_analysis_path, snapshot_path)
      @snapshot_analysis_path, @snapshot_path = snapshot_analysis_path, snapshot_path
    end

    def cards
      FileUtils.rm_rf(@snapshot_analysis_path)
      cards = walle_visual_analysis
      cards = clear_similar_cards_by_position(cards)
    end

    def walle_visual_analysis
      WalleVisual.card_wall(@snapshot_path).save_to(@snapshot_analysis_path)
      data = YAML.load File.read(File.join(@snapshot_analysis_path, 'rects.yml'))

      data[:rects].map do |rect|
        file = rect[:file].gsub(Rails.public_path, '')
        x, y, width, height = rect[:rect]
        Card.new(:image => file, :x => x, :y => y, :width => width, :height => height)
      end
    end

    def clear_similar_cards_by_position(cards)
      rest = cards.to_a.sort_by(&:area)
      result = []
      loop do
        break if rest.empty?
        test_card = rest.shift
        threshold = test_card.area * 0.8 # why 80%?
        if rest.all? { |card| card.mix_area(test_card) < threshold }
          result << test_card
        end
      end
      result
    end
  end
end
