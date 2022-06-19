module OcrFile
  module ImageEngines
    module Pdftoppm
      extend self

      # TODO: other options
      # https://www.xpdfreader.com/pdftoppm-man.html
      # password
      # −mono Generate a monochrome PBM file (instead of an RGB PPM file).
      # −gray Generate a grayscale PGM file (instead of an RGB PPM file).
      # −cmyk Generate a CMYK PAM file (instead of an RGB PPM file).
      def images_from_pdf(pdf_path, save_path, filename: 'image', filetype: 'png', quality: 100, dpi: 300, verbose: true)
        print 'Generating screenshots of each PDF page ... '

        if filetype == 'jpg'
          `pdftoppm -jpeg -jpegopt quality=#{quality} -r #{dpi} #{pdf_path} #{save_path}/#{filename}`
        else
          `pdftoppm -#{filetype} -r #{dpi} #{pdf_path} #{save_path}/#{filename}`
        end

        puts 'Complete!'

        OcrFile::FileHelpers.fetch_temp_image_paths(save_path, filename, filetype)
      end
    end
  end
end
