require "test/unit"
require "grid"

class GridTest < Test::Unit::TestCase
  class Item < Struct.new(:identifier, :x, :y, :width, :height)
  end

  def test_build_empty_grid
    grid = Grid.build([])
    assert_nil grid
  end

  def test_build_one_item_grid
    grid = Grid.build([Item.new('item1', 0, 0, 10, 10)])
    assert_equal 1, grid.columns.size
    assert_equal 'item1', grid.columns[0].head.identifier
  end

  def test_build_grid
    # item1  item2  item3
    #  --   item4   item5
    # item6   --    item7 item8
    #   item9
    item1 = Item.new('item1', 0, 0,   10, 10)
    item2 = Item.new('item2', 15, 0,  10, 10)
    item3 = Item.new('item3', 30, 0,  10, 10)
    item4 = Item.new('item4', 14, 15, 10, 10)
    item5 = Item.new('item5', 30, 15, 10, 10)
    item6 = Item.new('item6', 0,  30, 10, 10)
    item7 = Item.new('item7', 30, 30, 10, 10)
    item8 = Item.new('item8', 45, 30, 10, 10)
    item9 = Item.new('item9', 5,  45, 10, 10)

    grid = Grid.build([item1, item2, item3, item4, item5, item6, item7, item8, item9])

    assert_equal 3, grid.columns.size
    assert_equal [item1, item2, item3], grid.columns.map(&:head)
    assert_equal [item6, item9], grid.columns[0].body
    assert_equal [item4], grid.columns[1].body
    assert_equal [item5, item7, item8], grid.columns[2].body
  end

  def test_build_grid_with_little_overlap_heads
    # item-i-1-tem2    item3
    # item4            item5

    item1 = Item.new('item1', 0, 0,   10, 10)
    item2 = Item.new('item2', 5, 0,  10, 10)
    item3 = Item.new('item3', 15, 0,  10, 10)
    item4 = Item.new('item4', 0, 15, 10, 10)
    item5 = Item.new('item4', 15, 15, 10, 10)

    grid = Grid.build([item1, item2, item3, item4, item5])

    assert_equal 3, grid.columns.size
    assert_equal [item1, item2, item3], grid.columns.map(&:head)
    assert_equal [item4], grid.columns[0].body
    assert_equal [], grid.columns[1].body
    assert_equal [item5], grid.columns[2].body
  end

  def test_fill_in_blank_cells
    # item1  item2
    #  --    item3
    # item4
    item1 = Item.new('item1', 0, 0,   10, 10)
    item2 = Item.new('item2', 15, 0,  10, 10)
    item3 = Item.new('item3', 15, 15, 10, 10)
    item4 = Item.new('item4', 0, 30,  10, 10)

    grid = Grid.build([item1, item2, item3, item4]).fill_blank_cells
    assert_equal 2, grid.columns.size
    assert_equal [item1, item2], grid.columns.map(&:head)
    assert_equal [Grid::EmptyCell.new(0, 15, 10, 10), item4], grid.columns[0].body
    assert_equal [item3], grid.columns[1].body
  end

  def test_row_inbound_y
    row = Grid::Row.new(Item.new('item3', 15, 15, 10, 10))
    assert row.inbound_y?(20)
    assert row.inbound_y?(15)
    assert row.inbound_y?(25)
    assert !row.inbound_y?(30)
    assert !row.inbound_y?(5)
  end

  def test_diff_item_moved
    # item1  item2
    # item4  item3
    item11 = Item.new('item1', 0, 0,   10, 10)
    item12 = Item.new('item2', 15, 0,  10, 10)
    item13 = Item.new('item3', 15, 15, 10, 10)
    item14 = Item.new('item4', 0, 30,  10, 10)

    grid1 = Grid.build([item11, item12, item13, item14])

    # item1  item2
    #  --    item3
    #  --    item4
    item21 = Item.new('item1', 0, 0,   10, 10)
    item22 = Item.new('item2', 15, 0,  10, 10)
    item23 = Item.new('item3', 15, 15, 10, 10)
    item24 = Item.new('item4', 15, 30,  10, 10)

    grid2 = Grid.build([item21, item22, item23, item24])
    changes = grid2.diff(grid1)

    assert_equal 1, changes.size
    change = changes[0]
    assert_equal 'move', change.type
    assert_equal item24, change.item
    assert_equal [0, 0], change.from_position
    assert_equal [1, 1], change.position
  end

  def test_diff_item_added
    # item1  item2
    # item3
    item11 = Item.new('item1', 0, 0,   10, 10)
    item12 = Item.new('item2', 15, 0,  10, 10)
    item13 = Item.new('item3', 0, 15, 10, 10)

    grid1 = Grid.build([item11, item12, item13])

    # item1  item2
    #  --    item3
    #  --    item4
    item21 = Item.new('item1', 0, 0,   10, 10)
    item22 = Item.new('item2', 15, 0,  10, 10)
    item23 = Item.new('item3', 15, 15, 10, 10)
    item24 = Item.new('item4', 15, 30,  10, 10)

    grid2 = Grid.build([item21, item22, item23, item24])
    changes = grid2.diff(grid1).sort_by(&:type)

    assert_equal 2, changes.size
    change = changes[0]
    assert_equal 'add', change.type
    assert_equal item24, change.item
    assert_equal nil, change.from_position
    assert_equal [1, 1], change.position

    change = changes[1]
    assert_equal 'move', change.type
    assert_equal item23, change.item
    assert_equal [0, 0], change.from_position
    assert_equal [1, 0], change.position
  end

  def test_diff_item_removed
    # item1  item2
    # item3
    item11 = Item.new('item1', 0, 0,   10, 10)
    item12 = Item.new('item2', 15, 0,  10, 10)
    item13 = Item.new('item3', 0, 15, 10, 10)

    grid1 = Grid.build([item11, item12, item13])

    # item1  item2
    #  --    item3
    #  --    item4
    item21 = Item.new('item1', 0, 0,   10, 10)
    item22 = Item.new('item2', 15, 0,  10, 10)
    item23 = Item.new('item3', 15, 15, 10, 10)
    item24 = Item.new('item4', 15, 30,  10, 10)

    grid2 = Grid.build([item21, item22, item23, item24])
    changes = grid1.diff(grid2).sort_by(&:type)

    assert_equal 2, changes.size

    change = changes[0]
    assert_equal 'move', change.type
    assert_equal item13, change.item
    assert_equal [1, 0], change.from_position
    assert_equal [0, 0], change.position

    change = changes[1]
    assert_equal 'removed', change.type
    assert_equal item24, change.item
    assert_equal nil, change.from_position
    assert_equal [1, 1], change.position
  end
end
