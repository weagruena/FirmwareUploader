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
	
else
	
	if ARGV.length == 3
		server = ARGV[0].chomp
		port = ARGV[1].chomp
		file = ARGV[2].chomp
	else
		puts "Configuration or arguments (server, port, file) missing !!!"
		exit
	end
	
end

# Start connection
begin

	client = TCPSocket.open(server, port)
	puts "Socket open to #{server}:#{port}."
	
	if File.exists?(file)
		File.open(file, 'rb') do |f1|
			@content = f1.read		
		end
		# Send file
		client.puts(@content)
		puts "File: #{} sended to #{server}:#{port}."
	end
	
rescue
	puts "No connection to #{server}:#{port} !!!\nExit."
else
	# Close connection
	client.close
	puts "Socket closed."
end
