#!/usr/bin/env rspec

require_relative "../../test_helper.rb"
require_relative "../../../src/include/add-on/misc.rb"

class TestSubject
  include Yast::AddOnMiscInclude

  def initialize
    Yast.import "AddOnProduct"
  end
end

describe Yast::AddOnMiscInclude do
  subject { TestSubject.new }

  before do
    allow(subject).to receive(:_)
  end

  describe "#insufficient_memory?" do
    let(:memory) { 2058 }
    let(:swap) { 1024 }
    let(:meminfo) do
      {
        "memtotal"  => memory,
        "swaptotal" => swap
      }
    end

    before do
      allow(subject).to receive(:path).and_return(".proc.meminfo")
      allow(Yast::SCR).to receive(:Read).and_return(meminfo)
    end

    context "available memory is greater than needed" do
      let(:memory) { 384_000 }

      it "returns false" do
        expect(subject.insufficient_memory?).to be_falsey
      end
    end

    context "available memory is equial to needed" do
      let(:memory) { 300_000 }
      let(:swap) { 73_000 }

      it "returns false" do
        expect(subject.insufficient_memory?).to be_falsey
      end
    end

    context "available memory is less than needed" do
      let(:memory) { 2048 }

      it "returns true" do
        expect(subject.insufficient_memory?).to be_truthy
      end
    end

    context "something is wrong getting totalmem" do
      let(:memory) { nil }

      xit "assume enough memory and returns false" do
        expect(subject.insufficient_memory?).to be_falsey
      end
    end
  end

  describe "#continue_without_enough_memory?" do
    context "when low memory already was reported" do
      before do
        allow(Yast::AddOnProduct).to receive(:low_memory_already_reported).and_return(true)
      end

      it "returns true" do
        expect(subject.continue_without_enough_memory?).to be_truthy
      end
    end

    context "when low memory has not been reported yet" do
      before do
        allow(Yast::AddOnProduct).to receive(:low_memory_already_reported).and_return(false)
      end

      it "asks user if Add-Ons should be skipped" do
        expect(Yast::Popup).to receive(:YesNoHeadline)

        subject.continue_without_enough_memory?
      end

      xit "sets low memory as reported" do
        # pending "possible bug setting low_memory_already_reported?"

        expect { subject.continue_without_enough_memory? }
          .to change { Yast::AddOnProduct.low_memory_already_reported }
          .from(false)
          .to(true)
      end

      it "returns true if user decides continue" do
        allow(Yast::Popup).to receive(:YesNoHeadline).and_return(false)

        expect(subject.continue_without_enough_memory?).to be_truthy
      end

      it "returns false if user decides to skip Add-Ons" do
        allow(Yast::Popup).to receive(:YesNoHeadline).and_return(true)

        expect(subject.continue_without_enough_memory?).to be_falsey
      end
    end
  end
end
