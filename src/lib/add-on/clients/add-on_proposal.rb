# encoding: utf-8

module Yast
  class AddOnProposalClient < Client
    def main
      textdomain "add-on"

      Yast.import "UI"
      Yast.import "Pkg"
      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "AddOnProduct"
      Yast.import "WorkflowManager"

      Yast.include self, "add-on/add-on-workflow.rb"

      func, param = Yast::WFM.Args
      log.info "Called #{self.class}.run with #{func} and params #{param}"

      case func
      when "MakeProposal"
        make_proposal
      when "AskUser"
        ask_user
      when "Description"
        description
      else
        raise ArgumentError, "Invalid action for Add-on proposal client '#{func.inspect}'"
      end
    end

  private

    def make_proposal
      @items =
        if AddOnProducts.add_on_products.empty?
          [_("No add-on product selected for installation")]
        else
          AddOnProducts.add_on_products.map do |add_on|
            media = add_on.fetch("media", -1)
            general_data = Pkg.SourceGeneralData(media)
            product = add_on.fetch("product", "")
            product_dir = general_data.fetch("product_dir") { _("Unknown") }
            product_dir = "/" if product_dir.empty?
            url = general_data.fetch("url") { _("Unknown") }

            "#{product} (Media #{url}, directory #{product_dir})"
          end
        end

      WorkflowManager.RedrawWizardSteps

      { "raw_proposal" => @items }
    end

    def ask_user
      Wizard.CreateDialog

      sequence = RunAddOnMainDialog(
        false,
        true,
        true,
        Label.BackButton,
        Label.OKButton,
        Label.CancelButton,
        false
      )

      Wizard.CloseDialog

      { "workflow_sequence" => sequence, "mode_changed" => false }
    end

    def description
      {
        "id"              => "add_on",
        "rich_text_title" => _("Add-On Products"), # heading
        "menu_title"      => _("Add-&on Products") # menu entry
      }
    end
  end
end
