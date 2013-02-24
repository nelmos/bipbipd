#!/usr/bin/ruby

require_relative 'library/C_analyser'
require_relative 'library/C_processing'
require_relative 'library/C_log'
require 'colorize' #ruby gems : colorize
require 'socket'
require 'yaml'


#####################################
#      PROCEDURE DE DEMARRAGE       #
#####################################

# Instanciation des objets necessaire au demarrage
hash_config = Hash.new
log = C_log.new
config_file = 0
config_file_exist = 0

# 1°- Peuplement de hash_config avec les valeurs par defaut
hash_config["mode"] = "dual"
hash_config["path_config"] = "/etc/bipbipd/bipbipd.yaml"
hash_config["path_plugin"] = "/etc/bipbipd/plugins"
hash_config["path_log"] = "/var/log/bipbipd.log"
hash_config["listen_tcp_port"] = "5666"
hash_config["path_cmd_nagios"]="/usr/local/nagios/rw/nagios.cmd"
hash_config["verbose_lvl"]="0"

# 2°- Existe t'il un fichier un fichier de configuration ? 
# 2-1 : Recherche d'un eventuel fichier de configuration dans les arguments
ARGV.each do |element|
  if element =~ /-path_config/
      hash_config["path_config"] = element
  end
end
# 2-2 : Meme si aucun fichier n'a ete propose en argument, le hash est dispose deja d'un eventuel emplacement, celui peuple par defaut
#       Recuperation du chemin du fichier de configuration et test de l'existence du fichier
  if File.exist? (hash_config["path_config"])
    config_file_exist = 1
  end
puts "config_file_exist: #{config_file_exist}"
puts "config_file : #{hash_config["path_config"]}"  
# 2-3 : Si le fichier existe, ecupération des informations du fichier et peuplement du hash_config 
if config_file_exist.to_i == 1
### Recuperer les informations du fichier de configuration
  config = YAML.load_file(hash_config["path_config"])
  config.each do |x, y|
    if hash_config.has_key?(x)
      hash_config[x] = y
    end
  end
end

# 3° - Recupération des eventuels arguments et peupement du hash_config
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
  when /-v=/
    hash_config["verbose_lvl"] = value_arg
  end
end

# 5°- Log des informations de demarrage et lancement de
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], " \n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "  ** bipbipd - Version 0.4 - Cedrik MALLET **\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], " \n"


case hash_config["mode"]
when "a"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "  => bibbipd start in \"active\" mode with:\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_config : #{hash_config["path_config"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_log : #{hash_config["path_log"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_plugin : #{hash_config["path_plugin"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - tcp port : #{hash_config["listen_tcp_port"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - verbose_lvl : #{hash_config["verbose_lvl"]}\n"
when "p"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "  => bibbipd start in \"passive\" mode with:\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_config : #{hash_config["path_config"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_log : #{hash_config["path_log"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_cmd_nagios : #{hash_config["path_cmd_nagios"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - tcp port : #{hash_config["listen_tcp_port"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - verbose_lvl : #{hash_config["verbose_lvl"]}\n"
when "dual"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "  => bibbipd start in \"dual\" mode with:\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_config : #{hash_config["path_config"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_log : #{hash_config["path_log"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_cmd_nagios : #{hash_config["path_cmd_nagios"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - path_plugin : #{hash_config["path_plugin"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - tcp port : #{hash_config["listen_tcp_port"]}\n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    - verbose_lvl : #{hash_config["verbose_lvl"]}\n"
end

log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], " \n"
log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "  ** bipbipd started - Waiting connections... **\n"

#####################################
#     INSTANTIATION DU SOCKET       #
#####################################

# Instanciation d'un objet de type TCPserver
socket = TCPServer.new hash_config["listen_tcp_port"]

