require 'test_helper'

class ExportImportTest < ActiveSupport::TestCase
  setup do
    @tool = ExportImport.new
  end

  def test_export_import
    with_card_images(walls(:one)) do |wall|
      to_file = wall.export_file(Dir.tmpdir)
      @tool.export(wall, to_file)
      assert File.exist?(to_file)

      @tool.import(to_file, :name => 'imported wall')

      wall = Wall.find_by_name('imported wall')
      assert_equal 2, wall.snapshots.size
      s1 = wall.snapshots.find_by_image('snapshot1')
      assert_equal 2, s1.cards.size
      s1.cards.each do |card|
        assert File.exist?(wall.card_image_path[card])
      end
    end
  end

  def test_export_import_after_renamed_ewall
    with_card_images(walls(:one)) do |wall|
      wall.update_attribute(:name, 'new name')

      to_file = wall.export_file(Dir.tmpdir)

      @tool.export(wall, to_file)
      @tool.import(to_file, :name => 'imported wall')

      wall = Wall.find_by_name('imported wall')
      assert_equal 2, wall.snapshots.size
      s1 = wall.snapshots.find_by_image('snapshot1')
      assert_equal 2, s1.cards.size
      s1.cards.each do |card|
        assert_match /^rect_\d+\.png$/,  card.image
        assert_match /^\/#{wall.snapshot_analysis_uri(card.snapshot)}\/rect_\d+\.png$/,  wall.card_image_uri[card]
        assert File.exist?(wall.card_image_path[card])
      end
    end
  end

  def with_card_images(wall)
    wall.ensure_root_directory
    snapshots_path = wall.snapshots_path
    FileUtils.mkdir_p(snapshots_path)
    wall.cards.each_with_index do |c, i|
      image_path = wall.card_image_path[c]
      FileUtils.mkdir_p(File.dirname(image_path))
      FileUtils.touch(image_path)
    end
    yield(wall)
  ensure
    FileUtils.rm_rf(snapshots_path)
  end
end
