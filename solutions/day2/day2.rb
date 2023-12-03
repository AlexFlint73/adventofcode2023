# Preparation

raw_data = File.read('test_data')

games_data = raw_data.split("\n").map do |row|
  raw_id, raw_input = row.split(": ")
  id = raw_id.match(/\d+/)[0].to_i

  attempt_strings = raw_input.split("; ")

  max_counts_during_game = {}

  attempt_strings.each do |attempt_string|
    attempt_string.split(", ").each do |color_result|
      raw_count, color = color_result.split(" ")
      count = raw_count.to_i

      next if max_counts_during_game[color].to_i > count

      max_counts_during_game[color] = count
    end
  end

  [id, max_counts_during_game]
end;


# First part
game_limitation = { 'red' => 12, 'green' => 13, 'blue' => 14 }

ids_sum = 0
games_data.each do |id, game_data|
  puts "ID: #{id}, game_data: #{game_data}"
  next if game_limitation.any? { |color, count| game_data[color] > count }

  ids_sum = ids_sum + id
end;
ids_sum


## Second part 

games_data.map do |_, game_data|
  game_data.values.reduce(&:*)
end.reduce(&:+)
