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

    def initialize(options)
        puts "Starting selenium-webdriver ..."

        @driver = Selenium::WebDriver.for :firefox
        @image_dir = 'images/screenshots'
        @urls = options[:urls_to_visit]
        @logos = options[:logos_to_search_for]

        @log_file = 'results.txt' # options[:log_file_name] ||
        File.delete(@log_file) if File.exists?(@log_file)
    end

    def take_screenshot(name)
        path = "#{@image_dir}/#{name.downcase}.png"
        @driver.save_screenshot(path)
        log_to_file "Screenshot taken [Saved to: #{path}]"
    end

    # Returns true if at least one image was found
    def search_for_images_by_src(logos = [])
        @logos ||= logos

       # @logos.each do |key|
            return true if image_with_src_exists?(@logos[0])
        #end

        return false
    end

    # Returns true if image was found
    def image_with_src_exists?(image_src = '')
        
        begin
            wait = Selenium::WebDriver::Wait.new(:timeout => 2)
 
            log_to_file "Done: found image #{image_src}" if wait.until {
                @driver.find_element(:xpath => "//img[@src='#{image_src}']").displayed?
            }
            true
        rescue Exception => e
            log_to_file "Failed: could not find image with src: #{image_src}"
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
                    log_to_file "Error: .#{selector} selector is hidden or not found"
                    false
                end
            }
        rescue Exception => e
            log_to_file "Failed: .#{selector} selector is hidden or not found"
            false
        end

    end

    def execute_tests
        img_exists = search_for_images_by_src
        wrapper_exists = test_if_wrapper_visible?

        return img_exists || wrapper_exists
    end

    def visit_urls        
        
        urls.each do |key, url|
            
            log_to_file line
            log_to_file "Visiting #{key} - #{url}"

            @driver.get url

            unless execute_tests
                take_screenshot(key)
                log_to_file ">>>>>>>>>>>>>>>>>>>>>> FAILED"
            else
                log_to_file ">>>>>>>>>>>>>>>>>>>>>> PASSED"
            end

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
        puts message # For command line
        File.open(@log_file, 'a+') {|file| file.write("#{message}\n") }
    end
end

# ----------------------------------
# Setup and init
# ----------------------------------
logos = [
  
]

urls = {   
    'Google' => "http://www.google.at"
}

finder = FindoLogo.new({ 
    :urls_to_visit => urls, 
    :logos_to_search_for => logos
})
finder.visit_urls