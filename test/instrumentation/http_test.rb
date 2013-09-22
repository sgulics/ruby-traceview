require 'minitest_helper'
require 'net/http'


describe Oboe::Inst do
  before do
    clear_all_traces 
  end

  it 'Net::HTTP should be defined and ready' do
    defined?(::Net::HTTP).wont_match nil 
  end

  it 'Net::HTTP should have oboe methods defined' do
    [ :request_with_oboe ].each do |m|
      ::Net::HTTP.method_defined?(m).must_equal true
    end
  end

  it "should trace a Net::HTTP request" do
    Oboe::API.start_trace('net-http_test', '', {}) do
      uri = URI('https://www.google.com')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.get('/?q=test').read_body
    end

    traces = get_all_traces
    debugger
    traces.count.must_equal 5

    traces.first['Layer'].must_equal 'net-http_test'
    traces.first['Label'].must_equal 'entry'

    traces[1]['Layer'].must_equal 'net-http'
    traces[2]['IsService'].must_equal "1"
    traces[2]['RemoteProtocol'].must_equal "HTTPS"
    traces[2]['RemoteHost'].must_equal "www.google.com"
    traces[2]['ServiceArg'].must_equal "/?q=test"
    traces[2]['Method'].must_equal "GET"

    traces.last['Layer'].must_equal 'net-http_test'
    traces.last['Label'].must_equal 'exit'
  end
end
