module OcrFile
  module TextEngines
    class ResultProcessor
      MINIMUM_WORD_LENGTH = 4
      ACCEPTABLE_NUMBER_OF_ERRORS = 8 # Random number I pulled out of nowhere
      ACCEPTABLE_UNIDENTIFIED_WORDS = 8 # Random number I pulled out of nowhere

      # REGEX
      ASCII_ONLY = /[^\u{0000}-\u{007f}]/
      NOISE_CHARACTERS = /[^\w\s\/-]/
      DUPLICATE_WORDS = /\b(\w+)\s+\1\b/
      EVERYTHING_BUT_CHARACTERS = /[^\w\s]|(\d)/

      attr_reader :text, :clear_text, :clear_words

      def initialize(text)
        @text = text
        @clear_text = generate_clear_text
      end

      # This is a very naive way of determining if we should re-do OCR with
      # shifted options
      def valid_words?
        word_size_average >= MINIMUM_WORD_LENGTH &&
          Spellchecker.check(clear_text).count <= ACCEPTABLE_NUMBER_OF_ERRORS &&
          unidentified_words <= ACCEPTABLE_UNIDENTIFIED_WORDS
      end

      def word_count
        return 0 if clear_text.nil?
        @_word_count ||= clear_text.split(' ').size
      end

      def word_size_average
        return 0 if clear_text.nil?
        @_word_size_average ||= clear_text.split(' ').map(&:size).sum / word_count
      end

      # Assume English
      def unidentified_words
        clear_words.reject { |word| Spellchecker::Dictionaries::EnglishWords.include?(word) }.count
      end

      private

      def clear_words
        @_clear_words ||= clear_text.gsub(EVERYTHING_BUT_CHARACTERS, '').split(' ')
      end

      def generate_clear_text
        remove_lines
          .gsub(ASCII_ONLY, '')
          .gsub(NOISE_CHARACTERS, '')
          .gsub(DUPLICATE_WORDS, '')
      end

      def remove_lines
        text&.gsub("\n", ' ')&.gsub("\r", ' ')&.gsub('  ', '')
      end
    end
  end
end
