require 'fileutils'
require 'exifr'
class Wall < ActiveRecord::Base

  has_many :snapshots, :dependent => :destroy, :order => 'taken_at desc, created_at desc'
  has_many :cards, :through => :snapshots

  has_one :mingle_wall, :dependent => :destroy

  attr_accessible :name, :password

  def locked?
    !password.blank?
  end

  def identifier
    name.to_s.downcase.gsub(/[\W]/, '_')
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

  def snapshots_path
    File.join(Rails.public_path, 'snapshots', identifier)
  end

  def export(file)
    ExportImport.new.export(self, file)
  end

  def export_file(dir)
    [File.join(dir, identifier), 'ewall'].join('.')
  end
end
