#!/usr/bin/ruby

require_relative 'library/C_analyser'
require_relative 'library/C_processing'
require_relative 'library/C_log'
require 'colorize' #ruby gems : colorize
require 'socket'

#####################################
#      PROCEDURE DE DEMARRAGE       #
#####################################

# 1° Recherche des informations et mise en place dans hash_config
hash_config = Hash.new
ARGV.each do|element|
  value_arg = element.gsub(/^-[a-z_]+=/, "")
  case element
  when /-m=/
    hash_config["mode"]=value_arg
  when /-path_cfg=/
    hash_config["path_config"] = value_arg
  when /-path_plug=/
    hash_config["path_plugin"] = value_arg
  when /-path_log=/
    hash_config["path_log"] = value_arg
  when /-path_cmd=/
    hash_config["path_cmd_nagios"] = value_arg
  when /-ptcp=/
    hash_config["listen_tcp_port"] = value_arg
  when /-debug=/
    hash_config["debug"] = value_arg
  end
end

log = C_log.new

# 2° Mise en place des informations par defaut si manquantes
puts ""
puts "bipbipd - Version 0.2 - Cedrik MALLET"
puts ""
puts "  => Analysing start parameters :".blue
puts ""
puts ""
puts "  => Analysing start parameters :".blue
if !hash_config.has_key? "mode"
  hash_config["mode"]="dual"
  puts "    => \"mode\" not set ! Set \"dual\" by default"
else
  puts "    => \"mode\" set to #{hash_config["mode"]}"
end
if !hash_config.has_key? "debug"
  hash_config["debug"]="0"
  puts "    => \"debug\" not set ! Set \"0\" by default"
else
  puts "    => \"debug\" set to #{hash_config["debug"]}"
end
if !hash_config.has_key? "path_config"
  hash_config["path_config"]="/etc/bibipd/bipbipd.cfg"
  puts "    => \"path_config\" not set ! Set \"/etc/bipbipd/bipbipd.cfg\" by default"
else
  puts "    => \"path_config\" set to #{hash_config["path_config"]}"
end
if !hash_config.has_key? "path_log"
  hash_config["path_log"]="/var/log/bipbipd.log/"
  puts "    => \"path_log\" not set ! Set \"/var/log/bipbipd.log/\" by default"
else
  puts "    => \"path_log\" set to #{hash_config["path_log"]}"
end

case hash_config["mode"]
when "active"
  if !hash_config.has_key? "path_plugin"
    hash_config["path_plugin"]="/etc/bipbipd/plugins"
    puts "    => \"path_plugin\" not set ! Set \"/etc/bipbipd/plugins\" by default"
  else
    puts "    => \"path_plugin\" set to #{hash_config["path_config"]}"
  end
  if !hash_config.has_key? "listen_tcp_port"
    hash_config["listen_tcp_port"]="5666"
    puts "    => \"listen_tcp_port\" not set ! Set \"5666\" by default"
  else
    puts "    => \"listen_tcp_port\" set to #{hash_config["listen_tcp_port"]}"
  end

when "passive"
  if !hash_config.has_key? "path_cmd_nagios"
    hash_config["path_cmd_nagios"]="/usr/local/nagios/rw/nagios.cmd"
    puts "    => \"path_cmd_nagios\" not set ! Set \"...\" by default"
  else
    puts "    => \"path_cmd_nagios\" set to #{hash_config["path_cmd_nagios"]}"
  end
  if !hash_config.has_key? "listen_tcp_port"
    hash_config["listen_tcp_port"]="5666"
    puts "    => \"listen_tcp_port\" not set ! Set \"5666\" by default"
  else
    puts "    => \"listen_tcp_port\" set to #{hash_config["listen_tcp_port"]}"
  end
else
  if !hash_config.has_key? "path_plugin"
    hash_config["path_plugin"]="/etc/bipbipd/plugins"
    puts "    => \"path_plugin\" not set ! Set \"/etc/bipbipd/plugins\" by default"
  else
    puts "    => \"path_plugin\" set to #{hash_config["path_config"]}"
  end
  if !hash_config.has_key? "path_cmd_nagios"
    hash_config["path_cmd_nagios"]="/usr/local/nagios/rw/nagios.cmd"
    puts "    => \"path_cmd_nagios\" not set ! Set \"...\" by default"
  else
    puts "    => \"path_cmd_nagios\" set to #{hash_config["path_cmd_nagios"]}"
  end
  if !hash_config.has_key? "listen_tcp_port"
    hash_config["listen_tcp_port"]="5666"
    puts "    => \"listen_tcp_port\" not set ! Set \"5666\" by default"
  else
    puts "    => \"listen_tcp_port\" set to #{hash_config["listen_tcp_port"]}"
  end
