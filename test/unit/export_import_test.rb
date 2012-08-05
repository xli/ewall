require 'test_helper'

class ExportImportTest < ActiveSupport::TestCase
  def test_export_import
    wall = walls(:one)
    FileUtils.mkdir_p(wall.snapshots_path)
    FileUtils.touch(File.join(wall.snapshots_path, 'image'))

    to_file = wall.export_file(Dir.tmpdir)
    tool = ExportImport.new
    file = tool.export(wall, to_file)
    assert_equal file, to_file
    tool.import(file, :name => 'new name')
    wall = Wall.find_by_name('new name')
    assert_equal 2, wall.snapshots.size
    s1 = wall.snapshots.find_by_image('snapshot1')
    assert_equal 2, s1.cards.size
    assert File.exist?(File.join(Rails.public_path, 'snapshots', 'new_name', 'image'))
  end

end
