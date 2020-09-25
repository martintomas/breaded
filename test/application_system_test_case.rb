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
  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = 4000
  Capybara.app_host = "http://web:4000"

  driven_by :headless_selenium_chrome_in_container

  def login_as_admin
    visit new_session_path
    fill_in 'session[email]', with: users(:admin).email
    fill_in 'session[password]', with: user(:admin).password

    click_on 'Log in'
  end
end
