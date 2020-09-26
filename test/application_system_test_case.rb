# frozen_string_literal: true

require 'test_helper'

Capybara.register_driver :headless_selenium_chrome_in_container do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=1440x768) }
  )

  Capybara::Selenium::Driver.new(app,
                                 :browser => :remote,
                                 url: ENV['SELENIUM_URL'],
                                 desired_capabilities: capabilities)
end

Capybara.register_driver :selenium_chrome_in_container do |app|
  Capybara::Selenium::Driver.new(app,
                                 :browser => :remote,
                                 url: ENV['SELENIUM_URL'],
                                 desired_capabilities: :chrome)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :headless_selenium_chrome_in_container

  setup do
    Capybara.server_host = '0.0.0.0'
    Capybara.app_host = "http://#{Socket.ip_address_list.detect(&:ipv4_private?).ip_address}:#{Capybara.server_port}"
  end

  def login_as_admin
    visit new_user_session_path
    fill_in 'user[email]', with: 'admin@breaded.net'
    fill_in 'user[password]', with: 'password'

    click_on 'Log in'
  end
end
