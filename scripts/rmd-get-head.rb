#!/usr/bin/env ruby

raise "malformed args. Usage ... in-file out-file" if ARGV.length != 2

in_file = ARGV[0]
out_file = ARGV[1]


input = File.read(in_file)

output = File.open(out_file, "w")

m = (/<head>(.+)<\/head>/im).match(input)

raise "malformed input file #{in_file}" if m.nil?

raw_head = m[1]

clean_head = raw_head.gsub(/<title>.+<\/title>/, "")
               .gsub(/<meta [^>]+ \/>/, "")
output.write(clean_head)
