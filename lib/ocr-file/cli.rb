module OcrFile
  class Cli
    attr_reader :args

    def initialize(args)
      @args = args
    end

    def valid?
      return true if args.size == 2 || args.size == 3
      false
    end

    def invalid?
      !valid?
    end

    def call
      # TODO: Use ConsoleStyle::Functions
      # TODO: Heading and better CLI interface
      # Simple cli for now
      puts "OCR Tool © Jason Chalom 2022, Version: #{OcrFile::VERSION}"
      abort "File path, Save Folder Paths, and output type (pdf, txt) are required!" if invalid?

      # Using default config for now
      original_file_path = args.first
      save_file_path = args.second
      output_type = args.third

      document = OcrFile::Document.new(original_file_path: original_file_path, save_file_path: save_file_path)

      if output_type.downcase.include?('pdf')
        document.to_pdf
      elsif output_type.downcase.include?('txt') || output_type.downcase.include?('text')
        document.to_text
      else # Display in console
        puts document.to_s
      end
    end
  end
end
