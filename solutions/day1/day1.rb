# Before all

data = File.read("test_data")

# First part

data.split("\n").map { |line| numbers = line.split('').map(&:to_i).reject(&:zero?); [numbers.first, numbers.last].join.to_i }.reduce(:+)

# Second part

MAPPINGS = {
  "one" => 1,
  "two" => 2,
  "three" => 3,
  "four" => 4,
  "five" => 5,
  "six" => 6,
  "seven" => 7,
  "eight" => 8,
  "nine" => 9
}

data.split("\n").map { |line| numbers = line.gsub(Regexp.new(MAPPINGS.keys.join("|")), MAPPINGS).split('').map(&:to_i).reject(&:zero?); [numbers.first, numbers.last].join.to_i }.reduce(:+)
