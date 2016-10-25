# frozen_string_literal: true

require "./test/helper"

clean_describe "list favorite friends" do
  subject { run_cmd("list favorite friends") }

  describe "when file does not exist" do
    it "prints a no-data message" do
      stdout_only "Your favorite friends:"
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "prints a no-data message" do
      stdout_only "Your favorite friends:"
    end
  end

  describe "when file has content" do
    let(:content) { CONTENT }

    it "lists friends in order of decreasing activity" do
      stdout_only <<-OUTPUT
Your favorite friends:
1. George Washington Carver (2 activities)
2. Grace Hopper             (2)
3. Marie Curie              (1)
      OUTPUT
    end

    describe "--limit" do
      subject { run_cmd("list favorite friends --limit #{limit}") }

      describe "when limit is greater than 1" do
        let(:limit) { 2 }

        it "limits output to the number specified" do
          stdout_only <<-OUTPUT
Your favorite friends:
1. George Washington Carver (2 activities)
2. Grace Hopper             (2)
          OUTPUT
        end
      end

      describe "when limit is 1" do
        let(:limit) { 1 }

        it "outputs as a best friend" do
          stdout_only "Your best friend is George Washington Carver (2 activities)"
        end
      end
    end
  end
end
