require './constants.rb'

require './model/server.rb'

module Variables
  include Constants

  def setup
    @servers = const["servers"].collect do |details|
      Server.new details["name"], details["ip"], details["port"], details["password"], details["rcon"]
    end
  
    @server = @servers.first
    @map = const["maps"].first
  
    @signups = {}
    @players = {}
    @spoken = {}
    @afk = []

    @teams = []
    @lookup = {}
    
    @last = nil
    @state = const["states"]["waiting"]
    @pick = 0
  end
end
