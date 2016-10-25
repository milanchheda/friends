# frozen_string_literal: true

require "./test/helper"

clean_describe "rename friend" do
  subject { run_cmd("rename friend #{old_name} #{new_name}") }

  let(:content) { CONTENT }
  let(:new_name) { "'George Washington'" }

  describe "when friend name has no matches" do
    let(:old_name) { "Garbage" }
    it "prints an error message" do
      stderr_only 'Error: No friend found for "Garbage"'
    end
  end

  describe "when friend name has more than one match" do
    let(:old_name) { "George" }
    before { run_cmd("add friend George Harrison") }

    it "prints an error message" do
      stderr_only 'Error: More than one friend found for "George": '\
                  "George Harrison, George Washington Carver"
    end
  end

  describe "when friend name has one match" do
    let(:old_name) { "George" }

    it "renames friend" do
      line_changed "- George Washington Carver", "- George Washington"
    end

    it "prints an output message" do
      stdout_only 'Name changed: "George Washington"'
    end
  end
end
