module PlayersLogic
  def add_player user, classes
    return notice user, "You cannot add at this time, please wait for picking to end." unless can_add? # stateLogic.rb
    notice user, "You must be authorized with GameSurge in order to play in this channel, but consider this a warning. http://www.gamesurge.net/newuser/" unless user.authed?
    
    classes.collect! { |clss| clss.downcase }
    classes.reject! { |clss| not Const::Team_classes.key? clss }

    return notice user, "Invalid classes, you have not been added." if classes.empty?
    
    @players[user] = classes
  end

  def remove_player user
    return notice user, "You cannot remove at this time." unless can_remove? # stateLogic.rb
    
    @players.delete user
  end
  
  def list_players
    output = @players.keys.collect do |user|
      medic, captain = @players[user].include?("medic"), @players[user].include?("captain")
      special = ":#{ colourize "m", Const::Colour_red if medic }#{ colourize "c", Const::Colour_yellow if captain }" if medic or captain
      "#{ user.to_s }#{ special }"
    end
    message "#{ make_title "#{ @players.size } users added:" } #{ output.join(", ") }"
  end

  def list_players_detailed
    temp = get_classes
    Const::Team_classes.each_key do |k|
      message "#{ make_title "#{ k }:", Const::Colour_black, Const::Colour_lightgrey } #{ temp[k].join(", ") }" if temp[k]
    end
  end
  
  def replace_player user, replacement
    @players[replacement] = @players.delete(user) if @players.key? user
    @teams.each do |team|
      team.captain = replacement if team.captain == user
      team.players[replacement] = team.players.delete(user) if team.players.key? user
    end
  end
  
  def get_classes
    @players.invert_proper_arr
  end
  
  # I hate this function, but it is so important
  def classes_needed players, multiplier = 1
    required = Const::Team_classes.collect { |k, v| v * multiplier - (players[k] ||= []).size }
    required.reject! { |k, v| v <= 0 } # Remove any negative or zero values
    required
  end

  def list_classes_needed
    output = classes_needed(get_classes, Const::Team_count).to_a
    output.unshift [ "players" , (Const::Team_size * Const::Team_count - @players.size)] if @players.size < Const::Team_size * Const::Team_count
    output.collect! { |a| "#{ a[1] } #{ a[0] }" } # Format the output

    message "Required classes: #{ output.join(", ") }"
  end

  def minimum_players?
    return false if @players.size < Const::Team_size * Const::Team_count
    return classes_needed(get_classes, Const::Team_count).empty?
  end
end