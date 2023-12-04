# Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
# Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
# Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
# Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
# Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
# Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

raw_data = File.read("test_data")

sum = 0

raw_data.split("\n") do |raw_row|
  _, card_info = raw_row.split(": ")

  winning_nums, actual_nums = card_info.split(" | ").map { |string| string.split(" ") }

  match_nums = winning_nums & actual_nums

  next if match_nums.length == 0

  sum += 2 ** (match_nums.length - 1)
end


puts "First answer: #{sum}"


sum = 0
copies_stack = []

raw_data.split("\n") do |raw_row|
  _, card_info = raw_row.split(": ")

  winning_nums, actual_nums = card_info.split(" | ").map { |string| string.split(" ") }

  match_nums = winning_nums & actual_nums

  cards_won = 1

  copies_stack.each do |copy_memo|
    cards_won += copy_memo[:copies]
    copy_memo[:left] -= 1
  end

  copies_stack.select! do |copy_memo|
    copy_memo[:left] > 0
  end

  if match_nums.length > 0
    copies_stack << {
      copies: cards_won,
      left: match_nums.length
    }
  end

  sum += cards_won
end

puts "Second Answer: #{sum}"