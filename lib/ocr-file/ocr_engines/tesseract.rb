module OcrFile
  module OcrEngines
    module Tesseract
      extend self

      def ocr_to_text(file_path, options: {})
        image = RTesseract.new(file_path)
        image.to_s # Getting the value
      end

      def ocr_to_pdf(file_path, options: {})
        image = RTesseract.new(file_path)
        image.to_pdf  # Getting open file of pdf
      end
    end
  end
end
