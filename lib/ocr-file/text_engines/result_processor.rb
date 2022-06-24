module OcrFile
  module TextEngines
    class ResultProcessor
      MINIMUM_WORD_LENGTH = 4
      ACCEPTABLE_NUMBER_OF_ERRORS = 8 # Random number I pulled out of nowhere
      ACCEPTABLE_UNIDENTIFIED_WORDS = 8 # Random number I pulled out of nowhere

      # REGEX
      ASCII_ONLY = /[^\u{0000}-\u{007f}]/
      NOISE_CHARACTERS = /[^\w\s\/-;:]/
      DUPLICATE_WORDS = /\b(\w+)\s+\1\b/
      EVERYTHING_BUT_CHARACTERS = /[^\w\s]|(\d)/

      attr_reader :text, :clear_text

      def initialize(text)
        @text = text
        @clear_text = generate_clear_text || text
      end

      def correct
        Spellchecker.correct(text.gsub(NOISE_CHARACTERS, '')).gsub("\n ", "\n").strip
      end

      # This is a very naive way of determining if we should re-do OCR with
      # shifted options
      def valid_words?
        word_size_average >= MINIMUM_WORD_LENGTH &&
          spelling_error_count <= ACCEPTABLE_NUMBER_OF_ERRORS &&
          unidentified_word_count <= ACCEPTABLE_UNIDENTIFIED_WORDS
      end

      def invalid_words?
        !valid_words?
      end

      def word_count
        return 0 if empty_text?
        @_word_count ||= clear_words.size
      end

      def word_size_average
        return 0 if empty_text?
        @_word_size_average ||= clear_words.map(&:size).sum / word_count
      end

      # Assume English
      def unidentified_word_count
        clear_words.reject { |word| Spellchecker::Dictionaries::EnglishWords.include?(word) }.count
      end

      def spelling_error_count
        Spellchecker.check(clear_text).count
      end

      def count_of_issues
        spelling_error_count + unidentified_word_count
      end

      private

      def empty_text?
        clear_text.nil? || clear_text == ''
      end

      def clear_words
        @clear_words ||= clear_text.gsub(EVERYTHING_BUT_CHARACTERS, '').split(' ')
      end

      def generate_clear_text
        remove_lines
          &.gsub(ASCII_ONLY, '')
          &.gsub(NOISE_CHARACTERS, '')
          &.gsub(DUPLICATE_WORDS, '')
      end

      def remove_lines
        text&.gsub("\n", ' ')&.gsub("\r", ' ')&.gsub('  ', '')
      end
    end
  end
end
