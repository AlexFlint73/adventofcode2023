raw_data = File.read("test_data")

y_expansions = []
map = raw_data.split("\n").map.with_index do |raw_row, y|
  row = raw_row.split("")

  y_expansions << y if row.uniq.count == 1

  row
end

max_col_idx = map.first.length - 1

x_expansions = []
max_col_idx.downto(0).each do |idx|
  next unless map.all? { |row| row[idx] == '.' }

  x_expansions << idx
end


positions = {}
current_star_idx = 1

map.each_with_index do |row, y|
  row.each_with_index do |value, x|
    next if value == '.'

    positions[current_star_idx] = [x, y]
    current_star_idx += 1
  end
end

expansion_ratio = 2

distances = positions.keys.permutation(2).map(&:sort).uniq.to_a.map do |star_a, star_b|
  ax, ay = positions[star_a]
  bx, by = positions[star_b]

  exp_ax = ax + x_expansions.select { |exp_x| exp_x < ax }.count * (expansion_ratio - 1)
  exp_ay = ay + y_expansions.select { |exp_y| exp_y < ay }.count * (expansion_ratio - 1)
  exp_bx = bx + x_expansions.select { |exp_x| exp_x < bx }.count * (expansion_ratio - 1)
  exp_by = by + y_expansions.select { |exp_y| exp_y < by }.count * (expansion_ratio - 1)

  (exp_bx - exp_ax).abs + (exp_by - exp_ay).abs
end

res1 = distances.sum

puts "Fist answer is #{res1}"


expansion_ratio = 1_000_000

distances = positions.keys.permutation(2).map(&:sort).uniq.to_a.map do |star_a, star_b|
  ax, ay = positions[star_a]
  bx, by = positions[star_b]

  exp_ax = ax + x_expansions.select { |exp_x| exp_x < ax }.count * (expansion_ratio - 1)
  exp_ay = ay + y_expansions.select { |exp_y| exp_y < ay }.count * (expansion_ratio - 1)
  exp_bx = bx + x_expansions.select { |exp_x| exp_x < bx }.count * (expansion_ratio - 1)
  exp_by = by + y_expansions.select { |exp_y| exp_y < by }.count * (expansion_ratio - 1)

  (exp_bx - exp_ax).abs + (exp_by - exp_ay).abs
end

res2 = distances.sum

puts "Second answer is #{res2}"