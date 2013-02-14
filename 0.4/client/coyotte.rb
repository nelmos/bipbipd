#!/usr/bin/ruby

require 'socket'

################
#  COYOTTE 0.1 #
################

################################
##### Fonction collection  #####
################################

def check_active ( hash )
  @hash_config = hash
  @tab_error = Array.new
  if !@hash_config.has_key? "host"
    @tab_error.push('host')
  end
  if !@hash_config.has_key? "cmd"
    @tab_error.push('cmd')
  end
  if !@hash_config.has_key? "args"
    @tab_error.push('args')
  end
  return @tab_error
end

def check_passive ( hash )
  @hash_config = hash
  @tab_error = Array.new

   if !@hash_config.has_key? "notified_service"
    @tab_error.push('notified_service')
  end
  if !@hash_config.has_key? "notified_host"
    @tab_error.push('notified_host')
  end
  if !@hash_config.has_key? "for_type"
    @tab_error.push ('for')
  end
  if !@hash_config.has_key? "return_code"
    @tab_error.('return_code')
  end
  if !@hash_config.has_key? "message"
    @tab_error.('message')
  end
  return @tab_error
end

def create_active ( hash )
  @hash_config = hash
  if @hash_config["mode"] == "wrapper"
  #appel de la fonction wrapper
  # 
  else
    @request = "-rt=#{@hash_config["rt"]}|-chk=#{@hash_config["cmd"]}|-args=#{@hash_config["args"]}|-tmo=#{@hash_config["timeout"]}"
    return @request
  end
end

def create_passive ( hash )
  @hash_config = hash
end

def wrapper_search()
end

def request_push ( request, host, port )
  @request = request
  @host = host
  @port = port
  socket = TCPSocket.open(@host, @port)
  socket.puts "#{@request}"
  while line = socket.gets
    puts line
  end
  socket.close

  # ajouter ici le code pour ouvrir la connexion
end

##########################
######### BEGIN ##########
##########################


# Instanciation des objets necessaire au demarrage
hash_config = Hash.new

# 1°- Peuplement de hash_config avec les valeurs par defaut
hash_config["rt"] = "active"
hash_config["mode"] = "standalone"
hash_config["timeout"] = "30"
hash_config["port"] = "5666"

# Recherche d'eventuels arguments de configuration passé en parametre et override des key si necessaire
ARGV.each do|element|
  value_arg = element.gsub(/^-[a-z_]+=/, "")
  case element
  when /-rt=/
    hash_config["rt"]= value_arg
  when /-m=/
    hash_config["mode"] = value_arg
  when /-t=/
    hash_config["timeout"] = value_arg
  when /-p=/
    hash_config["port"] = value_arg
  when /-h=/
    hash_config["host"]= value_arg
  when /-c=/
    hash_config["cmd"] = value_arg
  when /-a=/
    hash_config["args"] = value_arg
  when /-nsrv=/
    hash_config["notified_service"] = value_arg
  when /-nhost=/
    hash_config["notified_host"] = value_arg
  when /-for=/
    hash_config["for_type"]= value_arg
  when /-rc=/
    hash_config["return_code"] = value_arg
  when /-msg=/
    hash_config["message"] = value_arg
  end
end


# RT ?
if hash_config["rt"] == "active"
  verifActive = check_active ( hash_config )
  if verifActive.length != 0
    verifActive.each do |element|
      puts "\"#{element}\" not defined"
    end
    exit 1
  end
  request = create_active ( hash_config )
  request_push request, hash_config["host"], hash_config["port"]
else 
end
