module AllowedSites
  def self.all
    sites = [Regexp.new('chromedriver.storage.googleapis.com')]
    sites += [Regexp.new(ENV['SELENIUM_URL'])] if ENV['SELENIUM_URL'].present?
    sites
  end
end

WebMock.disable_net_connect!(allow_localhost: true, allow: AllowedSites.all)
