# frozen_string_literal: true

Then(/^the example(s)? should( all)? pass$/) do |_, _|
  puts all_output
  step 'the output should contain "0 failures"'
  step 'the exit status should be 0'
end

Then(/^the example(s)? should( all)? fail$/) do |_, _|
  step 'the exit status should be 1'
end

Then(/^the output should contain (failures|these lines):$/) do |_, lines|
  out = all_output.dup
  lines.split(/\n/).map(&:strip).each do |line|
    next if line.blank?

    expect(out).to match(/#{Regexp.escape(line)}/)
    out.gsub!(/.*?#{Regexp.escape(line)}/m, '')
  end
end

Then('a yaml named {string} should contain:') do |file, expected_content|
  file_content = YAML.load_file(expand_path(file))
  content = YAML.safe_load(expected_content)

  expect(file_content).to eq(content)
end
