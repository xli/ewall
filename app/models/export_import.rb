require 'zipper'

class ExportImport
  include Zipper

  def initialize(target_dir='/tmp')
    @target_dir = target_dir
  end

  def export(wall)
    dir = File.join(@target_dir, wall.identifier)
    export_file = "#{dir}.ewall"
    FileUtils.mkdir_p(dir)
    begin
      Dir.chdir(dir) do
        write('wall.json', wall)
        write('snapshots.json', wall.snapshots)
        wall.snapshots.each{|s| write("snapshot#{s.id}_cards.json", s.cards)}
        FileUtils.cp_r(wall.snapshots_path, 'snapshots')
        file = zip(dir)
        FileUtils.mv(file, export_file)
      end
    ensure
      FileUtils.rm_rf(dir)
    end
    export_file
  end

  def import(export_file, options)
    dir = File.join(@target_dir, File.basename(export_file).split('.')[0])
    unzip(export_file, dir)
    protected_attrs = ['id', 'wall_id', 'snapshot_id', 'created_at', 'updated_at']
    Dir.chdir(dir) do
      wall = Wall.create!(read('wall.json').except(*protected_attrs).merge(options))

      read('snapshots.json').each do |snapshot|
        s = wall.snapshots.create!(snapshot.except(*protected_attrs))
        read("snapshot#{snapshot['id']}_cards.json").each do |card|
          s.cards.create!(card.except(*protected_attrs))
        end
      end
      FileUtils.rm_rf(wall.snapshots_path)
      FileUtils.cp_r('snapshots', wall.snapshots_path)
      wall
    end
  ensure
    FileUtils.rm_rf(dir)
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
