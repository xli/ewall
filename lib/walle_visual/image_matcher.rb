module WalleVisual

  class ImageMatcher
    include OpenCVHelper
    def initialize(image_files)
      @images = image_files.map{|f| load_as_gray_image(f)}
    end

    # find image matched with given file and return the index of the image in the image files
    def match(image_file)
      image = load_as_gray_image(image_file)
      matches = image.match_descriptors(@images)
      if m = matches.max_by{|_, count| count}
        m[0]
      end
    end
  end

end