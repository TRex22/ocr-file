module OcrFile
  class FileHelpers
    extend self

    # Beware this is dangerous!
    def clear_folder(path)
      `rm -rf #{path}` # Cleanup
    end

    def open_json(path)
      JSON.parse(File.read(path))
    end

    def append_file(path, text)
      File.open(path, 'a') { |file| file.write(text) }
    end
  end
end
