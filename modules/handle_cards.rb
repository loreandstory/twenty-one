module HandleCards
  def self.make_and_shuffle_deck
    face_cards = ['A', 'K', 'Q', 'J']
    numbered_cards = ('2'..'10').to_a

    deck = (face_cards + numbered_cards) * 4

    deck.shuffle!
  end

  def self.face_card?(card)
    card.match?(/[AKQJ]/)
  end

  def self.ace?(card)
    card.match?('A')
  end

  def self.number_card_to_value(card)
    card.to_i
  end

  def self.find_card_order_value(card)
    face_order_value = {
      'A' => 14, 'K' => 13,
      'Q' => 12, 'J' => 11
    }

    if face_card?(card)
      face_order_value[card]
    else
      number_card_to_value(card)
    end
  end

  def self.sort_hand(hand)
    hand.sort do |card1, card2|
      if card1.match(/m([A,K,Q,J,0-9]+)/)
        card1 = card1.match(/m([A,K,Q,J,0-9]+)/)[1]
      end

      if card2.match(/m([A,K,Q,J,0-9]+)/)
        card2 = card2.match(/m([A,K,Q,J,0-9]+)/)[1]
      end

      card1_order_val = find_card_order_value(card1)
      card2_order_val = find_card_order_value(card2)

      card1_order_val <=> card2_order_val
    end
  end

  def self.decide_face_card_value(face_card, current_sum)
    if ace?(face_card)
      # as ace can be either 1 or 11
      current_sum + 11 > BUST ? 1 : 11
    else
      # as all other face cards have value = 10
      10
    end
  end

  def self.sum_hand_value(hand)
    sorted_hand = sort_hand(hand)

    sorted_hand.reduce(0) do |sum, card|
      card_value = if face_card?(card)
                     decide_face_card_value(card, sum)
                   else
                     number_card_to_value(card)
                   end

      sum + card_value
    end
  end

  def self.hit!(deck)
    deck.pop
  end
end
