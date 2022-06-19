#  OCR-File
A tool to combine PDF tools, OCR tools and image processing into a
single interface as both a CLI and a library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ocr-file'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ocr-file

### Other required dependencies
You will need to install `tesseract` with your desired language on your system,
`pdftoppm` needs to be available and also `image-magick`.

## Usage
```ruby
  require 'ocr-file'

  config = {
    # Images from PDF
    filetype: 'png',
    quality: 100,
    dpi: 300,
    # Text to PDF
    font: 'Helvetica',
    font_size: 5, #8 # 12
    text_x: 20,
    text_y: 800,
    minimum_word: 5,
    # Cloud-Vision OCR
    type_of_ocr: OcrFile::OcrEngines::CloudVision::DOCUMENT_TEXT_DETECTION,
    # requires image_annotator to be passed through
    ocr_engine: 'tesseract', # 'cloud-vision'
    # Image Pre-Processing
    image_pre_preprocess: true,
    effects: ['bw', 'norm'],
    threshold: 0.25,
    optimise_pdf: true,
    extract_pdf_images: true, # if false will screenshot each PDF page
    temp_filename_prefix: 'image',
    verbose: true,
  }

  doc = OcrFile::Document.new(
    original_file_path: '/path-to-original-file/', # supports PDFs and images
    save_file_path: '/folder-to-save-to/',
    config: config # Not needed as defaults are used when not provided
  )

  doc.to_s # Returns text, removes temp files and wont save
  doc.to_pdf # Saves a PDF (either searchable over the images or dumped text)
  doc.to_text # Saves a text file with OCR text

  # How to generate PDFs of images or text files:
  original_file_path = 'file.txt' OR 'file.png'

  doc = OcrFile::Document.new(
    original_file_path: original_file_path, # supports PDFs and images
    save_file_path: '/folder-to-save-to/',
    config: config # Not needed as defaults are used when not provided
  )

  doc.to_pdf

  # How to merge files into a single PDF:
  filepaths = []
  documents = file_paths.map { |path| OcrFile::ImageEngines::PdfEngine.open_pdf(path, password: '') }
  merged_document = OcrFile::ImageEngines::PdfEngine.merge(documents)
  OcrFile::ImageEngines::PdfEngine.save_pdf(merged_document, save_file_path, optimise: true)
```

### Notes / Tips
Set `extract_pdf_images` to `false` for higher quality OCR. However this will consume more temporary space per PDF page and also be considerably slower.

Image pre-processing is not yet implemented.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### TODOs
- input validation
- CLI
- image processing
- password
- Base64 encoding
- requirements checking (installed dependencies etc ...)
- Tests

### Tests
To run tests execute:

    $ rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trex22/ocr-file. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OCR-File: project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/trex22/ocr-file/blob/master/CODE_OF_CONDUCT.md).
