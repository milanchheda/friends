# frozen_string_literal: true

require "./test/helper"

clean_describe "list favorite locations" do
  subject { run_cmd("list favorite locations") }

  describe "when file does not exist" do
    it "prints a no-data message" do
      stdout_only "Your favorite locations:"
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "prints a no-data message" do
      stdout_only "Your favorite locations:"
    end
  end

  describe "when file has content" do
    let(:content) { CONTENT }

    it "lists locations in order of decreasing activity" do
      stdout_only <<-OUTPUT
Your favorite locations:
1. Marie's Diner (1 activity)
2. Paris         (1)
3. Atlantis      (0)
      OUTPUT
    end

    describe "--limit" do
      subject { run_cmd("list favorite locations --limit #{limit}") }

      describe "when limit is less than 1" do
        let(:limit) { 0 }

        it "prints an error message" do
          stderr_only "Error: Favorites limit must be positive"
        end
      end

      describe "when limit is 1" do
        let(:limit) { 1 }

        it "outputs as a favorite location" do
          stdout_only "Your favorite location is Marie's Diner (1 activity)"
        end
      end

      describe "when limit is greater than 1" do
        let(:limit) { 2 }

        it "limits output to the number specified" do
          stdout_only <<-OUTPUT
Your favorite locations:
1. Marie's Diner (1 activity)
2. Paris         (1)
          OUTPUT
        end
      end
    end
  end
end
