require 'pry'
require 'progress_bar'
raw_data = File.read("test_data")

platform = raw_data.split("\n").map do |row|
  row.split('')
end

def tilt_row(row)
  stacks = []

  stack_counter = 0
  start_idx = 0

  row.each_with_index do |value, idx|
    if value == 'O'
      stack_counter += 1
    end

    if value == '#'
      stacks << [stack_counter, start_idx]

      stack_counter = 0
      start_idx = idx +1
    end
  end

  stacks << [stack_counter, start_idx] if stack_counter > 0

  row = row.map { |value| value == 'O' ? '.' : value}

  stacks.each do |stack|
    count, start_idx = stack

    (start_idx..start_idx + count - 1).each do |idx|
      row[idx] = 'O'
    end
  end

  row
end

def tilt(platform, direction)
  platform = platform.transpose if %i[up down].include?(direction)
  platform = platform.map(&:reverse) if %i[right down].include?(direction)

  new_platform = platform.map { |row| tilt_row(row) }

  new_platform = new_platform.map(&:reverse) if %i[right down].include?(direction)
  new_platform = new_platform.transpose if %i[up down].include?(direction)

  new_platform
end

def calculate_row(row)
  total = 0
  row.each_with_index do |value, index|
    next unless value == 'O'

    total += row.length - index
  end

  total
end


first_platform = platform.map { |row| row.dup }

res1 = tilt(first_platform, :up).transpose.map{ |row| calculate_row(row) }.sum
puts "First res is #{res1}"

second_platform = platform.map { |row| row.dup }

1000.times do
  second_platform = tilt(second_platform, :up)
  second_platform = tilt(second_platform, :left)
  second_platform = tilt(second_platform, :down)
  second_platform = tilt(second_platform, :right)
end


res2 = second_platform.transpose.map{ |row| calculate_row(row) }.sum
puts "Second res is #{res2}"