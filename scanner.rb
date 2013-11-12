require 'socket'

HOST = '0.0.0.0'
PORT_RANGE = 7600..8000
TIME_TO_WAIT = 5

PORT_RANGE.map do |port|
    socket = Socket.new :INET, :STREAM
    remote_addr = Socket.pack_sockaddr_in(port, HOST)
    
    begin
        socket.connect_nonblock remote_addr
    rescue Errno::EINPROGRESS
        _, writable, _ = IO.select(nil, [socket], nil, 0.5)
        next unless writable
        s = writable[0]

        begin
            s.connect_nonblock s.remote_address
        rescue Errno::EINVAL
            puts "#{HOST}:#{port} not accepts connections..."
            next
        rescue Errno::EISCONN
            p "#{HOST}:#{s.remote_address.ip_port} accepts connections..."
        end
    rescue Errno::ECONNREFUSED
        next
    rescue Errno::EINVAL
        puts "#{HOST}:#{port} not accepts connections..."
        next
    end
end