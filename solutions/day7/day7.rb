TYPE_PRIORITIES = [
  [5], # Five of a kind
  [4, 1], # Four of a kind
  [3, 2], # Full house
  [3, 1, 1], # Three of a kind
  [2, 2, 1], # Two pair
  [2, 1, 1, 1], # One pair
  [1, 1, 1, 1, 1], # High card
]

CARD_PRIORITY = %w[A K Q J T 9 8 7 6 5 4 3 2]

raw_data = File.read("test_data")

rows = raw_data.split("\n")

sorted_hands = rows.map do |row|
  hand, bid = row.split(" ")
  hand_cards = hand.split('')

  hand_type = hand_cards.tally.values.sort.reverse
  hand_type_priority = TYPE_PRIORITIES.index(hand_type) + 1
  hand_cards_priorities = hand_cards.map { |card| CARD_PRIORITY.index(card) + 10 } # Ensure all values are 2 digit

  total_priority = [hand_type_priority, *hand_cards_priorities].join.to_i

  [hand, total_priority, bid.to_i]
end

total = 0

sorted_hands.sort_by { |sorted_hand| sorted_hand[1] }.reverse.each.with_index(1) do |hand, index|
  total += hand[2] * index
end

puts "First result is #{total}"

NEW_CARD_PRIORITY = %w[A K Q T 9 8 7 6 5 4 3 2 J]

sorted_hands = rows.map do |row|
  hand, bid = row.split(" ")
  hand_cards = hand.split('')

  sorted_cards = hand_cards.tally.sort_by { |card, count| [card == 'J' ? 1 : 0, 5 - count, NEW_CARD_PRIORITY.index(card)] }

  hand_cards_with_joker_applied = hand_cards.map do |card|
    next sorted_cards[0][0] if card == 'J'

    card
  end

  hand_type = hand_cards_with_joker_applied.tally.values.sort.reverse

  hand_type_priority = TYPE_PRIORITIES.index(hand_type) + 1
  hand_cards_priorities = hand_cards.map { |card| NEW_CARD_PRIORITY.index(card) + 10 } # Ensure all values are 2 digit

  total_priority = [hand_type_priority, *hand_cards_priorities].join.to_i

  [hand, total_priority, bid.to_i]
rescue
  pp hand_cards_with_joker_applied
  raise
end

total = 0

sorted_hands.sort_by { |sorted_hand| sorted_hand[1] }.reverse.each.with_index(1) do |hand, index|
  total += hand[2] * index
end

puts "Second answer is #{total}"