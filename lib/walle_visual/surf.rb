require 'opencv'

module WalleVisual
  class SURF
    include OpenCV
    include WalleVisual::OpenCVHelper

    def load(file)
      IplImage.load(file, CV_LOAD_IMAGE_GRAYSCALE)
    end

    def surf(object_file)
      object = load(object_file).erode.equalize_hist
      # return do_surf(object, 1500)
      [2100, 1800, 1500, 1200, 900, 600, 300, 100].each do |param|
        r = do_surf(object, param)
        if r && r[0].size > 15
          return r
        end
      end
      return nil
    end

    def do_surf(object, param)
      begin
        object.extract_surf(CvSURFParams.new(param))
      rescue Exception => e
        nil
      end
    end

    def match(object_surf, image_surf)
      object_keypoints, object_descriptors = object_surf
      image_keypoints, image_descriptors = image_surf

      ptpairs = find_pairs(object_keypoints, object_descriptors, image_keypoints, image_descriptors)
      n = ptpairs.size / 2
      n < 4 ? nil : n
    rescue Exception => e
      log_error(e)
      nil
    end

    def compare_surf_descriptors(d1, d2, best, length)
      raise ArgumentError unless (length % 4) == 0
      total_cost = 0
      0.step(length - 1, 4) { |i|
        t0 = d1[i] - d2[i]
        t1 = d1[i + 1] - d2[i + 1]
        t2 = d1[i + 2] - d2[i + 2]
        t3 = d1[i + 3] - d2[i + 3]
        total_cost += t0 * t0 + t1 * t1 + t2 * t2 + t3 * t3
        break if total_cost > best
      }
      total_cost
    end

    def naive_nearest_neighbor(vec, laplacian, model_keypoints, model_descriptors)
      length = model_descriptors[0].size
      neighbor = nil
      dist1 = 1e6
      dist2 = 1e6

      model_descriptors.size.times { |i|
        kp = model_keypoints[i]
        mvec = model_descriptors[i]
        next if laplacian != kp.laplacian

        d = compare_surf_descriptors(vec, mvec, dist2, length)
        if d < dist1
          dist2 = dist1
          dist1 = d
          neighbor = i
        elsif d < dist2
          dist2 = d
        end
      }

      return (dist1 < 0.6 * dist2) ? neighbor : nil
    end

    def find_pairs(object_keypoints, object_descriptors,
                   image_keypoints, image_descriptors)
      ptpairs = []
      object_descriptors.size.times { |i|
        kp = object_keypoints[i]
        descriptor = object_descriptors[i]
        nearest_neighbor = naive_nearest_neighbor(descriptor, kp.laplacian, image_keypoints, image_descriptors)
        unless nearest_neighbor.nil?
          ptpairs << i
          ptpairs << nearest_neighbor
        end
      }
      ptpairs
    end

    def log_error(e)
      Rails.logger.debug { e.message }
      Rails.logger.debug { e.backtrace.join("\n") }
    end
  end
end
