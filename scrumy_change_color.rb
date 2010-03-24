require "rubygems"
require "bundler"
Bundler.setup

require "mechanize"
require 'logger'

class ScrumyChangeColor
  
  ALLOWED_COLORS = [
    'white', 'yellow', 'mint', 'pink', 'green', 'violet', 'grey', 'lime',
    'blue', 'goldenrod', 'seaweed', 'chocolate', 'altervibe-red', 'def-blue',
    'teal', 'dark', 'halloween', 'tropics', 'sponge', 'tabloid'
  ]
  
  def initialize(scrumy_board, password, user, color)
    @scrumy_board = scrumy_board
    @password = password
    @user = user
    @color = color
    @logfile ||= File.join(File.dirname(__FILE__),'scrumy_change_color.log')
    
    raise "Color you have selected isn't supported by scrumy.com!" unless ALLOWED_COLORS.include?(@color)
  end
  
  def change
    start_agent
    page = login
    auth_token = retrieve_authenticity_token(page)
    change_color(auth_token)
  end
  
  private
  
    def start_agent
      @agent = Mechanize.new { |a| a.log = Logger.new(@logfile) }
      @agent.user_agent_alias = 'Mac Safari'
    end

    def login
      page = @agent.get("https://scrumy.com/#{@scrumy_board}/signin")
      login_form = page.form_with(:action => "/#{@scrumy_board}/signin")
      login_form.fields_with(:name => "password").first.value = @password
      @agent.submit(login_form)
    end
  
    def retrieve_authenticity_token(page)
      change_color_form = page.form_with(:action => "/#{@scrumy_board}/scrumer_colors")
      change_color_form.fields_with(:name => 'authenticity_token').first.value
    end
  
    def change_color(auth_token)
      @agent.post("https://scrumy.com/#{@scrumy_board}/scrumer_colors", {
        :authenticity_token => auth_token,
        :commit => 'Save',
        'scrumers[0][id]' => @user,
        'scrumers[0][color]' => @color
      })
    end
  
end