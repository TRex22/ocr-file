lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ocr-file/version"

Gem::Specification.new do |spec|
  spec.name          = "ocr-file"
  spec.version       = OcrFile::VERSION
  spec.authors       = ["trex22"]
  spec.email         = ["contact@jasonchalom.com"]

  spec.summary       = "A tool to combine PDF tools, OCR tools and image processing into a single interface as both a CLI and a library."
  spec.description   = "A tool to combine PDF tools, OCR tools and image processing into a single interface as both a CLI and a library."
  spec.homepage      = "https://github.com/TRex22/ocr-file"

  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "bin"
  spec.executables   = ["ocr-file"] #spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "console-style", "~> 0.0.1"

  spec.add_dependency "active_attr", "~> 0.15.4"
  spec.add_dependency "hexapdf", "~> 0.23.0"
  spec.add_dependency "rtesseract", "~> 3.1.2"
  spec.add_dependency "mini_magick", "~> 4.11.0"

  # Development Dependencies
  spec.add_development_dependency "pry", "~> 0.14.1"
end
