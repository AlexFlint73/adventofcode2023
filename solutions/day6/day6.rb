def solve(races)
  nums = []

  races.each do |time, distance|
    # x^2 - time * x + distance = 0

    d = time ** 2 - 4 * distance

    if d > 0
      start_val = (time - Math.sqrt(d)) / 2
      end_val = (time + Math.sqrt(d)) / 2

      start_val = start_val.ceil == start_val ? (start_val + 1).round : start_val.ceil
      end_val = end_val.floor == end_val ? (end_val - 1).round : end_val.floor

      num = end_val - start_val + 1
    else
      num = 0
    end

    nums << num
  end

  nums.reduce(:*)
end

races = [
  [58, 478],
  [99, 2232],
  [64, 1019],
  [69, 1071]
]

puts "First answer: #{solve(races)}"

races = [[58996469, 478223210191071]]

puts "Second answer: #{solve(races)}"


