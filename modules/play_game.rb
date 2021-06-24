module PlayGame
  $LOAD_PATH << '.'

  require 'handle_cards'
  require 'colorize'

  def self.shuffle_and_deal
    deck = HandleCards.make_and_shuffle_deck

    player_hand = [deck.pop, deck.pop]
    dealer_hand = [deck.pop, deck.pop]

    [deck, HandleCards.sort_hand(player_hand), dealer_hand]
  end

  def self.color_new_card(hand, new_card_color)
    hand[0..-2] << hand.last.colorize(new_card_color)
  end

  def self.display_cards(hand)
    hand_str = ""
    hand.each do |card|
      hand_str << " | #{card} | "
    end

    hand_str
  end

  def self.hide_dealers_2nd_card(dealers_hand)
    dup_hand = dealers_hand.dup
    dup_hand[-1] = '?'

    dup_hand
  end

  def self.display_hand(hand, is_dealers = false, dealers_turn = false)
    if is_dealers && !dealers_turn
      printable_hand = hide_dealers_2nd_card(hand)

    elsif is_dealers && dealers_turn
      printable_hand = color_new_card(hand, :red)

    elsif hand.size > 2 && !is_dealers
      colorized_hand = color_new_card(hand, :blue)
      printable_hand = HandleCards.sort_hand(colorized_hand)

    else
      printable_hand = hand
    end

    display_cards(printable_hand)
  end

  def self.display_dealer_and_player_hands(game, dealers_turn = false)
    dealers_hand = game[:dealer][:hand]
    players_hand = game[:player][:hand]

    print "\n\nDealer's hand: #{display_hand(dealers_hand, true,
                                             dealers_turn)}\n"
    print "    Your hand: #{display_hand(players_hand)}\n\n"
  end

  def self.player_hit_or_stay
    choice = ""
    loop do
      print "=> Hit or stay? (h/s): "
      choice = gets.chomp

      break if choice.match?(/hi?t?/i) || choice.match?(/st?a?y?/i)
      print "Sorry, I couldn't understand your input. Please try again...\n\n"
    end

    choice.match?(/hi?t?/i) ? 'hit' : 'stay'
  end

  def self.players_turn(game)
    loop do
      system('clear')
      puts "| Player's Turn |".colorize(:blue)
      display_dealer_and_player_hands(game)

      hand = game[:player][:hand]
      game[:player][:hand_value] = HandleCards.sum_hand_value(hand)

      if game[:player][:hand_value] > BUST
        game[:winner] = 'dealer'
        puts "#{'player'.colorize(:blue)} BUST!\n\n"
        break
      end

      choice = player_hit_or_stay

      case choice
      when 'stay'
        break
      when 'hit'
        hand << HandleCards.hit!(game[:deck])
      end
    end
  end

  def self.dealers_turn(game)
    loop do
      system('clear')
      puts "| Dealer's Turn |".colorize(:red)

      display_dealer_and_player_hands(game, true)
      sleep(1.5)

      hand = game[:dealer][:hand]
      game[:dealer][:hand_value] = HandleCards.sum_hand_value(hand)

      if game[:dealer][:hand_value] > BUST
        game[:winner] = 'player'
        puts "#{'dealer'.colorize(:red)} BUST!\n\n"
        break
      elsif game[:dealer][:hand_value] >= 17
        break
      else
        hand << HandleCards.hit!(game[:deck])
      end
    end
  end
end
