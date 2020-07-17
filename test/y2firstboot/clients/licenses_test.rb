#!/usr/bin/env rspec
# Copyright (c) [2019] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require_relative "../../test_helper"
require "y2firstboot/clients/licenses"

describe Y2Firstboot::Clients::Licenses do
  subject(:client) { described_class.new }

  let(:directory) { "" }
  let(:firstboot_license_dir) { "" }
  let(:firstboot_novell_license_dir) { "" }
  let(:client_response) { :whatever }

  before do
    allow(Yast::Misc).to receive(:SysconfigRead)
      .with(Yast::Path.new(".sysconfig.firstboot.LICENSE_REFUSAL_ACTION"), anything)

    allow(Yast::Misc).to receive(:SysconfigRead)
      .with(Yast::Path.new(".sysconfig.firstboot.FIRSTBOOT_LICENSE_DIR"), anything)
      .and_return(firstboot_license_dir)

    allow(Yast::Misc).to receive(:SysconfigRead)
      .with(Yast::Path.new(".sysconfig.firstboot.FIRSTBOOT_NOVELL_LICENSE_DIR"), anything)
      .and_return(firstboot_novell_license_dir)

    allow(Yast::WFM).to receive(:CallFunction)
      .and_return(client_response)

    allow(Yast::GetInstArgs).to receive(:argmap)
      .and_return("directory" => directory)
  end

  describe "#run" do
    context "when 'directory' argument is given" do
      let(:directory) { "/path/to/somewhere" }

      it "includes it in the 'directories' argument sent to InstLicense client" do
        expect(Yast::WFM).to receive(:CallFunction)
          .with("inst_license", array_including(hash_including("directories" => [directory])))

        subject.run
      end
    end

    shared_examples "calls client giving the right directories" do |*defined_dir|
      it "includes it in the 'directories' argument sent to InstLicense client" do
        expect(Yast::WFM)
          .to receive(:CallFunction)
          .with(
            "inst_license",
            array_including(hash_including("directories" => defined_dir))
          )

        subject.run
      end

      context "but the 'directory' module argument is given too" do
        let(:directory) { "/path/to/somewhere" }

        it "includes only it in the 'directories' argument sent to InstLicense client" do
          expect(Yast::WFM)
            .to receive(:CallFunction)
            .with(
              "inst_license",
              array_including(hash_including("directories" => [directory]))
            )

          subject.run
        end
      end
    end

    context "when FIRSTBOOT_LICENSE_DIR is defined" do
      let(:firstboot_license_dir) { "/path/to/license" }

      include_examples "calls client giving the right directories", "/path/to/license"
    end

    context "when FIRSTBOOT_NOVELL_LICENSE_DIR is defined" do
      let(:firstboot_novell_license_dir) { "/path/to/novell/license" }

      include_examples "calls client giving the right directories", "/path/to/novell/license"
    end

    context "when both, FIRSTBOOT_LICENSE_DIR and FIRSTBOOT_NOVELL_LICENSE_DIR, are defined" do
      let(:firstboot_license_dir) { "/p/t/license" }
      let(:firstboot_novell_license_dir) { "/p/t/n/license" }

      include_examples "calls client giving the right directories", "/p/t/license", "/p/t/n/license"
    end
  end

  context "when InstLicense client finish" do
    context "and it returns :halt" do
      let(:client_response) { :halt }

      it "closes the dialog" do
        expect(Yast::UI).to receive(:CloseDialog)

        subject.run
      end
    end

    it "returns the response of InstLicense client" do
      expect(subject.run).to eq(client_response)
    end
  end
end