loop do

  #Creation d'un thread par connexion
  Thread.start(socket.accept) do |s|
    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], " \n"
    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ** New connection **\n"
    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => #{s} is accepted\n"
    time = (Time.now.ctime)
    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Time : #{time}\n"
    error_analyse = 0
    request_test = 0
 
    # Boucle permettant de récupérer et traiter les messages en provenance des clients
    while request = s.gets
      if request.chomp =~ /^\/exit/
        s.puts "Deconnexion OK"
        log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => Connection close by client"
        s.close
      else
        #####################################
        #      ANALYSE DE LA REQUETE        #
        #####################################

        #request = "-rt=a|-chk=check_ram.sh|-args=50!30|-rly=0|"
        #request = "-rt=p|-tsp=1348349172|-h=vm-test-01|-srv=cpu_load|-rc=2|-msg=Jai soif !"
        
        o_analyzer = C_analyser.new
        tab = o_analyzer.generate_tab( request )
        request_hash = o_analyzer.createHashRequest ( tab )
      	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "      => Request analysis : createHash\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => Request_type: #{request_hash["request_type"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => Check: #{request_hash["check_command"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => Args: #{request_hash["args"]}\n"
      	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => Relay: #{request_hash["relay"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => Road: #{request_hash["road"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => timestamp_passive: #{request_hash["timestamp_passive"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => Service: #{request_hash["service"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => hostname: #{request_hash["hostname"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => return_code: #{request_hash["return_code"]}\n"
    	log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "        => message: #{request_hash["message"]}\n"

        # Verification si la requete correspond au mode 
        request_test = o_analyzer.verifRequestType hash_config["mode"], request_hash["request_type"]
        if request_test.to_i == 1
       	  log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ERROR - Request_type:  \"#{request_hash["request_type"]}\" not supported by this server !\n".red
    	  log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => Error during request analysis. Request aborded\n".red
    	  log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ** Connexion closed by server **\n".red
          s.puts "=> ERROR - Request_type: \"#{request_hash["request_type"]}\" not supported by this server ! Connexion closed by server"
          error_analyse = "1"
          s.close
        end

        # En fonction du type de requete, appeler la bonne methode
        if error_analyse.to_i == 0
          if request_hash["request_type"] == "a"
      	    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Request analysis : verif_active\n"
    	    verifActive = o_analyzer.verif_active ( request_hash )
    	    if verifActive.length != 0
      	      verifActive.each do |element|
                log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "        => ERROR - \"#{element}\" not found\n".red
              end
      	      log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Error during request analysis. Request aborded\n".red
              s.puts "Error during request analysis. Request aborded\n"
              s.close
              error_analyse = '1'
              log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ** Connection closed **\n".red
    	    else
              log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "        => All params are found\n".green
            end
          elsif request_hash["request_type"] == "p"
      	    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Request analysis : verif_passive\n"
            verifPassive = o_analyzer.verif_passive ( request_hash )
	    if verifPassive.length != 0
      	      verifPassive.each do |element|
                log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "        => ERROR - \"#{element}\" not found\n".red
              end
      	      log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Error during request analysis. Request aborded\n".red
              s.puts "Error during request analysis. Request aborded\n"
              s.close
              error_analyse = '1'
              log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ** Connection closed **\n".red
    	    else
    	      log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "        => All params are found\n".green
            end
  	  end
        end

      	#####################################
	#     PROCESSING DE LA REQUETE      #
	#####################################
        if error_analyse.to_i == 0
	  o_processing = C_processing.new
	  if request_hash["request_type"] == "a"
            log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Request processing : check_active\n"
  	    result = o_processing.check_active hash_config, request_hash 
  	    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "        => Request result: #{result}\n".green
  	    s.puts result
            s.close
            log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ** Connection closed **\n"
	  else
	    log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "      => Request Processing : check_passive\n"
  	    result = o_processing.check_passive hash_config, request_hash
            log.logPush hash_config["verbose_lvl"], 1, hash_config["path_log"], "      => Request processing Successfull\n"
            s.puts "Event writted ! Bye\n"
    	    s.close
            log.logPush hash_config["verbose_lvl"], 0, hash_config["path_log"], "    => ** Connection closed **\n"
	  end
        end
      end
    end
  end
end
