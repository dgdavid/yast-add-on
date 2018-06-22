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

    def initialize_add_on_misc(include_target)

      textdomain "add-on"

      Yast.import "AddOnProduct"
      Yast.import "Popup"
    end

    # Returns whether the machine has insufficient memory for using
    # Add-Ons (in inst-sys).
    #
    # @return [Boolean] has insufficient memory
    def HasInsufficientMemory
      # 384 MB - 5% (bugzilla #239630)
      enough_memory = 373000

      meminfo = Convert.to_map(SCR.Read(path(".proc.meminfo")))

      memtotal = Ops.get_integer(meminfo, "memtotal", 0)
      swaptotal = Ops.get_integer(meminfo, "swaptotal", 0)
      totalmem = Ops.add(memtotal, swaptotal)

      log.info("Memory: #{memtotal}, Swap: #{swaptotal}, Total: #{totalmem}")

      # something is wrong
      if totalmem == nil
        # using only RAM if possible
        if Ops.get(meminfo, "memtotal") != nil
          totalmem = Ops.get_integer(meminfo, "memtotal", 0)
          # can't do anything, just assume we enough
        else
          totalmem = enough_memory
        end
      end

      # do we have less memory than needed?
      Ops.less_than(totalmem, enough_memory)
    end

    def ContinueIfInsufficientMemory
      Builtins.y2warning("Not enough memory!")

      # If already reported, just continue
      if !AddOnProduct.low_memory_already_reported
        # report it only once
        AddOnProduct.low_memory_already_reported = true

        if Popup.YesNoHeadline(
            # TRANSLATORS: pop-up headline
            _("Warning: Not enough memory!"),
            # TRANSLATORS: pop-up question
            _(
              "Your system does not seem to have enough memory to use add-on products\n" +
                "during installation. You can enable add-on products later when the\n" +
                "system is running.\n" +
                "\n" +
                "Do you want to skip using add-on products?"
            )
          )
          log.info("User decided to skip Add-Ons")
          AddOnProduct.skip_add_ons = true

          return false
        else
          Builtins.y2warning(
            "User decided to continue with not enough memory...!"
          )

          return true
        end
      end

      true
    end
  end
end
