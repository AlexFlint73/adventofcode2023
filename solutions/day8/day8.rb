raw_data = File.read("test_data")

instructions, map_string = raw_data.split("\n\n")

map = map_string.split("\n").each_with_object({}) do |instruction_string, memo|
  location, left, right = instruction_string.scan(/\w+/)

  memo[location] = { 'L' => left, 'R' => right }
end


current_location = 'AAA'
steps = 0

loop do
  instruction_index = steps % instructions.length

  steps += 1
  current_location = map[current_location][instructions[instruction_index]]

  break if current_location == 'ZZZ'
end

puts "First answer is #{steps}"

current_locations = map.keys.select { |location| location[-1] == 'A' }

individual_solutions = current_locations.map do |start_loc|
  current_location = start_loc
  steps = 0

  loop do
    instruction_index = steps % instructions.length

    steps += 1
    current_location = map[current_location][instructions[instruction_index]]

    break if current_location[-1] == 'Z'
  end

  steps
end

second_answer = individual_solutions.reduce { |lcm, value| lcm.lcm(value) }

puts "Second answer is #{second_answer}"