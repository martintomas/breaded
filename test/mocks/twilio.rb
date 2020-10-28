# frozen_string_literal: true

module Mocks
  module Twilio
    def mock_twilio_for(message = Hash)
      twilio_mock = MiniTest::Mock.new
      twilio_mock_client = MiniTest::Mock.new
      twilio_mock.expect :messages, twilio_mock_client
      twilio_mock_client.expect :create, true, [message]
      twilio_mock
    end
  end
end
