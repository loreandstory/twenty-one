$LOAD_PATH << "modules/"

require 'handle_cards'
require 'play_game'
require 'colorize'

def play_again?
  choice = ""
  loop do
    print "=> Play again? (y/n): "
    choice = gets.chomp

    break if choice.match?(/ye?s?/i) || choice.match?(/no?/i)
    print "Sorry, I couldn't understand your input. Please try again...\n\n"
  end

  choice.match?(/ye?s?/i) ? true : false
end

def colorize_winner(winner)
  case winner
  when 'player'
    winner.colorize(:blue)
  when 'dealer'
    winner.colorize(:red)
  else
    winner.colorize(:light_white)
  end
end

BUST = 21

game = {
  deck: nil,
  dealer: {
    hand: nil,
    hand_value: 0,
    wins: 0
  },

  player: {
    hand: nil,
    hand_value: 0,
    wins: 0
  },

  winner: nil,
  ties: 0
}

loop do
  game[:winner] = nil
  system('clear')

  game[:deck], game[:player][:hand], game[:dealer][:hand] =
    PlayGame.shuffle_and_deal

  game[:player][:hand_value] = HandleCards.sum_hand_value(game[:player][:hand])
  game[:dealer][:hand_value] = HandleCards.sum_hand_value(game[:dealer][:hand])

  PlayGame.players_turn(game)
  PlayGame.dealers_turn(game) if game[:winner].nil?

  player_score = game[:player][:hand_value]
  dealer_score = game[:dealer][:hand_value]

  if game[:winner].nil?
    game[:winner] = player_score > dealer_score ? 'player' : 'dealer'

    game[:winner] = 'tie' if player_score == dealer_score
  end

  case game[:winner]
  when 'player'
    game[:player][:wins] += 1
  when 'dealer'
    game[:dealer][:wins] += 1
  else
    game[:ties] += 1
  end

  print "dealer score: #{game[:dealer][:hand_value]}\n"
  print "player score: #{game[:player][:hand_value]}\n"

  print "\n----------------\n"
  print "winner: #{colorize_winner(game[:winner])}"
  print "\n----------------\n"

  print "  wins: #{game[:player][:wins]}\n"
  print " loses: #{game[:dealer][:wins]}\n"
  print "  ties: #{game[:ties]}\n\n"

  break unless play_again?
end
