module OcrFile
  module FileHelpers
    extend self

    def merge_pdfs(file_paths, save_file_path)
      documents = file_paths.map { |path| OcrFile::ImageEngines::PdfEngine.open_pdf(path) }
      merged_document = OcrFile::ImageEngines::PdfEngine.merge(documents)
      save_pdf(merged_document, save_file_path, optimise: true)
    end

    # Beware this is dangerous!
    def clear_folder(path)
      return unless path.include?('/temp') # Small hacky safeguard
      `rm -rf #{path}` # Cleanup
    end

    def make_directory(path)
      `mkdir -p #{path}`
    end

    def open_json(path)
      JSON.parse(File.read(path))
    end

    def append_file(path, text)
      File.open(path, 'a') { |file| file.write(text) }
    end

    def open_text_file(path)
      File.read(path)
    end
  end
end
