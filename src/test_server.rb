require 'socket'

cfg = 'config.txt'
cfgs = {}

# Read configuration
if File.exists?(cfg)
	
	File.open(cfg, 'r') do |f| 
		f.readlines.each do |line|
			cfgs[line.split('=')[0]] = line.split('=')[1]
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
