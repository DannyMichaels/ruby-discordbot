# frozen_string_literal: true
require 'dotenv/load'

# This simple bot responds to every "Ping!" message with a "Pong!"

require 'discordrb'

# This statement creates a bot with the specified token and application ID. After this line, you can add events to the
# created bot, and eventually run it.
#
# If you don't yet have a token to put in here, you will need to create a bot account here:
#   https://discordapp.com/developers/applications
# If you're wondering about what redirect URIs and RPC origins, you can ignore those for now. If that doesn't satisfy
# you, look here: https://github.com/discordrb/discordrb/wiki/Redirect-URIs-and-RPC-origins
# After creating the bot, simply copy the token (*not* the OAuth2 secret) and put it into the
# respective place.
# bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']


# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '.'

bot.command :user do |event|
  # Commands send whatever is returned from the block to the channel. This allows for compact commands like this,
  # but you have to be aware of this so you don't accidentally return something you didn't intend to.
  # To prevent the return value to be sent to the channel, you can just return `nil`.
  event.user.name
end

bot.command :bold do |_event, *args|
  # Again, the return value of the block is sent to the channel
  "**#{args.join(' ')}**"
end

# This method call adds an event handler that will be called on any message that exactly contains the string "Ping!".
# The code inside it will be executed, and a "Pong!" response will be sent to the channel.
bot.command :ping do |event|
  event.respond 'Pong!'
end


bot.command(:random, min_args: 0, max_args: 2, description: 'Generates a random number between 0 and 1, 0 and max or min and max.', usage: 'random [min/max] [max]') do |_event, min, max|
  # The `if` statement returns one of multiple different things based on the condition. Its return value
  # is then returned from the block and sent to the channel
  if max
    rand(min.to_i..max.to_i)
  elsif min
    rand(0..min.to_i)
  else
    rand
  end
end

bot.command(:rps) do |event, *args| 
  #rock paper scissor
  moves = ["rock", "scissors", "paper"]
  if (!args[0] || !moves.include?(args[0].downcase)) 
    event.message.reply("Please enter a valid move. Valid moves are: rock, paper, scissors.");
    return nil
  end

  user_move = args[0].downcase
  result = rock_paper_scissors(user_move, event.message)
  event.message.reply(result)
end

def rock_paper_scissors(user_move, message) 
  moves = ["rock", "scissors", "paper"]
  computer_move = moves.sample
  message.reply("You chose #{user_move}. I chose #{computer_move}.")

  if user_move == computer_move
    return "It's a tie!"
  elsif user_move == "rock" && computer_move == "scissors"
    return "You win!"
  elsif user_move == "scissors" && computer_move == "paper"
    return "You win!"
  elsif user_move == "paper" && computer_move == "rock"
    return "You win!"
  else 
    return "I win!"
  end
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run