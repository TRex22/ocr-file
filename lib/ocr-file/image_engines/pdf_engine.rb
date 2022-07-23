module OcrFile
  module ImageEngines
    module PdfEngine
      extend self

      PAGE_BREAK = "\n\r\n"

      DEFAULT_PAGE_OPTIONS = {
        font: 'Helvetica',
        font_size: 5, #8 # 12
        text_x: 20,
        text_y: 800,
        minimum_word: 5,
      }

      def pdf_from_text(text, options = DEFAULT_PAGE_OPTIONS)
        document = ::HexaPDF::Document.new

        text
          .split(PAGE_BREAK)
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
        document.write(save_file_path, optimize: true)
      end

      def open_pdf(file, password: '')
        ::HexaPDF::Document.open(file, decryption_opts: { password: password })
      end

      def extract_images(document, save_path, verbose: false)
        image_paths = []

        ::HexaPDF::CLI::Images.new.send(:each_image, document) do |image, index, pindex, (_x_ppi, _y_ppi)|
          puts "Processing page: #{pindex} ..."
          info = image.info

          if info.writable
            image_filename = "#{index}.#{image.info.extension}"
            image_path = "#{save_path}/#{image_filename}"
            image.write(image_path)

            image_paths << image_path
          elsif command_parser.verbosity_warning?
            puts style("Warning (image #{index}, page #{pindex}): PDF image format not supported for writing", RED)
          end
        end

        image_paths
      end

      def insert_image(document, image_path, dimensions: nil)
        image_processor = OcrFile::ImageEngines::ImageMagick.new(
          image_path: image_path,
          temp_path: @temp_folder_path,
          save_file_path: '',
          config: @config
        )

        if dimensions
          width = dimensions[0]
          height = dimensions[1]
        else
          width = image_processor.width
          height = image_processor.height
        end

        page = document.pages.add([0, 0, width, height])
        page.canvas.image(@image || image_path, at: [0, 0], width: width, height: height)
      end

      def combine(text, pdf_of_images)
        return unless pdf_of_images.is_a?(::HexaPDF::Document)

        if text.is_a?(::HexaPDF::Document)
          pages_of_text = text.pages
        else # Assume raw text with PAGE_BREAK
          pages_of_text = text.split(PAGE_BREAK)
        end

        return unless pages_of_text.size == pdf_of_images.pages.size

        if text.is_a?(::HexaPDF::Document) # Keep the page structure

        else # Just text to embed

        end
      end

      def merge(documents)
        target = ::HexaPDF::Document.new

        documents.each do |document|
          if document.is_a?(::HexaPDF::Document)
            document.pages.each { |page| target.pages << target.import(page) }
          else # Assume an image
            insert_image(target, document)
          end
        end

        target
      end
    end
  end
end
