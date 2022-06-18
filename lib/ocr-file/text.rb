module OcrFile
  class Text
    attr_reader :text, :save_file_path, :config

    def initialize(text:, save_file_path:, config:)
      @text = text
      @save_file_path = save_file_path
      @config = config
    end
  end
end
