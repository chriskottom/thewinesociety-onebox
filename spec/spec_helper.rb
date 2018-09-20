require 'rspec'
require 'fakeweb'
require 'onebox'
require 'mocha/api'

$: << File.join(File.dirname(__FILE__), '/../gems/2.3.1/gems/money-6.12.0/lib')
require 'money'

$: << File.join(File.dirname(__FILE__), '/../lib')
load 'onebox/helpers.rb'
require 'onebox/engine/thewinesociety_onebox'

Onebox.options.load_paths << File.join(File.dirname(__FILE__), '../templates')

module HTMLSpecHelper
  def fake(uri, response, verb = :get)
    FakeWeb.register_uri(verb, uri, response: header(response))
  end

  def header(html)
    "HTTP/1.1 200 OK\n\n#{html}"
  end

  def onebox_view(html)
    %|<div class="onebox">#{html}</div>|
  end

  def response(file)
    file = File.join("spec", "fixtures", "#{file}.response")
    File.exists?(file) ? File.read(file) : ""
  end
end

# Monkey-patch fakeweb to support Ruby 2.4+.
# See https://github.com/chrisk/fakeweb/pull/59.
module FakeWeb
  class StubSocket
    def close; end
  end
end

RSpec.configure do |config|
  config.before(:all) do
    FakeWeb.allow_net_connect = false
  end
  config.include HTMLSpecHelper
  config.full_backtrace = false
end

shared_context "engines" do
  before(:each) do
    fake(@uri || @link, response(described_class.onebox_name))
    @onebox = described_class.new(@link)
    @html = @onebox.to_html
    @data = Onebox::Helpers.symbolize_keys(@onebox.send(:data))
  end
  before(:each) { Onebox.options.cache.clear }

  let(:onebox) { @onebox }
  let(:html) { @html }
  let(:data) { @data }
  let(:link) { @link }
end

shared_examples_for "an engine" do
  it "responds to data" do
    expect(described_class.private_instance_methods).to include(:data)
  end

  it "responds to record" do
    expect(described_class.private_instance_methods).to include(:record)
  end

  it "correctly matches the url" do
    onebox = Onebox::Matcher.new(link).oneboxed
    expect(onebox).to be(described_class)
  end

  describe "#data" do
    it "includes title" do
      expect(data[:title]).not_to be_nil
    end

    it "includes link" do
      expect(data[:link]).not_to be_nil
    end

    it "is serializable" do
      expect { Marshal.dump(data) }.to_not raise_error
    end
  end
end


shared_examples_for "a layout engine" do
  describe "#to_html" do
    it "includes subname" do
      expect(html).to include(%|<aside class="onebox #{described_class.onebox_name}">|)
    end

    it "includes title" do
      expect(html).to include(data[:title])
    end

    it "includes link" do
      expect(html).to include(%|class="link" href="#{data[:link]}|)
    end

    it "includes badge" do
      expect(html).to include(%|<strong class="name">#{data[:badge]}</strong>|)
    end

    it "includes domain" do
      expect(html).to include(%|class="domain" href="#{data[:domain]}|)
    end
  end
end
