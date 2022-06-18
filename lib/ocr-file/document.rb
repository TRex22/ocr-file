module OcrFile
  class Document
    attr_reader :original_file_path, :save_file_path, :config

    def initialize(original_file_path:, save_file_path:, config:)
      @original_file_path = original_file_path
      @save_file_path = save_file_path
      @config = config
    end
  end
end
