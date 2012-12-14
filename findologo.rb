#
# FINDOLOGO 
# tests if a website has a specific image
#

# Requiered GEMs:
require 'rubygems'
require 'selenium-webdriver'
require 'RMagick'

# -------------------------------------------------
# Logger Class
class Logger
    include Singleton

    attr_accessor :file

    def self.set_up
        @file = 'results.txt'
        File.delete(@file) if File.exists?(@file)
    end
    
    def self.nl
        log "\n"
    end

    def self.line(amount = 24)
        line = ""
        amount.times { line += "-" }
        return line
    end

    def self.log_line
        log line
    end

    def self.log message
        puts message # For command line
        File.open(@file, 'a+') {|file| file.write("#{message}\n") } if message
    end

end

# -------------------------------------------------
# Website Class
#   => represents a single website
class Website

    attr_accessor :title, :url, :is_image_visible, :is_wrapper_visible, :has_logo

    def initialize(data)
        @title = data[:title]
        @url = data[:url]

        @is_wrapper_visible = false
        @is_image_visible = false
        @has_logo = false
    end

end

# -------------------------------------------------
# FindoLogo Class
#   => Visits a website and searchs for an image (logo)
#   => Logs results to results.txt
#   => Takes screenshot (images/screenshots/)

class FindoLogo

    attr_accessor :driver, :image_dir, :websites, :logos

    def initialize(options)
        @image_dir = 'images/screenshots'
        @websites_data = options[:websites_to_visit]
        @logos = options[:logos_to_search_for]
        @websites = []

        push_websites()
    end

    def run                
        before_run()

        visit_websites()       

        after_run()
    end

    def before_run
        start_driver()
    end

    def after_run        
        @driver.quit
    end

    def push_websites

        return false if !@websites_data

        @websites_data.each do |key, value|
            @websites.push( Website.new({ :title => key, :url => value }) )
        end

    end

    def start_driver
        puts "Starting selenium-webdriver ..."
        @driver = Selenium::WebDriver.for :firefox
    end

    # --------------------------------------
    def visit_websites
        
        websites.each do |website|
            
            Logger::nl
            Logger::log_line
            Logger::log "Visiting #{website.title} - #{website.url}"

            @driver.get website.url

            if execute_tests_on_website website
                Logger::log ">>>>>>>>>>>>>>>>>>>>>> PASSED"
            else
                Logger::log ">>>>>>>>>>>>>>>>>>>>>> FAILED"
            end
            
        end

    end

    def execute_tests_on_website website

        website.is_image_visible   = test_if_a_logo_visible? #TODO: set this to website should_have_logo_file if found
        website.is_wrapper_visible = test_if_element_visible?({:class => "fl_logo_wrapper"})

        screenshot = take_screenshot(website.title)

        website.has_logo = search_for_logos_in_screenshot(screenshot)

    end

    def test_if_element_visible?(selector)
        isVisible = false

        begin
            wait = Selenium::WebDriver::Wait.new(:timeout => 3)            
            wait.until {
                element = @driver.find_element( selector )
                isVisible = element.displayed?                 
            }
        rescue Exception => e         
            false
        end

        return isVisible
    end

    def take_screenshot(file_name)

        file_name = "#{file_name.downcase}.png"
        path = "#{@image_dir}/#{file_name}"
        @driver.save_screenshot(path)

        Logger::log "Screenshot taken [Saved to: #{path}]"
        
        return file_name

    end

    def test_if_a_logo_visible?
        state = false

        @logos.each do |logo|
            if test_if_element_visible?({:xpath => "//img[@src='#{logo}']"})
                state = true
                break
            end
        end

        return state
        
    end
    
    def search_for_logos_in_screenshot(screenshot)
        state = false

        @logos.each do |logo|
            if locate_logo_in_screenshot(logo, screenshot)
                state = true
                break
            end
        end

        return state
    end

    def locate_logo_in_screenshot(logo_file, screenshot)
        
        state = false
        screenshot_file = "images/screenshots/#{screenshot}";
        begin
            logo = Magick::Image.read("images/logos/#{logo_file}").first
            target = Magick::Image.read(screenshot_file).first

            state = target.find_similar_region(logo)

            Logger::log "Searching for #{logo_file} in #{screenshot} ..."
            puts logo.rows
            puts logo.columns

            if state             
                Logger::log "Done: found #{logo_file} in screenshot"
                draw_rectangle_on_screenshot(state[0], state[1], logo.columns, logo.rows, screenshot_file)
                state = true
            else
                Logger::log "Failed: could not find #{logo_file} in screenshot"
                state = false
            end    

        rescue Exception => e
            Logger::log "Failed to find logo in screenshot"
            false        
        end

        return state

    end

    def draw_rectangle_on_screenshot(x, y, width, height, target_path)
        
        target = Magick::Image.read(target_path).first

        gc = Magick::Draw.new
        gc.stroke('red')
        gc.fill_opacity(0)
        gc.stroke_width(2)
        gc.rectangle(x, y, x + width, y + height)        
        gc.draw(target)
        target.write(target_path)

    end
   
end

# ----------------------------------
# Setup and init
# ----------------------------------
Logger::set_up()

logos = [

]

websites = {

}

finder = FindoLogo.new({
    :websites_to_visit => websites,
    :logos_to_search_for => logos
})
finder.run