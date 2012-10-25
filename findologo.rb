require 'rubygems'
require 'selenium-webdriver'

class FindoLogo

    attr_accessor :driver, :image_dir, :urls

    def initialize(urls)
        @driver = Selenium::WebDriver.for :firefox         
        @image_dir = 'images/screenshots'
        @urls = urls
    end

    def take_screenshot(name)
        @driver.save_screenshot("#{@image_dir}/#{name.downcase}.png")
    end

    def visit_urls
        urls.each do |key, url|
            @driver.get url

            take_screenshot(key)
        end

        quit
    end

    def quit
        @driver.quit
    end

    def log_to_file message

    end
end

# ----------------------------------
urls = {
    "Google" => "https://www.google.com"
}

finder = FindoLogo.new(urls)
finder.visit_urls