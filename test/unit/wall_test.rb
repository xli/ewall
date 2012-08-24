require 'test_helper'

class WallTest < ActiveSupport::TestCase
  def test_identifier
    wall = walls(:one)
    assert_equal "test_story_wall_#{wall.salt[2..6]}", wall.identifier
    assert_equal "test_story_wall_#{wall.salt}", wall.identifier(:full => true)
  end

  def test_create_salt_when_create_wall
    wall = Wall.create(:name => 'haha')
    assert wall.salt
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
    path = File.join(Rails.public_path, 'snapshots', "x1_#{wall.salt}")
    FileUtils.mkdir_p(path)
    assert_equal path, wall.snapshots_path
  ensure
    FileUtils.rm_rf(path)
  end

  def test_snapshots_uri_should_be_relative_to_snapshots_path
    wall = walls(:one)
    path = File.join(Rails.public_path, 'snapshots', "x1_#{wall.salt}")
    FileUtils.mkdir_p(path)

    assert_equal "snapshots/x1_#{wall.salt}", wall.snapshots_uri
  ensure
    FileUtils.rm_rf(path)
  end
end
