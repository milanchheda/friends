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

  describe "#add_friend" do
    let(:new_friend_name) { "Jacob Evelyn" }
    subject { introvert.add_friend(name: new_friend_name) }

    describe "when there is no existing friend with that name" do
      it "adds the given friend" do
        stub_friends(friends) do
          subject
          introvert.
            instance_variable_get(:@friends).
            map(&:name).
            must_include new_friend_name
        end
      end

      it "returns the friend added" do
        stub_friends(friends) do
          subject.name.must_equal new_friend_name
        end
      end
    end

    describe "when there is an existing friend with that name" do
      let(:new_friend_name) { friend_names.first }

      it "raises an error" do
        stub_friends(friends) do
          proc { subject }.must_raise Friends::FriendsError
        end
      end
    end
  end

  describe "#add_location" do
    let(:new_location_name) { "Peru" }
    subject { introvert.add_location(name: new_location_name) }

    describe "when there is no existing location with that name" do
      it "adds the given location" do
        stub_locations(locations) do
          subject
          introvert.list_locations.must_include new_location_name
        end
      end

      it "returns the location added" do
        stub_locations(locations) do
          subject.name.must_equal new_location_name
        end
      end
    end

    describe "when there is an existing location with that name" do
      let(:new_location_name) { locations.first.name }

      it "raises an error" do
        stub_locations(locations) do
          proc { subject }.must_raise Friends::FriendsError
        end
      end
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

  describe "#add_nickname" do
    subject do
      introvert.add_nickname(name: friend_names.first, nickname: "The Dude")
    end

    it "returns the modified friend" do
      stub_friends(friends) do
        subject.must_equal friends.first
      end
    end
  end

  describe "#add_tag" do
    subject do
      introvert.add_tag(name: friend_names.first, tag: "@school")
    end

    it "returns the modified friend" do
      stub_friends(friends) do
        subject.must_equal friends.first
      end
    end

    describe "when more than one friend name matches" do
      let(:friend_names) { ["George Washington Carver", "George Washington"] }

      describe "when one friend name matches exactly" do
        it "returns the modified friend" do
          stub_friends(friends) do
            subject.must_equal friends.first
          end
        end
      end

      describe "when no friend name matches exactly" do
        it "raises an error" do
          proc do
            stub_friends(friends) do
              introvert.add_tag(name: "George", tag: "@school")
            end
          end.must_raise Friends::FriendsError
        end
      end
    end
  end
end
