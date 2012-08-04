module Zipper
  class InvalidZipFile < StandardError
  end
  
  def zip(basedir)
    zip_file = "#{basedir}.zip"
    system("cd '#{File.expand_path(basedir)}' && zip -r '#{File.expand_path(zip_file)}' . 2>&1 > /dev/null")
    raise "Could not create zip file: #{zip_file}" unless File.exist?(zip_file)
    zip_file
  end
  
  def unzip(zip_file, to_dir)
    system("unzip '#{zip_file}' -d '#{to_dir}' 2>/dev/null >/dev/null")
    raise InvalidZipFile, "This is not a valid zip file, zip file: #{zip_file}, to dir: #{to_dir}" if $? != 0
  end
end