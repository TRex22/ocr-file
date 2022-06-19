module OcrFile
  module ImageEngines
    module Pdftoppm
      extend self

      def images_from_pdf(pdf_path, save_path, filename: 'image', filetype: 'png', quality: 100, dpi: 300, verbose: true)
        print 'Generating screenshots of each PDF page ... '

        if filetype == 'jpg'
          `pdftoppm -jpeg -jpegopt quality=#{quality} -r #{dpi} #{pdf_path} #{save_path}/#{filename}`
        else
          `pdftoppm -#{filetype} -r #{dpi} #{pdf_path} #{save_path}/#{filename}`
        end

        puts 'Complete!'

        OcrFile::ImageEngines::PdfEngine
          .fetch_temp_image_paths(pdf_path, save_path, filename, filetype)
      end
    end
  end
end
