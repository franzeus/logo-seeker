require 'rubygems'
require 'selenium-webdriver'

class FindoLogo

    attr_accessor :driver, :image_dir, :urls

    def initialize(urls, logos = [], log_file_name = 'results.txt')
        @driver = Selenium::WebDriver.for :firefox
        @image_dir = 'images/screenshots'
        @urls = urls
        @logos = logos

        @log_file = log_file_name
        File.delete(@log_file) if File.exists?(@log_file)
    end

    def take_screenshot(name)
        @driver.save_screenshot("#{@image_dir}/#{name.downcase}.png")
    end

    def test_for_image_src
        
        logo = @logos[0]

        begin
            log_to_file "Image-Src Test passed for logo #{logo}" if @driver.find_element(:xpath => "//img[@src='logo']").displayed?
        rescue Exception => e
            log_to_file "Image-Src Test failed for logo #{logo}"
        end

    end

    def visit_urls        
        
        urls.each do |key, url|
            
            log_to_file line
            log_to_file "Visiting #{key} - #{url}"

            @driver.get url

            test_for_image_src
            take_screenshot(key)

        end

        quit
    end

    def quit
        @driver.quit
    end

    def line
        "\n---------------------------\n"
    end

    def log_to_file message
        puts message

        File.open(@log_file, 'a+') {|file| file.write("#{message}\n") }
    end
end

# ----------------------------------
# Setup and init
# ----------------------------------
logos = [
    'http://findologic.com/bild/frauLupe_beschn_206x668.jpg'
]

urls = {
    "Findologic" => "http://findologic.com/de/"
}

finder = FindoLogo.new(urls, logos)
finder.visit_urls