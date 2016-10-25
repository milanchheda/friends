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

  describe "#list_activities" do
    subject do
      introvert.list_activities(
        limit: limit,
        with: with,
        location_name: location_name,
        tagged: tagged
      )
    end
    let(:limit) { nil }
    let(:with) { nil }
    let(:location_name) { nil }
    let(:tagged) { nil }

    describe "when the limit is lower than the number of activities" do
      let(:limit) { 1 }

      it "lists that number of activities" do
        stub_activities(activities) do
          subject.size.must_equal limit
        end
      end
    end

    describe "when the limit is equal to the number of activities" do
      let(:limit) { activities.size }

      it "lists all activities" do
        stub_activities(activities) do
          subject.size.must_equal activities.size
        end
      end
    end

    describe "when the limit is greater than the number of activities" do
      let(:limit) { activities.size + 5 }

      it "lists all activities" do
        stub_activities(activities) do
          subject.size.must_equal activities.size
        end
      end
    end

    describe "when the limit is nil" do
      let(:limit) { nil }

      it "lists all activities" do
        stub_activities(activities) do
          subject.size.must_equal activities.size
        end
      end
    end

    describe "when not filtering by a friend" do
      let(:with) { nil }

      it "lists the activities" do
        stub_activities(activities) do
          subject.must_equal activities.map(&:to_s)
        end
      end
    end

    describe "when filtering by part of a friend's name" do
      let(:with) { "george" }

      describe "when there is more than one friend match" do
        let(:friend_names) { ["George Washington Carver", "George Harrison"] }

        it "raises an error" do
          stub_friends(friends) do
            stub_activities(activities) do
              proc { subject }.must_raise Friends::FriendsError
            end
          end
        end
      end

      describe "when there are no friend matches" do
        let(:friend_names) { ["Joe"] }

        it "raises an error" do
          stub_friends(friends) do
            stub_activities(activities) do
              proc { subject }.must_raise Friends::FriendsError
            end
          end
        end
      end

      describe "when there is exactly one friend match" do
        it "filters the activities by that friend" do
          stub_friends(friends) do
            stub_activities(activities) do
              # Only one activity has that friend.
              subject.must_equal activities[0..0].map(&:to_s)
            end
          end
        end
      end
    end

    describe "when not filtering by a location" do
      let(:location_name) { nil }

      it "lists the activities" do
        stub_activities(activities) do
          subject.must_equal activities.map(&:to_s)
        end
      end
    end

    describe "when filtering by part of a location name" do
      let(:location_name) { "City" }

      describe "when there is more than one location match" do
        let(:locations) do
          [
            Friends::Location.new(name: "New York City"),
            Friends::Location.new(name: "Kansas City")
          ]
        end

        it "raises an error" do
          stub_friends(friends) do
            stub_locations(locations) do
              stub_activities(activities) do
                proc { subject }.must_raise Friends::FriendsError
              end
            end
          end
        end
      end

      describe "when there are no location matches" do
        let(:locations) { [Friends::Location.new(name: "Atantis")] }

        it "raises an error" do
          stub_friends(friends) do
            stub_locations(locations) do
              stub_activities(activities) do
                proc { subject }.must_raise Friends::FriendsError
              end
            end
          end
        end
      end

      describe "when there is exactly one location match" do
        let(:location_name) { "Atlantis" }
        let(:activities) do
          [
            Friends::Activity.new(str: "Swimming near _Atlantis_."),
            Friends::Activity.new(str: "Swimming somewhere else.")
          ]
        end

        it "filters the activities by that location" do
          stub_friends(friends) do
            stub_locations(locations) do
              stub_activities(activities) do
                # Only one activity has that friend.
                subject.must_equal activities[0..0].map(&:to_s)
              end
            end
          end
        end
      end
    end

    describe "when not filtering by a tag" do
      let(:tagged) { nil }

      it "lists the activities" do
        stub_activities(activities) do
          subject.must_equal activities.map(&:to_s)
        end
      end
    end

    describe "when filtering by a tag" do
      let(:activities) do
        [
          Friends::Activity.new(str: "Tennis after work. @exercise @tennis"),
          Friends::Activity.new(str: "Wimbledon! @tennis"),
          Friends::Activity.new(str: "Drinks after work. @beer")
        ]
      end

      describe "when the tag ('@tag') is not used at all" do
        let(:tagged) { "@garbage" }
        it "returns no results" do
          stub_activities(activities) do
            subject.must_equal []
          end
        end
      end

      describe "when the tag ('@tag') is used once" do
        let(:tagged) { "@beer" }
        it "returns the activity with that tag" do
          stub_activities(activities) do
            subject.must_equal [activities.last.to_s]
          end
        end
      end

      describe "when the tag ('@tag') is used multiple times" do
        let(:tagged) { "@tennis" }
        it "returns the activities with that tag" do
          stub_activities(activities) do
            subject.must_equal activities[0..1].map(&:to_s)
          end
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

  describe "#rename_friend" do
    let(:new_name) { "David Bowie" }
    subject do
      introvert.rename_friend(old_name: friend_names.last, new_name: new_name)
    end

    it "replaces old name within activities to the new name" do
      stub_friends(friends) do
        stub_activities(activities) do
          subject
          introvert.activities.first.description.must_include new_name
          introvert.activities.last.description.must_include new_name
        end
      end
    end
  end

  describe "#rename_location" do
    subject do
      introvert.rename_location(old_name: old_name, new_name: new_name)
    end
    let(:old_name) { "Paris" }
    let(:new_name) { "Paris, France" }

    let(:activities) do
      [
        Friends::Activity.new(str: "Dining in _Paris_."),
        Friends::Activity.new(str: "Falling in love in _Paris_."),
        Friends::Activity.new(str: "Swimming near _Atlantis_.")
      ]
    end
    let(:locations) do
      [
        Friends::Location.new(name: "Paris"),
        Friends::Location.new(name: "Atlantis")
      ]
    end

    it "replaces old name within activities to the new name" do
      stub_locations(locations) do
        stub_activities(activities) do
          subject
          introvert.activities.map do |activity|
            activity.description.include? new_name
          end.must_equal [true, true, false]
        end
      end
    end

    describe "when there are friends at the location" do
      let(:friends) do
        [
          Friends::Friend.new(name: "Jacques Cousteau", location_name: "Paris"),
          Friends::Friend.new(name: "Marie Antoinette", location_name: "Paris"),
          Friends::Friend.new(name: "Julius Caesar", location_name: "Rome")
        ]
      end

      it "updates their locations" do
        stub_locations(locations) do
          stub_friends(friends) do
            subject
            introvert.friends.map do |friend|
              friend.location_name == new_name
            end.must_equal [true, true, false]
          end
        end
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

  describe "#remove_nickname" do
    subject do
      introvert.remove_nickname(name: "Jeff", nickname: "The Dude")
    end

    it "returns the modified friend" do
      friend = Friends::Friend.new(name: "Jeff", nickname_str: "The Dude")
      stub_friends([friend]) do
        subject.must_equal friend
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

  describe "#remove_tag" do
    subject do
      introvert.remove_tag(name: "Jeff", tag: "@school")
    end

    it "returns the modified friend" do
      friend = Friends::Friend.new(name: "Jeff", tags_str: "@school")
      stub_friends([friend]) do
        subject.must_equal friend
      end
    end
  end
end