end

puts ""
puts "  => bipbipd started - Waiting connections".blue

#####################################
#     INSTANTIATION DU SOCKET       #
#####################################

# Instanciation d'un objet de type TCPserver
socket = TCPServer.new hash_config["listen_tcp_port"]

loop do

  #Creation d'un thread par connexion
  Thread.start(socket.accept) do |s|
    log.logPush hash_config["debug"], 0, hash_config["path_log"], " \n"
    log.logPush hash_config["debug"], 0, hash_config["path_log"], "    => ** New connection **\n"
    log.logPush hash_config["debug"], 0, hash_config["path_log"], ""
    log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => #{s} is accepted\n"
    time = (Time.now.ctime)
    log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Time : #{time}\n"

    # Boucle permettant de récupérer et traiter les messages en provenance des clients
    while request = s.gets
      if request.chomp =~ /^\/exit/
        s.puts "Deconnexion OK"
        log.logPush hash_config["debug"], 0, hash_config["path_log"], "    => Connection close by client"
        s.close
      else
        #####################################
        #      ANALYSE DE LA REQUETE        #
        #####################################

        #  request = "-rt=active|-chk=check_ram.sh|-args=50!30|-rly=0|"
        #request = "-rt=passive|-tsp=1348349172|-h=vm-test-01|-srv=cpu_load|-rc=2|-msg=Jai soif !"
        
        o_analyzer = C_analyser.new
        tab = o_analyzer.generate_tab( request )
        request_hash = o_analyzer.createHashRequest ( tab )
      	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "      => Request analysis : createHash\n".blue
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => Request_type: #{request_hash["request_type"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => Check: #{request_hash["check_command"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => Args: #{request_hash["args"]}\n"
      	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => Relay: #{request_hash["relay"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => Road: #{request_hash["road"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => timestamp_passive: #{request_hash["timestamp_passive"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => Service: #{request_hash["service"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => hostname: #{request_hash["hostname"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => return_code: #{request_hash["return_code"]}\n"
    	  log.logPush hash_config["debug"], 1, hash_config["path_log"], "        => message: #{request_hash["message"]}\n"
 
        error_analyse = '0'
        # En fonction du type de requete, appeler la bonne methode
        if request_hash["request_type"] == "active"
      	  log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Request analysis : verif_active\n".blue
    	  verifActive = o_analyzer.verif_active ( request_hash )
    	  if verifActive.length != 0
      	    verifActive.each do |element|
              log.logPush hash_config["debug"], 0, hash_config["path_log"], "        => ERROR - \"#{element}\" not found\n".red
            end
      	    log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Error during request analysis. Request aborded\n".red
            s.puts "Error during request analysis. Request aborded\n"
            s.close
            error_analyse = '1'
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "    => ** Connection closed **\n".red
    	  else
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "        => All params are found\n".green
          end
        elsif request_hash["request_type"] == "passive"
      	  log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Request analysis : verif_passive\n".blue
    	  verifPassive = o_analyzer.verif_passive ( request_hash )
    	  if verifPassive.length != 0
      	    verifPassive.each do |element|
              log.logPush hash_config["debug"], 0, hash_config["path_log"], "        => ERROR - \"#{element}\" not found\n".red
            end
      	    log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Error during request analysis. Request aborded\n".red
            s.puts "Error during request analysis. Request aborded\n"
            s.close
            error_analyse = '1'
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "    => ** Connection closed **\n".red
    	  else
            puts "        => All params are found\n".green
    	  end
  	end


      	#####################################
	#     PROCESSING DE LA REQUETE      #
	#####################################
        if error_analyse == '0'
	  o_processing = C_processing.new
	  if request_hash["request_type"] == "active"
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Request processing : check_active\n".blue
  	    result = o_processing.check_active hash_config, request_hash 
  	    log.logPush hash_config["debug"], 0, hash_config["path_log"], "        => Request result: #{result}\n".green
  	    s.puts result
            s.close
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "    => ** Connection closed **\n"
	  else
  	    result = o_processing.check_passive hash_config, request_hash
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "      => Request processing : check_passive\n".blue
  	    log.logPush hash_config["debug"], 0, hash_config["path_log"], "        => Request result: #{result}\n".green
            s.puts "Event writted ! Bye\n"
    	    s.close
            log.logPush hash_config["debug"], 0, hash_config["path_log"], "    => ** Connection closed **\n"
	  end
        end
      end
    end
  end
end
