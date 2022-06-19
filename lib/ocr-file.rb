require 'hexapdf'
require 'hexapdf/cli/images'
require 'rtesseract'
require 'mini_magick'

require 'ocr-file/version'

require 'ocr-file/image_engines/pdf_engine'
require 'ocr-file/image_engines/image_magick'
require 'ocr-file/image_engines/pdftoppm'
require 'ocr-file/ocr_engines/tesseract'
require 'ocr-file/ocr_engines/cloud_vision'
require 'ocr-file/file_helpers'
require 'ocr-file/document'
require 'ocr-file/cli'

module OcrFile
  class Error < StandardError; end
end
