require 'spec_helper'
require 'fileutils'

describe 'Blacksmith::Forge' do

  subject { Blacksmith::Forge.new(username, password, forge) }
  let(:username) { 'johndoe' }
  let(:password) { 'secret' }
  let(:forge) { "https://forge.puppetlabs.com" }
  let(:module_name) { "test" }
  let(:version) { "1.0.0" }
  let(:package) { File.dirname(__FILE__) + '/../data/maestrodev-ant-1.0.4.tar.gz' }

  describe 'missing credentials file' do
    before do
      allow(File).to receive(:expand_path) { '/home/mr_puppet/.puppetforge.yml' }
    end

    context "when the credentials file is missing" do
      before do

      end

      it "should raise an error" do
        expect { foo = Blacksmith::Forge.new(nil, password, forge) }.to raise_error(/Could not find Puppet Forge credentials file '\/home\/mr\_puppet\/.puppetforge.yml'\s*Please create it\s*---\s*url: https:\/\/forge.puppetlabs.com\s*username: myuser\s*password: mypassword/)
      end
    end

  end

  describe 'push' do

    before do
      FileUtils.mkdir_p("pkg")
      FileUtils.touch("pkg/#{username}-#{module_name}-#{version}.tar.gz")
    end

    context "when using username and password" do
      before do
        stub_request(:post, "#{forge}/login").with(
          :body => {'username' => username, 'password' => password}).to_return(
          :status => 200, :headers => { 'Set-Cookie' => "auth=xxx; path=/; expires=Tue, 27-Aug-2013 08:34:51 GMT" })

        stub_request(:post, "#{forge}/#{username}/#{module_name}/upload").to_return(:status => 200)
        subject.push!(module_name, package)
      end

      it "should push the module" do

      end
    end

    context "when forge returns an error" do
      before do
        stub_request(:post, "#{forge}/login").with(
          :body => {'username' => username, 'password' => password}).to_return(
          :status => 200, :headers => { 'Set-Cookie' => "auth=xxx; path=/; expires=Tue, 27-Aug-2013 08:34:51 GMT" })

        stub_request(:post, "#{forge}/#{username}/#{module_name}/upload").to_return(
          :body => File.new('spec/data/forge_error.html'), :status => 200)
      end

      it "should handle the error" do
        expect { subject.push!(module_name, package) }.to raise_error(%r{^Error uploading module .*maestrodev-ant-1.0.4.tar.gz to Puppet Forge johndoe/test})
      end
    end
  end
end

