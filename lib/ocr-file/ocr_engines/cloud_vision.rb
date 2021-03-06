module OcrFile
  module OcrEngines
    module CloudVision
      extend self

      DEFAULT_LANGUAGE = 'en'

      # Available Types: https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-vision/lib/google/cloud/vision/v1/image_annotator_pb.rb
      TEXT_DETECTION = 'TEXT_DETECTION' # Used for low-quality images
      DOCUMENT_TEXT_DETECTION = 'DOCUMENT_TEXT_DETECTION' # Used for dense text documents

      def id
        'cloud-vision'
      end

      def ocr_to_text(file_path, options: { type_of_ocr: '', image_annotator: nil })
        type_of_ocr = options[:type_of_ocr]
        image_annotator = options[:image_annotator]

        response = detect_text(type_of_ocr, file_path, image_annotator)
        extract_text(response)
      end

      def ocr_to_pdf(file_path, options: { type_of_ocr: '', image_annotator: nil })
        text = ocr_to_text(file_path, options: { type_of_ocr: '', image_annotator: nil })
        OcrFile::ImageEngines::PdfEngine.pdf_from_text(text, options)
      end

      private

      def detect_text(type_of_ocr, image_path, image_annotator)
        if type_of_ocr == 'DOCUMENT_TEXT_DETECTION'
          image_annotator.document_text_detection(image: image_path)
        else
          image_annotator.text_detection(image: image_path)
        end
      end

      def extract_text(response)
        raw_text = ''
        foreign_text = ''

        response.responses.each do |section|
          section.text_annotations.each do |annotation|
            raw_text << annotation.description

            if annotation.locale && annotation.locale != DEFAULT_LANGUAGE
              foreign_text << annotation.description
            end
          end
        end

        raw_text = raw_text.split("\n")
        raw_text.pop # Remove the last line
        raw_text.join("\n")
      end
    end
  end
end
