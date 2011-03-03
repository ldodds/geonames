require 'rubygems'
require 'rdf'
require 'rdf/raptor'

#Script accepts to parameters on the command-line:
#
# The name of the geonames RDF export
# The name of the ntriples file to generate
#
# ruby convert.rb all-geonames-rdf.txt geonames.nt

puts "Reading source data from #{ARGV[0]}"
puts "Writing ntriples to #{ARGV[1]}"

count = 0
skipped = 0

#Convert data into ntriples
File.open(ARGV[1], "w") do |f|

  writer = RDF::NTriples::Writer.new( f )
  
  uri = ""
  File.open(ARGV[0], "r").each do |line|
    count = count + 1    
    if count % 2 == 0
      #FIXME reserializing to work around bug in rdf-raptor
      File.open("/tmp/data.rdf", "w") do |tmp|
        tmp.puts line
      end
      begin
        RDF::Reader.open("/tmp/data.rdf") do |reader|
          reader.each_statement do |statement|
            writer << statement
          end
        end
      rescue => e
        puts "Unable to parse RDF for #{uri}"
        skipped = skipped + 1
        puts e
      end
    else
      uri = line
    end
    puts "Processed #{count} documents" if count % 100000 == 0
  end
  
end

puts "Completed #{count} documents. #{skipped} documents were ignored due to parse errors"