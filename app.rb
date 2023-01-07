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


# Start the game by typing "!game" in chat.
bot.command(:guess) do |event|
  # Pick a number between 1 and 10
  magic = rand(1..10)

  puts("Magic number is #{magic}")
  # Await a MessageEvent specifically from the invoking user.
  #
  # Note that since the identifier I'm using here is `:guess`,
  # only one person can be playing at one time. You can otherwise
  # interpolate something into a symbol to have multiple awaits
  # for this "command" available at the same time.
  event.user.await(:guess) do |guess_event|
    # Their message is a string - cast it to an integer
    guess = guess_event.message.content.to_i

    # If the block returns anything that *isn't* `false`, then the
    # event handler will persist and continue to handle messages.
    if guess == magic
      # This returns `nil`, which will destroy the await so we don't reply anymore
      guess_event.respond 'you win!'
    else
      # Let the user know if they guessed too high or low.
      guess_event.respond(guess > magic ? 'too high' : 'too low')

      # Return false so the await is not destroyed, and we continue to listen
      false
    end
  end

  # Let the user know we're  ready and listening..
  event.respond 'Guess a number between 1 and 10..'
end

bot.command(:about) do |event|
  event.respond 'I am a bot made by <@1045871493587939379> using Ruby, I will play fun games with you!. I am currently in development.'
end


bot.command(:connect) do |event|
  # The `voice_channel` method returns the voice channel the user is currently in, or `nil` if the user is not in a
  # voice channel.
  channel = event.user.voice_channel

  # Here we return from the command unless the channel is not nil (i. e. the user is in a voice channel). The `next`
  # construct can be used to exit a command prematurely, and even send a message while we're at it.
  next "You're not in any voice channel!" unless channel

  # The `voice_connect` method does everything necessary for the bot to connect to a voice channel. Afterwards the bot
  # will be connected and ready to play stuff back.
  bot.voice_connect(channel)
  "Connected to voice channel: #{channel.name}"
end

# A simple command that plays back an mp3 file.
bot.command(:play_mp3) do |event|
  # `event.voice` is a helper method that gets the correct voice bot on the server the bot is currently in. Since a
  # bot may be connected to more than one voice channel (never more than one on the same server, though), this is
  # necessary to allow the differentiation of servers.
  #
  # It returns a `VoiceBot` object that methods such as `play_file` can be called on.
  voice_bot = event.voice
  voice_bot.play_file('./music.mp3')
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run