# https://github.com/webarbeit/logo-seeker
require 'rubygems'
require 'selenium-webdriver'

# -------------------------------------------------
# FindoLogo Class
#   => Visits a website and searchs for an image (logo)
#   => Logs results to results.txt
#   => Takes screenshot (images/screenshots/)

class FindoLogo

    attr_accessor :driver, :image_dir, :urls

    def initialize(urls, logos = [], log_file_name = 'results.txt')
        puts "Starting selenium-webdriver ..."

        @driver = Selenium::WebDriver.for :firefox
        @image_dir = 'images/screenshots'
        @urls = urls
        @logos = logos

        @log_file = log_file_name
        File.delete(@log_file) if File.exists?(@log_file)
    end

    def take_screenshot(name)
        @driver.save_screenshot("#{@image_dir}/#{name.downcase}.png")
        log_to_file 'Screenshot taken.'
    end

    def test_if_image_exists?(image_src = '')
        
        logo = @logos[0]

        begin
            wait = Selenium::WebDriver::Wait.new(:timeout => 2)
 
            # Check that the image exists using different attributes and xpath
            log_to_file "Image-Src Test passed for logo #{logo}" if wait.until {
                @driver.find_element(:xpath => "//img[@src='#{logo}']").displayed?
            }
            true
        rescue Exception => e
            log_to_file "Image-Src Test failed for logo #{logo}"
            false
        end

    end

    def test_if_wrapper_visible?(selector = 'findologic_logo')
        
        begin 
            wait = Selenium::WebDriver::Wait.new(:timeout => 3)
            
            wait.until {
                linkWrapper = @driver.find_element(:class, selector)

                if linkWrapper.displayed?
                    log_to_file "Done: .#{selector} selector is visible"
                    true
                else
                    log_to_file "Error: .#{selector} selector is hidden"
                    false
                end                
            }
        rescue Exception => e
            log_to_file "Visiblity-Test failed for selector #{selector}"
            false
        end

    end

    def visit_urls        
        
        urls.each do |key, url|
            
            log_to_file line
            log_to_file "Visiting #{key} - #{url}"

            @driver.get url

            img_exists = test_if_image_exists?
            wrapper_exists = test_if_wrapper_visible?
            
            unless img_exists || wrapper_exists
                take_screenshot(key)
            end

        end

        quit

        # match_logos_with_screenshots        
    end

    def match_logos_with_screenshots
        # Object recognition comes here ...
    end

    def quit
        @driver.quit
    end

    def line
        "\n---------------------------\n"
    end

    def log_to_file message
        puts message # For command line
        File.open(@log_file, 'a+') {|file| file.write("#{message}\n") }
    end
end

# ----------------------------------
# Setup and init
# ----------------------------------
logos_to_search_for = [

]

urls = {
    
}

finder = FindoLogo.new(urls, logos_to_search_for)
finder.visit_urls