# frozen_string_literal: true

require "./test/helper"

clean_describe "graph" do
  subject { run_cmd("graph") }

  describe "when file does not exist" do
    it "prints no output" do
      stdout_only ""
    end
  end

  describe "when file is empty" do
    let(:content) { "" }

    it "prints no output" do
      stdout_only ""
    end
  end

  describe "when file has content" do
    let(:content) { CONTENT } # Content must be sorted to avoid errors.

    it "graphs all activities" do
      stdout_only <<-OUTPUT
Nov 2014 |█
Dec 2014 |█
Jan 2015 |█
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |█
      OUTPUT
    end

    describe "--in" do
      subject { run_cmd("graph --in paris") }

      it "matches location case-insensitively" do
        stdout_only <<-OUTPUT
Nov 2014 |
Dec 2014 |█
Jan 2015 |
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |
        OUTPUT
      end
    end

    describe "--tagged" do
      subject { run_cmd("graph --tagged food") }

      it "matches tag case-sensitively" do
        stdout_only <<-OUTPUT
Nov 2014 |
Dec 2014 |
Jan 2015 |█
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |█
        OUTPUT
      end
    end

    describe "--with" do
      subject { run_cmd("graph --with george") }

      it "matches friend case-insensitively" do
        stdout_only <<-OUTPUT
Nov 2014 |█
Dec 2014 |
Jan 2015 |█
Feb 2015 |
Mar 2015 |
Apr 2015 |
May 2015 |
Jun 2015 |
Jul 2015 |
Aug 2015 |
Sep 2015 |
Oct 2015 |
Nov 2015 |
        OUTPUT
      end
    end
  end
end
