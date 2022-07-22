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
    image_annotator: nil, # Needed for Cloud-Vision
    type_of_ocr: OcrFile::OcrEngines::CloudVision::DOCUMENT_TEXT_DETECTION,
    ocr_engine: 'tesseract', # 'cloud-vision'
    # Image Pre-Processing
    image_preprocess: true,
    effects: ['despeckle', 'deskew', 'enhance', 'sharpen', 'remove_shadow', 'bw'], # Applies effects as listed. 'norm' is also available
    automatic_reprocess: true, # Will possibly do double + the operations but can produce better results automatically
    # PDF to Image Processing
    optimise_pdf: true,
    extract_pdf_images: true, # if false will screenshot each PDF page
    temp_filename_prefix: 'image',
    spelling_correction: true, # Will attempt to fix text at the end (not used for searchable pdf output)
    keep_files: false,
    # Console Output
    verbose: true,
    timing: true
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
  # The files can be images or other PDFs
  filepaths = []
  documents = file_paths.map { |path| OcrFile::ImageEngines::PdfEngine.open_pdf(path, password: '') }
  merged_document = OcrFile::ImageEngines::PdfEngine.merge(documents)
  OcrFile::ImageEngines::PdfEngine.save_pdf(merged_document, save_file_path, optimise: true)
```

### Notes / Tips
Set `extract_pdf_images` to `false` for higher quality OCR. However this will consume more temporary space per PDF page and also be considerably slower.

Image pre-processing only thresholds (bw), normalises the colour space, removes speckles, removes shadows and tries to straighten the image. Will make the end result Black and White but have far more accurate OCR (PDFs). The order of operations is important, but steps can be removed when necessary. Expanding the colour dynamic range with `'norm'` can also be done but isn't recommended.

`automatic_reprocess` is much slower as it has to re-do operations per image (in some cases) but will select the best result for each page.

### Simple CLI
Once installed you can use `ocr-file` as a CLI. Its currently a reduced set of options. These are subject to change in future versions

```
# Basic Usage with console output
ocr-file input_file_path output_folder_path

# Output to PDF
ocr-file input_file_path output_folder_path pdf

# Output to TXT
ocr-file input_file_path output_folder_path txt
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### TODOs
- input validation
- Better CLI
- password
- Base64 encoding
- requirements checking (installed dependencies etc ...)
- Tests
- Configurable temp folder cleanup
- Improve console output
- Fix spaces in file names
- Better verbosity
- Docker
- pdftk / pdf merge for text and bookmarks etc ...
    - https://github.com/tesseract-ocr/tesseract/issues/660
    - tesseract -c naked_pdf=true
-

### Tests
To run tests execute:

    $ rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trex22/ocr-file. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OCR-File: project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/trex22/ocr-file/blob/master/CODE_OF_CONDUCT.md).
