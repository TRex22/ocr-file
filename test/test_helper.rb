$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ocr-file"

require "minitest/autorun"
require 'minitest/focus'
require 'minitest/reporters'
require 'mocha/minitest'
require 'webmock/minitest'
require 'timecop'

Minitest::Reporters.use!(
  [Minitest::Reporters::DefaultReporter.new(color: true)],
  ENV,
  Minitest.backtrace_filter
)

Timecop.safe_mode = true
