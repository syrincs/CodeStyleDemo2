require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_hosts '127.0.0.1', 'localhost'
  c.register_request_matcher :xml_action do |request_1, request_2|

    def action(body)
      match_data = body.match(/<\/(.*)Request>/)
      match_data && match_data[1]
    end

    action(request_1.body) == action(request_2.body)
  end
end
