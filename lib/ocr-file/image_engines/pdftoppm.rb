module OcrFile
  module ImageEngines
    module Pdftoppm
      extend self

      def images_from_pdf(pdf_path, save_path, filename: 'image', quality: 100, dpi: 300)
        `pdftoppm -jpeg -jpegopt quality=#{quality} -r #{dpi} #{pdf_path} #{save_path}/#{filename}`
      end
    end
  end
end
