def find_next(array)
  differences = array.each_cons(2).map { |a, b| b - a }

  diff = differences.uniq.count == 1 ? differences.first : find_next(differences)

  array[-1] + diff
end

def find_first(array)
  differences = array.each_cons(2).map { |a, b| b - a }

  diff = differences.uniq.count == 1 ? differences.first : find_first(differences)

  array[0] - diff
end

raw_data = File.read("test_data")

sequences = raw_data.split("\n").map { |row| row.split(' ').map(&:to_i) }

first_answer = sequences.map { |sequence| find_next(sequence) }.reduce(:+)

puts "First answer is #{first_answer}"

second_answer = sequences.map { |sequence| find_first(sequence) }.reduce(:+)

puts "Second answer is #{second_answer}"

