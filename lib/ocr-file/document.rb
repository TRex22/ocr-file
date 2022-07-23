module OcrFile
  class Document
    # TODO: Skewness / text orientation detection
    # TODO: Better handwriting analysis

    ACCEPTED_IMAGE_TYPES = ['png', 'jpeg', 'jpg', 'tiff', 'bmp']
    PAGE_BREAK = "\n\r\n" # TODO: Make configurable
    EFFECTS_TO_REMOVE = ['', 'norm', 'remove_shadow', 'bw']
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
      image_annotator: nil, # Needed for Cloud-Vision
      type_of_ocr: OcrFile::OcrEngines::CloudVision::DOCUMENT_TEXT_DETECTION,
      ocr_engine: 'tesseract', # 'cloud-vision'
      # Image Pre-Processing
      image_preprocess: true,
      effects: ['despeckle', 'deskew', 'enhance', 'sharpen', 'remove_shadow', 'bw'],
      automatic_reprocess: true,
      # PDF to Image Processing
      optimise_pdf: true,
      extract_pdf_images: true, # if false will screenshot each PDF page
      temp_filename_prefix: 'image',
      spelling_correction: true,
      keep_files: false,
      # Console Output
      verbose: true,
      timing: true
    }

    attr_reader :original_file_path,
      :filename,
      :save_file_path,
      :final_save_file,
      :config,
      :ocr_engine,
      :start_time,
      :end_time

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
      @original_file_path.downcase.include?('.pdf')
    end

    def image?
      return false if pdf?
      ACCEPTED_IMAGE_TYPES.any? { |type| @original_file_path.downcase.include?(".#{type}") }
    end

    # Treat anything which isnt a PDF or image as text
    def text?
      !pdf? && !image?
    end

    # Trigger OCR pipeline
    def to_pdf
      @start_time = Time.now
      find_best_image_processing(save: false) if config[:automatic_reprocess] && !text?

      if pdf?
        ocr_pdf_to_searchable_pdf
      elsif text?
        text_to_pdf
      else # is an image
        ocr_image_to_pdf
      end

      close

      @end_time = Time.now
      print_time
    end

    def to_text
      @start_time = Time.now
      return ::OcrFile::FileHelpers.open_text_file(@original_file_path) if text?

      find_best_image_processing(save: true)
      close

      @end_time = Time.now
      print_time
    end

    def to_s
      @start_time = Time.now
      return ::OcrFile::FileHelpers.open_text_file(@original_file_path) if text?

      text = find_best_image_processing(save: false)

      close

      @end_time = Time.now
      print_time

      text
    end

    def close
      return if keep_files?
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

    def keep_files?
      config['keep_files']
    end

    def create_temp_folder
      date = Time.now.to_s.split(' ').first

      @temp_folder_path = "#{save_file_path}/temp-#{date}/".gsub(' ', '\ ')
      ::OcrFile::FileHelpers.make_directory(@temp_folder_path)
    end

    def process_image(path)
      return path unless @config[:image_preprocess]

      create_temp_folder
      save_file_path = "#{@temp_folder_path}/#{Time.now.to_i}.#{@config[:filetype]}"

      image_processor = OcrFile::ImageEngines::ImageMagick.new(
        image_path: path,
        temp_path: @temp_folder_path,
        save_file_path: save_file_path,
        config: @config
      )

      image_processor.convert!
    end

    def ocr_pdf_to_searchable_pdf
      create_temp_folder
      image_paths = extract_image_paths_from_pdf(@original_file_path)

      pdfs_to_merge = []

      image_paths.each do |image_path|
        puts image_path
        pdfs_to_merge << @ocr_engine.ocr_to_pdf(process_image(image_path), options: @config)
      end

      merged_pdf = OcrFile::ImageEngines::PdfEngine.merge(pdfs_to_merge)

      OcrFile::ImageEngines::PdfEngine
        .save_pdf(merged_pdf, "#{@final_save_file}.pdf", optimise: @config[:optimise_pdf])
    end

    def text_to_pdf
      text = ::OcrFile::FileHelpers.open_text_file(@original_file_path)
      text = OcrFile::TextEngines::ResultProcessor.new(text).correct if config[:spelling_correction]

      pdf_file = OcrFile::ImageEngines::PdfEngine.pdf_from_text(text, @config)

      OcrFile::ImageEngines::PdfEngine
        .save_pdf(pdf_file, "#{@final_save_file}.pdf", optimise: @config[:optimise_pdf])
    end

    def ocr_image_to_pdf
      find_best_image_processing(save: false) if config[:automatic_reprocess]

      pdf_document = @ocr_engine.ocr_to_pdf(process_image(@original_file_path), options: @config)
      OcrFile::ImageEngines::PdfEngine
        .save_pdf(pdf_document, "#{@final_save_file}.pdf", optimise: @config[:optimise_pdf])
    end

    def ocr_pdf_to_text(save:)
      create_temp_folder
      image_paths = extract_image_paths_from_pdf(@original_file_path)

      text = ''

      image_paths.each do |image_path|
        puts image_path
        text = @ocr_engine.ocr_to_text(process_image(image_path), options: @config) || ''

        text = OcrFile::TextEngines::ResultProcessor.new(text).correct if config[:spelling_correction]
        text = "#{text}#{PAGE_BREAK}#{text}"
      end

      if save
        ::OcrFile::FileHelpers.append_file("#{@final_save_file}.txt", "#{text}#{PAGE_BREAK}")
      else
        text
      end
    end

    def ocr_image_to_text(save:)
      create_temp_folder

      text = @ocr_engine.ocr_to_text(process_image(@original_file_path), options: @config)
      text = OcrFile::TextEngines::ResultProcessor.new(text).correct if config[:spelling_correction]

      if save
        ::OcrFile::FileHelpers.append_file("#{@final_save_file}.txt", text)
      else
        text
      end
    end

    def ocr_file_to_text(save:)
      if pdf?
        ocr_pdf_to_text(save: save)
      else # is an image
        ocr_image_to_text(save: save)
      end
    end

    def find_best_image_processing(save:)
      ocr_file_to_text(save: save) unless config[:automatic_reprocess]

      text = ''
      best_text_count = 0
      best_effects = config[:effects]

      effects_to_test = [''] + (EFFECTS_TO_REMOVE - (EFFECTS_TO_REMOVE - config[:effects]))
      effects_to_test.each do |effect|
        text = test_ocr_settings(effect)
        processed_result = OcrFile::TextEngines::ResultProcessor.new(text)

        if processed_result.count_of_issues < best_text_count
          best_text_count = processed_result.count_of_issues
          best_effects = config[:effects]
        end

        break if processed_result.valid_words?
      end

      # Fallback
      if OcrFile::TextEngines::ResultProcessor.new(text).invalid_words?
        config[:effects] = best_effects
        text = ocr_file_to_text(save: false)
      end

      # Adds in extra operations which is unfortunately inefficient
      if save
        ocr_file_to_text(save: save)
      else
        text
      end
    end

    def test_ocr_settings(effect)
      config[:effects] = config[:effects] - [effect]
      ocr_file_to_text(save: false)
    end

    def print_time
      puts "Total Time: #{end_time-start_time} secs.\n\n" if config[:timing]
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
