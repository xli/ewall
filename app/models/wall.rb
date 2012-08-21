require 'fileutils'
require 'exifr'
class Wall < ActiveRecord::Base

  has_many :snapshots, :dependent => :destroy, :order => 'taken_at desc, created_at desc'
  has_many :cards, :through => :snapshots

  has_one :mingle_wall, :dependent => :destroy
  after_create :ensure_root_directory

  attr_accessible :name, :password, :time_zone

  def self.snapshots_root
    'snapshots'
  end

  def locked?
    !password.blank?
  end

  def identifier
    [name.to_s.downcase.gsub(/[\W]/, '_'), id].join('_')
  end

  def snapshots_uri
    snapshots_path[(Rails.public_path.size + 1)..-1]
  end

  def snapshots_path
    find_snapshots_path
  end

  def new_snapshot(stream)
    self.snapshots.create!.tap do |snapshot|
      snapshot.image = "snapshot#{snapshot.id}_image#{File.extname(stream.original_filename)}"
      File.open(snapshot.snapshot_path, 'wb') do |file|
        file.write(stream.read)
      end
      if snapshot.snapshot_path =~ /.jpg$/i
        jpeg = EXIFR::JPEG.new(snapshot.snapshot_path)
        snapshot.width = jpeg.width
        snapshot.height = jpeg.height
        snapshot.taken_at = jpeg.date_time
      end
    end
  end

  def export(file)
    ExportImport.new.export(self, file)
  end

  def export_file(dir)
    [File.join(dir, identifier), 'ewall'].join('.')
  end

  def ensure_root_directory
    FileUtils.mkdir_p(default_snapshots_path)
  end

  private
  def default_snapshots_path
    File.join(Rails.public_path, Wall.snapshots_root, identifier)
  end

  def find_snapshots_path
    Dir[File.join(Rails.public_path, Wall.snapshots_root, '*')].find {|d| d =~ /_#{id}$/}
  end

end
