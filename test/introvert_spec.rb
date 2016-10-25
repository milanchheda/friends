# frozen_string_literal: true

require "./test/helper"

describe Friends::Introvert do
  # Add readers to make internal state easier to test.
  module Friends
    class Introvert
      attr_reader :filename, :activities, :friends
    end
  end

  # Add helpers to set internal states for friends/locations/activities.
  def stub_friends(val)
    old_val = introvert.instance_variable_get(:@friends)
    introvert.instance_variable_set(:@friends, val)
    introvert.send(:set_n_activities!, :friend)
    yield
    introvert.instance_variable_set(:@friends, old_val)
  end

  def stub_activities(val)
    old_val = introvert.instance_variable_get(:@activities)
    introvert.instance_variable_set(:@activities, val)
    introvert.send(:set_n_activities!, :friend)
    introvert.send(:set_n_activities!, :location)
    yield
    introvert.instance_variable_set(:@activities, old_val)
  end

  def stub_locations(val)
    old_val = introvert.instance_variable_get(:@locations)
    introvert.instance_variable_set(:@locations, val)
    introvert.send(:set_n_activities!, :location)
    yield
    introvert.instance_variable_set(:@locations, old_val)
  end

  let(:filename) { "test/tmp/friends.md" }
  let(:args) { { filename: filename } }
  let(:introvert) { Friends::Introvert.new(args) }
  let(:friend_names) { ["George Washington Carver", "Betsy Ross"] }
  let(:friends) do
    friend_names.map do |name|
      Friends::Friend.new(name: name, tags_str: "@test")
    end
  end
  let(:activities) do
    [
      Friends::Activity.new(
        str: "Lunch w/ **#{friend_names.first}** and **#{friend_names.last}**."
      ),
      Friends::Activity.new(
        str: "Yesterday: Called **#{friend_names.last}**."
      )
    ]
  end
  let(:locations) do
    [
      Friends::Location.new(name: "The Eiffel Tower"),
      Friends::Location.new(name: "Atlantis")
    ]
  end

  describe "#new" do
    it "accepts all arguments" do
      introvert # Build a new introvert.

      # Check passed values.
      introvert.filename.must_equal filename
    end

    it "has sane defaults" do
      args.clear # Pass no arguments to the initializer.
      introvert # Build a new introvert.

      # Check default values.
      introvert.filename.must_equal Friends::Introvert::DEFAULT_FILENAME
    end
  end

  describe "#add_activity" do
    let(:activity_serialization) { "2014-01-01: Snorkeling with Betsy." }
    let(:activity_description) { "Snorkeling with **Betsy Ross**." }
    subject { introvert.add_activity(serialization: activity_serialization) }

    it "adds the given activity" do
      stub_friends(friends) do
        subject
        introvert.activities.first.description.must_equal activity_description
      end
    end

    it "adds the activity after others on the same day" do
      stub_friends(friends) do
        introvert.add_activity(serialization: "2014-01-01: Ate breakfast.")
        subject
        introvert.activities.first.description.must_equal activity_description
      end
    end

    it "returns the activity added" do
      stub_friends(friends) do
        subject.description.must_equal activity_description
      end
    end
  end
end
