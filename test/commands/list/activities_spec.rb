# frozen_string_literal: true

require "./test/helper"

clean_describe "list activities" do
  subject { run_cmd("list activities") }

  describe "when file does not exist" do
    it "does not list anything" do
      stdout_only ""
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "does not list anything" do
      stdout_only ""
    end
  end

  describe "when file has content" do
    # Use scrambled content to differentiate between output that is sorted and output that
    # only reads from the (usually-sorted) file.
    let(:content) { SCRAMBLED_CONTENT }

    it "lists activities in file order" do
      stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2015-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute. @food
2014-11-15: Talked to George Washington Carver on the phone for an hour.
2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying
      OUTPUT
    end

    describe "--limit" do
      subject { run_cmd("list activities --limit #{limit}") }

      describe "when limit is less than 1" do
        let(:limit) { 0 }
        it "prints an error message" do
          stderr_only "Error: Limit must be positive"
        end
      end

      describe "when limit is 1 or greater" do
        let(:limit) { 2 }
        it "limits output to the number specified" do
          stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2015-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute. @food
          OUTPUT
        end
      end
    end

    describe "--in" do
      subject { run_cmd("list activities --in #{location_name}") }

      describe "when location does not exist" do
        let(:location_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No location found for "Garbage"'
        end
      end

      describe "when location exists" do
        let(:location_name) { "paris" }
        it "matches location case-insensitively" do
          stdout_only "2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying"
        end
      end
    end

    describe "--with" do
      subject { run_cmd("list activities --with #{friend_name}") }

      describe "when friend does not exist" do
        let(:friend_name) { "Garbage" }
        it "prints an error message" do
          stderr_only 'Error: No friend found for "Garbage"'
        end
      end

      describe "when friend name matches more than one friend" do
        let(:friend_name) { "george" }
        it "prints an error message" do
          run_cmd("add friend George Harrison")
          stderr_only 'Error: More than one friend found for "george": '\
                      "George Harrison, George Washington Carver"
        end
      end

      describe "when friend name matches one friend" do
        let(:friend_name) { "marie" }
        it "matches friend case-insensitively" do
          stdout_only "2014-12-31: Celebrated the new year in Paris with Marie Curie. @partying"
        end
      end
    end

    describe "--tagged" do
      subject { run_cmd("list activities --tagged food") }

      it "matches tag case-sensitively" do
        stdout_only <<-OUTPUT
2015-01-04: Got lunch with Grace Hopper and George Washington Carver. @food
2015-11-01: Grace Hopper and I went to Marie's Diner. George had to cancel at the last minute. @food
        OUTPUT
      end
    end
  end
end
