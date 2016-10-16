# frozen_string_literal: true

require "./test/helper"

clean_describe "suggest" do
  subject { run_cmd("suggest") }

  describe "when file does not exist" do
    it "prints a no-data message" do
      stdout_only <<-FILE
Distant friend: None found
Moderate friend: None found
Close friend: None found
      FILE
    end
  end

  describe "when the file is empty" do
    let(:content) { "" }

    it "prints a no-data message" do
      stdout_only <<-FILE
Distant friend: None found
Moderate friend: None found
Close friend: None found
      FILE
    end
  end

  describe "when file has content" do
    let(:content) { CONTENT }

    it "prints suggested friends" do
      stdout_only <<-FILE
Distant friend: Marie Curie
Moderate friend: George Washington Carver
Close friend: Grace Hopper
      FILE
    end

    describe "--in" do
      subject { run_cmd("suggest --in Paris") }

      it "prints suggested friends" do
        stdout_only <<-FILE
Distant friend: None found
Moderate friend: None found
Close friend: Grace Hopper
        FILE
      end
    end
  end
end
