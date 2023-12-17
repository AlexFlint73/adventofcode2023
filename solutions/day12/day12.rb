require 'pry'

raw_data = File.read("test_data")
raw_rows = raw_data.split("\n")

def count_left_springs(springs, counts, cache = {})
  if counts.empty?
    return springs.include?('#') ? 0 : 1
  end

  if springs.length < counts.sum + counts.length - 1
    return 0 # not enough space to fit pattern
  end

  if cache.dig(springs.length, counts.length)
    return cache.dig(springs.length, counts.length)
  end

  total = 0

  if springs[0] != '#'
    total += count_left_springs(springs[1..-1], counts, cache)
  end

  current_count = counts[0]

  if !springs[0...current_count].include?('.') && springs[current_count] != '#'
    total += count_left_springs(springs[current_count + 1..-1] || [], counts[1..-1] || [], cache)
  end

  cache[springs.length] ||= {}
  cache[springs.length][counts.length] = total

  total
end



total_counter = 0

raw_rows.each do |raw_row|
  raw_springs, raw_counts = raw_row.split(' ')

  springs = raw_springs.split('')
  counts = raw_counts.split(',').map(&:to_i)

  total_counter += count_left_springs(springs, counts)
end

puts "First answer is #{total_counter}"

total_counter = 0
raw_rows.each do |raw_row|
  raw_springs, raw_counts = raw_row.split(' ')

  springs = ((raw_springs.split('') + ['?']) * 5)[0..-2]
  counts = raw_counts.split(',').map(&:to_i) * 5

  current_counter = count_left_springs(springs, counts)

  total_counter += current_counter
end

puts "Second answer is #{total_counter}"
