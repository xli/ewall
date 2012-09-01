require 'fileutils'
require 'exifr'
require 'securerandom'

class Wall < ActiveRecord::Base

  has_many :snapshots, :dependent => :destroy, :order => 'taken_at desc'
  has_many :cards, :through => :snapshots

  has_one :mingle_wall, :dependent => :destroy
  before_create :ensure_salt
  after_create :ensure_root_directory

  attr_accessible :name, :password, :time_zone

  def self.snapshots_root
    'snapshots'
  end

  def locked?
    !password.blank?
  end

  def identifier(options={full: false})
    [name.to_s.downcase.gsub(/[\W]/, '_'), options[:full] ? salt : salt[2..6]].join('_')
  end

  def snapshots_uri
    snapshots_path[(Rails.public_path.size + 1)..-1]
  end

  def snapshots_path
    find_snapshots_path
  end

  def snapshot_uri(snapshot)
    File.join('', snapshots_uri, snapshot.image.to_s)
  end

  def snapshot_path(snapshot)
    path(snapshot_uri(snapshot))
  end

  def all_rects_uri(snapshot)
    File.join('', snapshot_analysis_uri(snapshot), 'all_rects.png')
  end

  def snapshot_analysis_path(snapshot)
    path(snapshot_analysis_uri(snapshot))
  end

  def snapshot_analysis_uri(snapshot)
    File.join(snapshots_uri, [strip(snapshot.image), 'analysis'].join('_'))
  end

  def card_snapshot(card)
    snapshots.detect {|s| s.id == card.snapshot_id}
  end

  def card_image_uri
    lambda do |card|
      File.join('', snapshot_analysis_uri(card_snapshot(card)), card.image)
    end
  end
  def card_image_path
    lambda do |card|
      path(card_image_uri[card])
    end
  end

  def new_snapshot(stream)
    self.snapshots.create!.tap do |snapshot|
      snapshot.image = "snapshot#{snapshot.id}_image#{File.extname(stream.original_filename)}"
      path = snapshot_path(snapshot)
      File.open(path, 'wb') do |file|
        file.write(stream.read)
      end
      if path =~ /.jpg$/i
        jpeg = EXIFR::JPEG.new(path)
        snapshot.width = jpeg.width
        snapshot.height = jpeg.height
        snapshot.taken_at = jpeg.date_time
      end
      snapshot.taken_at ||= snapshot.created_at
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

  def ensure_salt
    self.salt = SecureRandom.hex
  end

  private
  def default_snapshots_path
    path(Wall.snapshots_root, identifier(:full => true))
  end

  def find_snapshots_path
    Dir[path(Wall.snapshots_root, '*')].find {|d| d =~ /_#{salt}$/}
  end

  def path(*uri)
    File.join(Rails.public_path, uri)
  end

  def strip(str)
    str.to_s.downcase.gsub(/[\W]/, '_')
  end

end
