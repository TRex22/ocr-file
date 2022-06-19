module OcrFile
  module OcrEngines
    module Tesseract
      extend self

      def id
        'tesseract'
      end

      def ocr_to_text(file_path, options: {})
        image = ::RTesseract.new(file_path)
        image.to_s # Getting the value
      end

      def ocr_to_pdf(file_path, options: {})
        image = ::RTesseract.new(file_path)
        raw_output = image.to_pdf  # Getting open file of pdf
        OcrFile::ImageEngines::PdfEngine.open_pdf(raw_output, password: '')
      end
    end
  end
end
