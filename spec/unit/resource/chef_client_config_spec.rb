#
# Author:: Tim Smith (<tsmith@chef.io>)
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
#

require "spec_helper"

describe Chef::Resource::ChefClientConfig do
  let(:node) { Chef::Node.new }
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:resource) { Chef::Resource::ChefClientConfig.new("fakey_fakerton", run_context) }
  let(:provider) { resource.provider_for_action(:create) }

  it "sets the default action as :create" do
    expect(resource.action).to eql([:create])
  end

  it "supports :create and :remove actions" do
    expect { resource.action :create }.not_to raise_error
    expect { resource.action :remove }.not_to raise_error
  end

  context "ssl_verify_mode" do
    it "coerces String to Symbol" do
      resource.ssl_verify_mode "ssl_verify_mode"
      expect(resource.ssl_verify_mode).to eql(:ssl_verify_mode)
    end

    it "coerces Symbol-like String to Symbol" do
      resource.ssl_verify_mode ":ssl_verify_mode"
      expect(resource.ssl_verify_mode).to eql(:ssl_verify_mode)
    end

    it "raises an error if it is not an allowed value" do
      expect { resource.ssl_verify_mode("foo") }.to raise_error(Chef::Exceptions::ValidationFailed)
      expect { resource.ssl_verify_mode(:verify_none) }.not_to raise_error(Chef::Exceptions::ValidationFailed)
      expect { resource.ssl_verify_mode(:verify_peer) }.not_to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end
end
