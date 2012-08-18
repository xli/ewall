require 'test_helper'

class WallTest < ActiveSupport::TestCase
  def test_identifier
    wall = walls(:one)
    assert_equal "test_story_wall_#{wall.id}", wall.identifier
  end

  def test_should_create_snapshots_path_if_it_does_not_exist
    wall = Wall.create(:name => 'haha')
    assert File.exist?(wall.snapshots_path)
  ensure
    FileUtils.rm_rf(wall.snapshots_path)
  end

  def test_change_wall_name_should_not_change_snapshots_path
    wall = Wall.create(:name => 'haha')
    p1 = wall.snapshots_path
    wall.update_attribute(:name, 'haha2')
    assert_equal p1, wall.snapshots_path
  ensure
    FileUtils.rm_rf(wall.snapshots_path)
  end

  def test_should_read_existing_snapshots_path
    wall = walls(:one)
    path = File.join(Rails.public_path, 'snapshots', "x1_#{wall.id}")
    FileUtils.mkdir_p(path)
    assert_equal path, wall.snapshots_path
  ensure
    FileUtils.rm_rf(path)
  end

  def test_snapshots_uri_should_be_relative_to_snapshots_path
    wall = walls(:one)
    path = File.join(Rails.public_path, 'snapshots', "x1_#{wall.id}")
    FileUtils.mkdir_p(path)

    assert_equal "snapshots/x1_#{wall.id}", wall.snapshots_uri
  ensure
    FileUtils.rm_rf(path)
  end
end
