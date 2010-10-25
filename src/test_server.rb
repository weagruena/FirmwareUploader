require 'socket'

# Exit while compiling
exit if Object.const_defined?(:Ocra)

cfg = 'config.txt'
cfgs = {}

# Read configuration
if File.exists?(cfg)
	
	File.open(cfg, 'r') do |f| 
		f.readlines.each do |line|
			if line[0..1] != "# "
				cfgs[line.split('=')[0]] = line.split('=')[1]
			end	
		end	
	end
	server = cfgs['server'].chomp
	port = cfgs['port'].chomp
	file = cfgs['file'].chomp	
	
end

ncs = TCPServer.new(server, port)
puts "Server started."
loop do
  puts "Server waiting ..."   
	Thread.start(ncs.accept) do |client|
		data = client.read
		File.open(file+".new", "wb") do |f|
			f.puts data
		end
	end
	puts "File: #{file} received + created."  	
end
puts "Server closed."
