require 'test_helper'

class CardTest < ActiveSupport::TestCase
  def test_mix_area
    assert_mixed_area([1, 1, 10, 10], [2, 1, 10, 10], (10-1)*10)
    assert_mixed_area([1, 1, 10, 10], [1, 2, 10, 10], (10-1)*10)
    assert_mixed_area([2, 1, 10, 10], [1, 1, 10, 10], (10-1)*10)
    assert_mixed_area([1, 2, 10, 10], [1, 1, 10, 10], (10-1)*10)

    assert_mixed_area([1, 1, 10, 10], [2, 2, 10, 10], (10-1)*(10-1))
    assert_mixed_area([2, 1, 10, 10], [1, 2, 10, 10], (10-1)*(10-1))
    assert_mixed_area([2, 2, 10, 10], [1, 1, 10, 10], (10-1)*(10-1))
    assert_mixed_area([1, 2, 10, 10], [2, 1, 10, 10], (10-1)*(10-1))

    assert_mixed_area([1, 1, 5, 10], [2, 2, 10, 10], (5-1)*(10-1))
    assert_mixed_area([2, 1, 5, 10], [1, 2, 10, 10], 5*(10-1))
    assert_mixed_area([2, 2, 5, 10], [1, 1, 10, 10], 5*(10-1))
    assert_mixed_area([1, 2, 5, 10], [2, 1, 10, 10], (5-1)*(10-1))

    assert_mixed_area([20, 20, 5, 10], [2, 1, 10, 10], 0)
    assert_mixed_area([20, 20, 5, 10], [200, 100, 10, 10], 0)
  end

  def assert_mixed_area(c1, c2, area)
    assert_equal area, card(c1).mix_area(card(c2))
  end

  def card(c)
    x, y, width, height = c
    Card.new(:x => x, :y => y, :width => width, :height => height)
  end
end
