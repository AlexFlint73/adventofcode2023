require 'pry'

raw_data = File.read("test_data")
raw_patterns = raw_data.split("\n\n")

INVERSE = {
  '.' => '#',
  '#' => '.'
}

def distance(left, right)
  total = 0

  left.each_with_index do |left_val, idx|
    next if left_val == right[idx]

    total += 1
  end

  total
end


def solve_pattern(pattern, search_distance = 0)
  symmetry_num = 0

  max_x_idx = pattern.first.length - 1
  max_y_idx = pattern.length - 1

  rotated_pattern = pattern.transpose

  (0..max_y_idx).each do |y_idx|
    top, bottom = pattern[0..y_idx], pattern[y_idx + 1..-1]

    next if [top, bottom].any?(&:empty?)

    comparable_length = [top.length, bottom.length].min

    comparable_top = top.last(comparable_length).reverse
    comparable_bottom = bottom.first(comparable_length)

    distance = (0..comparable_top.length - 1).map do |idx|
      distance(comparable_top[idx], comparable_bottom[idx])
    end.sum

    next unless distance == search_distance

    symmetry_num = (y_idx + 1) * 100
  end

  return symmetry_num if symmetry_num.positive?

  (0..max_x_idx).each do |x_idx|
    top = rotated_pattern[0..x_idx]
    bottom = rotated_pattern[x_idx + 1..-1]

    next if [top, bottom].any?(&:empty?)

    comparable_length = [top.length, bottom.length].min

    comparable_top = top.last(comparable_length).reverse
    comparable_bottom = bottom.first(comparable_length)

    distance = (0..comparable_top.length - 1).map do |idx|
      distance(comparable_top[idx], comparable_bottom[idx])
    end.sum

    next unless distance == search_distance

    symmetry_num = x_idx + 1
  end

  symmetry_num
end

def dup_pattern(pattern)
  pattern.map { |row| row.dup }
end

def pattern_variations(pattern)
  new_patterns = []

  pattern.each_with_index do |row, y|
    row.each_index do |x|
      new_pattern = dup_pattern(pattern)
      new_pattern[y][x] = INVERSE[new_pattern[y][x]]

      new_patterns << new_pattern
    end
  end

  new_patterns
end

total1 = 0
total2 = 0

raw_patterns.each do |raw_pattern|
  pattern = raw_pattern.split("\n").map do |row|
    row.split('')
  end

  res1 = solve_pattern(pattern)
  res2 = solve_pattern(pattern, 1)

  total1 += res1
  total2 += res2
end

puts "First answer is #{total1}"
puts "Second answer is #{total2}"




