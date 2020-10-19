# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2012 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File		: firstboot_ntp.ycp
# Author	: Jiri Suchomel <jsuchome@suse.cz>
# Purpose	: NTP configuration sequence to be run during firstboot
#

require "y2ntp_client/dialog/main"

module Yast
  class FirstbootNtpClient < Client
    def main
      Yast.import "UI"
      Yast.import "NtpClient"
      Yast.import "Progress"
      Yast.import "Wizard"


      @progress_orig = Progress.set(false)

      Wizard.SetDesktopIcon("org.opensuse.yast.NTPClient")

      NtpClient.Read

      @ret = Y2NtpClient::Dialog::Main.new.run
      NtpClient.Write if @ret == :next

      Progress.set(@progress_orig)

      deep_copy(@ret)
    end
  end
end

Yast::FirstbootNtpClient.new.main
