module OcrFile
  module ImageEngines
    module PdfEngine
      extend self

      DEFAULT_PAGE_OPTIONS = {
        font: 'Helvetica',
        font_size: 5, #8 # 12
        text_x: 20,
        text_y: 800,
        minimum_word: 5,
      }

      def pdf_from_text(text, options = DEFAULT_PAGE_OPTIONS)
        document = HexaPDF::Document.new

        text
          .split("\n\n")
          .reject { |line| line.size < options[:minimum_word] }
          .each { |page_text| document = add_page(document, page_text, options) }

        document
      end

      def add_page(document, text, options)
        canvas = document.pages.add.canvas
        canvas.font(options[:font], size: options[:font_size])
        canvas.text(text, at: [options[:text_x], options[:text_y]])

        document
      end

      def save_pdf(document, save_file_path, optimise: true)
        document.write(pdf_save_path, optimize: true)
      end

      def open_pdf(file_path, password: '')
        HexaPDF::Document.open(file_path, decryption_opts: { password: password })
      end

      def extract_images(document, save_path, verbose: false)
        HexaPDF::CLI::Images.new.send(:each_image, document) do |image, index, pindex, (_x_ppi, _y_ppi)|
          puts "Processing page: #{pindex} ..."
          info = image.info

          if info.writable
            image_filename = "#{index}.#{image.info.extension}"
            image_path = "#{temp_path}/#{image_filename}"
            image.write(image_path)

            ocr_image(type_of_ocr, image_path, text_save_path, pindex: pindex, credentials: credentials)
          elsif command_parser.verbosity_warning?
            puts style("Warning (image #{index}, page #{pindex}): PDF image format not supported for writing", RED)
          end
        end
      end

      def merge(documents)
        document = HexaPDF::Document.new

        documents.each do |document|
          document.pages.each { |page| target.pages << target.import(page) }
        end

        document
      end
    end
  end
end
