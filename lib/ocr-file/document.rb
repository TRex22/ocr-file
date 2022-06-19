module OcrFile
  class Document
    ACCEPTED_IMAGE_TYPES = ['png', 'jpeg', 'jpg', 'tiff', 'bmp']
    DEFAULT_CONFIG = {
      # Images from PDF
      filetype: 'png',
      quality: 100,
      dpi: 300,
      # Text to PDF
      font: 'Helvetica',
      font_size: 5, #8 # 12
      text_x: 20,
      text_y: 800,
      minimum_word: 5,
      # Cloud-Vision OCR
      type_of_ocr: OcrFile::OcrEngines::CloudVision::DOCUMENT_TEXT_DETECTION,
      # requires image_annotator to be passed through
      ocr_engine: 'tesseract', # 'cloud-vision'
      # Image Pre-Processing
      image_pre_preprocess: true,
      effects: ['bw', 'norm'],
      threshold: 0.25,
      optimise_pdf: true,
      extract_pdf_images: true, # if false will screenshot each PDF page
      temp_filename_prefix: 'image',
      verbose: true,
    }

    attr_reader :original_file_path,
      :filename,
      :save_file_path,
      :final_save_file,
      :config,
      :ocr_engine

    # save_file_path will also generate a tmp path for tmp files. Expected folder path
    # TODO: Add in more input validation
    def initialize(original_file_path:, save_file_path:, config: DEFAULT_CONFIG)

      @original_file_path = original_file_path
      @filename = original_file_path.split('/').last.split('.').first

      date = Time.now.to_s.split(' ').first

      @save_file_path = save_file_path
      @final_save_file = "#{@save_file_path}/#{@filename}-#{date}-#{Time.now.to_i}"

      @config = config
      @ocr_engine = find_ocr_engine(config[:ocr_engine])
    end

    def pdf?
      @original_file_path.include?('.pdf')
    end

    def image?
      return false if pdf?
      ACCEPTED_IMAGE_TYPES.any? { |type| @original_file_path.include?(".#{type}")}
    end

    # Treat anything which isnt a PDF or image as text
    def text?
      !pdf? && !image?
    end

    def to_pdf
      if pdf?
        create_temp_folder
        image_paths = extract_image_paths_from_pdf(@original_file_path)

        pdfs_to_merge = []

        image_paths.each do |image_path|
          pdfs_to_merge << @ocr_engine.ocr_to_pdf(image_path, options: @config)
        end

        merged_pdf = OcrFile::ImageEngines::PdfEngine.merge(pdfs_to_merge)

        OcrFile::ImageEngines::PdfEngine
          .save_pdf(merged_pdf, "#{@final_save_file}.pdf", optimise: @config[:optimise_pdf])

        close
      else # is an image
        ocr_image_to_pdf
      end
    end

    def to_text
      if pdf?
        create_temp_folder
        image_paths = extract_image_paths_from_pdf(@original_file_path)

        image_paths.each do |image_path|
          text = @ocr_engine.ocr_to_text(image_path, options: @config)
          ::OcrFile::FileHelpers.append_file("#{@final_save_file}.txt", "#{text}\n\r\n")
        end

        close
      else # is an image
        ocr_image_to_text(save: true)
      end
    end

    def to_s
      if pdf?
        create_temp_folder
        image_paths = extract_image_paths_from_pdf(@original_file_path)

        text = ''

        image_paths.each do |image_path|
          text = "#{text}\n\r\n#{@ocr_engine.ocr_to_text(image_path, options: @config)}"
        end

        close
        text
      else # is an image
        ocr_image_to_text(save: false)
      end
    end

    def close
      ::OcrFile::FileHelpers.clear_folder(@temp_folder_path)
    end

    private

    def extract_image_paths_from_pdf(file_path)
      document = OcrFile::ImageEngines::PdfEngine.open_pdf(file_path, password: '')

      if @config[:extract_pdf_images]
        OcrFile::ImageEngines::PdfEngine
          .extract_images(document, @temp_folder_path, verbose: @config[:verbose])
      else # Generate screenshots of each image
        OcrFile::ImageEngines::Pdftoppm.images_from_pdf(
          file_path,
          @temp_folder_path,
          filename: @config[:temp_filename_prefix],
          filetype: @config[:filetype],
          quality: @config[:quality],
          dpi: @config[:dpi],
          verbose: @config[:verbose]
        )
      end
    end

    def create_temp_folder
      # TODO: Make this a bit more robust
      @temp_folder_path = "#{save_file_path}/temp/".gsub(' ', '\ ')
      ::OcrFile::FileHelpers.make_directory(@temp_folder_path)
    end

    def ocr_image_to_pdf
      pdf_document = @ocr_engine.ocr_to_pdf(@original_file_path, options: @config)
      OcrFile::ImageEngines::PdfEngine
        .save_pdf(pdf_document, "#{@final_save_file}.pdf", optimise: @config[:optimise_pdf])
    end

    def ocr_image_to_text(save: true)
      text = @ocr_engine.ocr_to_text(@original_file_path, options: @config)

      if save
        ::OcrFile::FileHelpers.append_file("#{@final_save_file}.txt", text)
      else
        text
      end
    end

    def find_ocr_engine(engine_id)
      ocr_engine_constants
        .map { |c| ocr_module(c) }
        .find { |selected_module| selected_module.id == engine_id }
    end

    def ocr_module(constant)
      OcrFile::OcrEngines.const_get(constant)
    end

    def ocr_engine_constants
      OcrFile::OcrEngines.constants
    end
  end
end
