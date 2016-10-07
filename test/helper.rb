# frozen_string_literal: true

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "minitest/autorun"
require "minitest/pride"
require "open3"

require "friends"

CONTENT = <<-FILE
### Activities:
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute. @food
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.

### Friends:
- George Washington Carver
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science
- Marie Curie [Atlantis] @science

### Locations:
- Atlantis
- Marie's Diner
- Paris
FILE

# This is CONTENT but with activities, friends, and locations unsorted.
SCRAMBLED_CONTENT = <<-FILE
### Activities:
- 2015-01-04: Got lunch with **Grace Hopper** and **George Washington Carver**. @food
- 2015-11-01: **Grace Hopper** and I went to _Marie's Diner_. George had to cancel at the last minute. @food
- 2014-11-15: Talked to **George Washington Carver** on the phone for an hour.
- 2014-12-31: Celebrated the new year in _Paris_ with **Marie Curie**. @partying

### Friends:
- George Washington Carver
- Marie Curie [Atlantis] @science
- Grace Hopper (a.k.a. The Admiral a.k.a. Amazing Grace) [Paris] @navy @science

### Locations:
- Paris
- Atlantis
- Marie's Diner
FILE

# Define these methods so they can be referenced in the methods below. They'll be overridden in
# test files.
def filename; end

def subject; end

def run_cmd(command)
  stdout, stderr, status = Open3.capture3(
    "bundle exec bin/friends --filename #{filename} #{command}"
  )
  {
    stdout: stdout,
    stderr: stderr,
    status: status
  }
end

# @param str [String] a string
# @return [String] the input string with a newline appended to it if one was not already
#   present, *unless* the string is empty
def ensure_trailing_newline_unless_empty(str)
  return "" if str.empty?

  str.to_s[-1] == "\n" ? str.to_s : "#{str}\n"
end

def stdout_only(expected)
  subject[:stdout].must_equal ensure_trailing_newline_unless_empty(expected)
  subject[:stderr].must_equal ""
  subject[:status].must_equal 0
end

def file_equals(expected)
  subject
  File.read(filename).must_equal expected
end

def clean_describe(desc, *additional_desc, &block)
  describe desc, *additional_desc do
    let(:filename) { "test/tmp/friends.md" }
    let(:content) { nil }

    before { File.write(filename, content) unless content.nil? }
    after { File.delete(filename) if File.exist?(filename) }

    class_eval(&block)
  end
end
