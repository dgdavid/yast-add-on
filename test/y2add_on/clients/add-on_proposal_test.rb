require_relative "../../test_helper"
require "add-on/clients/add-on_proposal"

Yast.import "Packages"
Yast.import "Linuxrc"
Yast.import "Installation"
Yast.import "AddOnProduct"

describe Yast::AddOnProposalClient do
  describe "#main" do
    before do
      allow(Yast::WFM).to receive(:Args).with(no_args).and_return([func])
      allow(Yast::WFM).to receive(:Args).with(0).and_return(func)
      allow(Yast::WFM).to receive(:Args).with(1).and_return({})
    end

    context "MakeProposal" do
      let(:func) { "MakeProposal" }

      it "redraw wizard steps" do
        expect(Yast::WorkflowManager).to receive(:RedrawWizardSteps)

        subject.main
      end

      context "when there is add-on product selected" do

      end
    end

    context "AskUser" do
      let(:func) { "AskUser" }

      it "runs Add-on main dialog" do
        expect(subject).to receive(:RunAddOnMainDialog)

        subject.main
      end

      it "returns a hash with result" do
        allow(subject).to receive(:RunAddOnMainDialog).and_return(:next)

        expect(subject.main).to eq("workflow_sequence" => :next, "mode_changed" => false)
      end
    end

    context "Description" do
      let(:func) { "Description" }

      it "returns a hash" do
        expect(subject.main).to eq(
          "rich_text_title" => "Add-On Products",
          "menu_title"      => "Add-&on Products",
          "id"              => "add_on"
        )
      end
    end
  end
end
