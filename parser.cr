require "./src/parser"

content = ""
if ARGV.size > 0
  if File.exists?(ARGV.first)
    content = File.read(ARGV.first)
  else
    content = ARGV.first
  end
else
  gets.try do |value|
    content = value
  end
end
puts OrgMob::Parser.new.parse(content)
