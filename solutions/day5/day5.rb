raw_data = File.read("test_data")

first, *rest = raw_data.split("\n")
_, raw_seeds = first.split(": ")

batches = []
current_batch = []

mapping_lines = rest.filter do |line|
  unless /\d/.match?(line)
    batches << current_batch

    current_batch = []

    next
  end

  current_batch << line
end
batches << current_batch
batches.reject!(&:empty?)

seeds_nums = raw_seeds.split(" ").map(&:to_i)

seeds_mapping = seeds_nums.map { |seed_id| [seed_id, seed_id] }.to_h

batches.each do |batch|
  new_mapping = seeds_mapping.dup

  batch.each do |line|
    destination_start, source_start, range_length = line.split(" ").map(&:to_i)

    seeds_mapping.each do |key, value|
      next unless value >= source_start && value < source_start + range_length

      source_diff = value - source_start
      new_mapping[key] = destination_start + source_diff
    end
  end

  seeds_mapping = new_mapping
end

first_answer = seeds_mapping.sort_by { |key, value| value }.first[1]

puts "First answer is #{first_answer}"

seeds_ranges = seeds_nums.
  each_slice(2).
  map { |range_start, range_length| [range_start, range_start + range_length - 1] }

batches.each do |batch|
  new_ranges = []

  ranges_left = seeds_ranges.dup

  batch.each do |line|
    destination_start, source_start, range_length = line.split(" ").map(&:to_i)

    unprocessed_ranges = []

    ranges_left.each do |min, max|
      source_finish = source_start + range_length - 1

      to_left = source_finish < min && source_start < min
      to_right = source_finish > max && source_start > max

      if to_left || to_right
        unprocessed_ranges << [min, max]

        next
      end

      slice_start = [source_start, min].max
      slice_finish = [source_finish, max].min

      slice_destination = destination_start + slice_start - source_start
      slice_destination_finish = slice_destination + slice_finish - slice_start

      new_ranges << [slice_destination, slice_destination_finish]

      rest_ranges =
        [[min, slice_start - 1], [slice_finish + 1, max]].
          reject { |sliced_min, sliced_max| sliced_min > sliced_max }

      rest_ranges.each { |sliced_range| unprocessed_ranges << sliced_range }
    end

    ranges_left = unprocessed_ranges
  end

  seeds_ranges = new_ranges + ranges_left
end


second_answer = seeds_ranges.map(&:min).min
puts "Second answer is #{second_answer}"

