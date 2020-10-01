#
# Author:: Matt Wrock (<mwrock@chef.io>)
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef
  class Pwsh < Chef::PowerShell

    @@wrapper_dll ||= Dir.glob("#{RbConfig::CONFIG["bindir"]}/**/Chef.PowerShell.Wrapper.Core.dll").last

    # Run a command under pwsh (powershell core) via FFI
    # This implementation requires the managed dll, native wrapper and a
    # published, self contained dotnet core directory tree to exist in the
    # bindir directory.
    #
    # @param script [String] script to run
    # @return [Object] output
    def initialize(script)
      @dll = @@wrapper_dll
      super
    end

    protected

    def exec(script)
      # Note that we need to override the location of the shared dotnet core library
      # location. With most .net core applications, you can simply publish them as a
      # "self-contained" application allowing consumers of the application to run them
      # and use its own stand alone version of the .net core runtime. However because
      # this is simply a dll and not an exe, it will look for the runtime in the shared
      # .net core installation folder. By setting DOTNET_MULTILEVEL_LOOKUP to 0 we can
      # override that folder's location with DOTNET_ROOT. To avoid the possibility of
      # interfering with other .net core processes that might rely on the common shared
      # location, we revert these variables after the script completes.
      original_dml = ENV["DOTNET_MULTILEVEL_LOOKUP"]
      original_dotnet_root = ENV["DOTNET_ROOT"]

      ENV["DOTNET_MULTILEVEL_LOOKUP"] = "0"
      ENV["DOTNET_ROOT"] = RbConfig::CONFIG["bindir"]

      super
    ensure
      ENV["DOTNET_MULTILEVEL_LOOKUP"] = original_dml
      ENV["DOTNET_ROOT"] = original_dotnet_root
    end
  end
end
