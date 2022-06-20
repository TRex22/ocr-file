module OcrFile
  module ImageEngines
    class ImageMagick
      # TODO:
      # Conversion of image types
      # Rotation and detection of skew

      attr_reader :image_path, :image, :temp_path, :save_file_path, :config

      def initialize(image_path:, temp_path:, save_file_path:, config:)
        @image_path = image_path
        @config = config
        @save_file_path = save_file_path

        @temp_path = temp_path

        # Will be available in the next version of MiniMagick > 4.11.0
        # https://github.com/minimagick/minimagick/pull/541
        # MiniMagick.configure do |config|
        #   # cli_version  graphicsmagick?  imagemagick7?  imagemagick? version
        #   config.tmpdir = File.join(Dir.tmpdir, @temp_path)
        # end

        @image = MiniMagick::Image.open(image_path)
      end

      def convert
        return @image_path unless @config[:image_preprocess]

        @config[:effects].each do |effect|
          self.send(effect.to_sym)
        end
      end

      def save
        image.write(@save_file_path)
      end

      # Effects
      # http://www.imagemagick.org/script/command-line-options.php
      def bw
        @image.alpha('off')
        @image.auto_threshold("otsu")
      end

      def norm
        @image.equalize
      end

      # Most likely not going to be configurable because
      # these are aggressive parameters used to optimised OCR results
      # and not the final results of the PDFs
      def sharpen
        @image.sharpen('0x4') # radiusXsigma
      end

      def deskew
        @image.deskew('40%') # threshold recommended in the docs
      end

      def despeckle
        @image.despeckle
      end
    end
  end
end
