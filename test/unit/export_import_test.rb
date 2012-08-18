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
        assert File.exist?(card.image_path)
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
        assert_match /^\/snapshots\/#{wall.identifier}\/rect_\d+\.png$/,  card.image
        assert File.exist?(card.image_path)
      end
    end
  end

  def with_card_images(wall)
    wall.ensure_root_directory
    snapshots_path = wall.snapshots_path
    FileUtils.mkdir_p(snapshots_path)
    wall.cards.each_with_index do |c, i|
      img = "rect_#{i}.png"
      FileUtils.touch(File.join(snapshots_path, img))
      c.update_attribute :image, File.join('', wall.snapshots_uri, img)
    end
    yield(wall)
  ensure
    FileUtils.rm_rf(snapshots_path)
  end
end
