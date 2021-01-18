def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns)
  record_arr = []
  dns_map = {}
  dns.
    reject { |record| !(!record.start_with?("#") && record.strip.length > 0) }.
    map { |record| record.split(",").map { |item| item.strip } }.
    each { |record|
    dns_map[record[1]] = {
      :type => record[0],
      :destination => record[2],
    }
  }
  dns_map
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records[domain]
    type = dns_records[domain][:type]
    if type == "CNAME"
      lookup_chain.concat([dns_records[domain][:destination]])
      resolve(dns_records, lookup_chain, dns_records[domain][:destination])
    elsif type == "A"
      lookup_chain.concat([dns_records[domain][:destination]])
    else
      lookup_chain.concat("Unknow record type \"#{type}\"")
    end
  else
    puts "Error: record not found for #{domain}"
    return []
  end
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
