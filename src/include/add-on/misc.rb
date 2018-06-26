# encoding: utf-8

# File:
#      include/add-on/misc.ycp
#
# Module:
#      System installation
#
# Summary:
#      Add-on product miscellaneous
#
# Authors:
#      Lukas Ocilka <locilka@suse.cz>
#
#
module Yast
  module AddOnMiscInclude
    include Yast::Logger

    ENOUGH_MEMORY = 373_000 # 384B - 5%, bugzilla #239630

    def initialize_add_on_misc(*)
      textdomain "add-on"

      Yast.import "AddOnProduct"
      Yast.import "Popup"
    end

    # Validates whether the machine has enough memory for using Add-Ons (in inst-sys).
    #
    # @return [Boolean] true if there is enough memory; false otherwise
    def enough_memory?
      available_memory >= ENOUGH_MEMORY
    end

    # Validates whether the machine has not enough memory for using Add-Ons (in inst-sys).
    #
    # @return [Boolean] true if available memory if not enough; false otherwise
    def insufficient_memory?
      !enough_memory?
    end

    # Validates if continue without enough memory
    #
    # @return [Boolean] true if should be continue; false otherwise
    def continue_without_enough_memory?
      log.warn("Not enough memory!")

      return true if AddOnProduct.low_memory_already_reported

      AddOnProduct.low_memory_already_reported = true

      if skip_addons?
        log.info("User decided to skip Add-Ons")

        return false
      end

      true
    end

  private

    # Shows popup asking user if add-on products should be skipped
    #
    # @return [Boolean] true if user wants to skip using add-on products; false if not
    def skip_addons?
      # TRANSLATORS: pop-up headline
      headline = _("Warning: Not enough memory!")
      # TRANSLATORS: pop-up question
      question = _([
        "Your system does not seem to have enough memory to use add-on products",
        "during installation. You can enable add-on products later when the",
        "system is running.",
        "\n",
        "Do you want to skip using add-on products?"
      ].join("\n"))

      Popup.YesNoHeadline(headline, question)
    end

    # Calculates total available memory (RAM + Swap)
    #
    # @see {mem_info}
    #
    # @return [Float] avaialble memory
    def available_memory
      memory = mem_info.fetch("memtotal", 0)
      swap = mem_info.fetch("swaptotal", 0)
      total = memory + swap

      log.info("Memory: #{memory}, Swap: #{swap}, Total: #{total}")

      total
    end

    def mem_info
      @mem_info ||= Convert.to_map(SCR.Read(path(".proc.meminfo")))
    end
  end
end
