module OcrFile
  module TextEngines
    class ResultProcessor
      MINIMUM_WORD_LENGTH = 3

      attr_reader :text, :clear_text

      def initialize(text)
        @text = text
        @clear_text = remove_lines
      end

      # This is a very naive way of determining if we should re-do OCR with
      # shifted options
      def valid_words?
        word_size_average >= MINIMUM_WORD_LENGTH
      end

      def word_count
        @_word_count ||= clear_text.split(' ').size
      end

      def word_size_average
        @_word_size_average ||= clear_text.split(' ').map(&:size).sum / word_count
      end

      private

      def remove_lines
        text.gsub("\n", ' ').gsub("\r", ' ').gsub('  ', '')
      end
    end
  end
end
