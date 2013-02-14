#!/usr/bin/ruby

require_relative 'Canalyzer'
require_relative 'Cprocessing'
require 'socket'

# Instanciation d'un objet de type TCPserver
socket = TCPserver.open(20000)

loop do

# Creation d'un thread par connexion
  Thread.start(socket.accept) do |s|
    puts "#######################################"
    puts " --> #{s} is accepted\n"
    time = (Time.now.ctime)
    puts " --> Time : #{time}"
    
# Boucle permettant de récupérer et traiter les messages en provenance des clients
    while line = s.gets
      if line.chomp =~ /^\/exit/
        s.puts " --> Deconnexion OK"
        s.close
      else
        # puts line  # Il faudra appeler l'objet analyse ici.



        #line = "rt=A|relay=0|cmd=check_http|t=30|route=undef"

        o_analyzer = Canalyzer.new
        tab = o_analyzer.generate_tab( line )
        request_type = o_analyzer.search_rt( tab )
        relay = o_analyzer.search_relay ( tab )

        if relay == "1"
          puts " --> Receive request for RELAY"
        end


        ## LA FONCTION DE PROCESSING DU CHECK
        if relay == "0"
          puts " --> Receive request for ME"
          puts " --> Request : #{line}"
          o_processor = Cprocessing.new

          case request_type
          when "A"
          puts " --> It's a ACTIVE_CHECK request"
          puts " --> Exectute cmd"
          result = o_processor.active_check( tab )
          puts result
          s.puts result
          puts " --> Socket closed"
          puts "#######################################"
          s.close
          when "P"
          puts " --> It's a PASSIVE_CHECK request"
          puts " --> Writing event on nagios.cmd file"
          result = o_processor.passive_check( tab )
          puts result
          s.puts result
          s.close
          puts " --> Socket closed"
          puts "#######################################"
          end
        end
      end
    end
  end
end
