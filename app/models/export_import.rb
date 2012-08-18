require 'zipper'
require 'securerandom'

class ExportImport
  include Zipper

  attr_reader :target_dir

  def initialize(tmpdir=Dir.tmpdir)
    @target_dir = File.join(tmpdir, SecureRandom.hex)
  end

  def ensure_target_dir
    FileUtils.mkdir_p(@target_dir)
  end

  def export(wall, export_file)
    zip_dir = File.join(File.dirname(export_file), wall.identifier)
    FileUtils.mkdir_p(zip_dir)
    begin
      Dir.chdir(zip_dir) do
        write('wall.json', wall)
        write('snapshots.json', wall.snapshots)
        wall.snapshots.each{|s| write("snapshot#{s.id}_cards.json", s.cards)}
        FileUtils.cp_r(wall.snapshots_path, 'snapshots')
        file = zip(zip_dir)
        FileUtils.mv(file, export_file)
      end
    ensure
      FileUtils.rm_rf(zip_dir)
    end
  end

  def import(export_file, options={})
    ensure_target_dir
    unzip(export_file, @target_dir)
    protected_attrs = ['id', 'wall_id', 'snapshot_id', 'created_at', 'updated_at']
    Dir.chdir(@target_dir) do
      wall = Wall.create!(read('wall.json').except(*protected_attrs).merge(options))
      wall_snapshots_path = wall.snapshots_path

      FileUtils.rm_rf(wall_snapshots_path)
      FileUtils.cp_r('snapshots', wall_snapshots_path)

      read('snapshots.json').each do |snapshot|
        s = wall.snapshots.create!(snapshot.except(*protected_attrs))
        read("snapshot#{snapshot['id']}_cards.json").each do |card|
          card_attrs = card.except(*protected_attrs)
          # card image example: /snapshots/2_9/snapshot27_image_jpg_analysis/rect_141.png
          if card_attrs['image']
            relative_path = File.join(card_attrs['image'].split("/")[3..-1])
            card_attrs['image'] = File.join('', wall.snapshots_uri, relative_path)
          end
          s.cards.create!(card_attrs)
        end
      end
      wall
    end
  ensure
    FileUtils.rm_rf(@target_dir)
  end

  private
  def write(f, obj)
    File.open(f, 'w') do |io|
      io.write(obj.to_json)
    end
  end

  def read(f)
    ActiveSupport::JSON.decode File.read(f)
  end
end
