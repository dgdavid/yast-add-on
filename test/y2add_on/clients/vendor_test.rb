require_relative "../../test_helper"
require "add-on/clients/vendor.rb"

Yast.import "Packages"
Yast.import "Linuxrc"
Yast.import "Installation"
Yast.import "AddOnProduct"

describe Yast::VendorClient do
  describe "#main" do
    let (:driver_not_found_message) { "Could not find driver data on the CD-ROM.\nAborting now." }

    context "when dirlist does not contains linux" do
      it "returns error looking for driver" do
        allow(Yast::SCR).to receive(:Execute).and_return(true)
        allow(Yast::Convert).to receive(:to_list).and_return(["bsd"])
        expect(Yast::Popup).to receive(:Message).with(driver_not_found_message)

        subject.main
      end
    end

    context "when dirlist does not contains suse nor unitedlinux" do
      it "returns error looking for driver" do
        allow(Yast::SCR).to receive(:Execute).and_return(true)
        allow(Yast::Convert).to receive(:to_list).and_return(["linux", "ubuntu"])
        expect(Yast::Popup).to receive(:Message).with(driver_not_found_message)

        subject.main
      end
    end
  end
end
