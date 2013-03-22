class C_analyser
  # Genere un tableau depuis la commande en entree
  def generate_tab ( chaine )
    @chaine = chaine
    @tab_generate = @chaine.split('|')
    return @tab_generate
  end

  def verifRequestType (mode, request_type)
    @mode = mode
    @request_type = request_type
    case @mode
    when "a"
      if @request_type != "a"
        return 1
      else
        return 0
      end
    when "p"
      if @request_type != "p"
        return 1
      else
        return 0
      end
    when "dual"
      if @request_type == "p"
        return 0
      elsif @request_type == "a"
        return 0
      else
        return 1
      end
    else             # Si request_type n'est pas active|passive|dual
      return 1
    end
  end 

  def createHashRequest ( tab )
    @tab_temp = tab
    @request_hash = Hash.new
    @tab_temp.each do |element|
      if element =~ /-rt=/  #|| /request_type=/)
        @request_hash["request_type"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-chk=/
        @request_hash["check_command"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-args=/
        @request_hash["args"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-rly=/
        @request_hash["relay"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-road=/
        @request_hash["road"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-tmo=/
        @request_hash["time_out"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-ntype=/
        @request_hash["notified_type"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-nserv=/
        @request_hash["notified_service"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-nhost=/
        @request_hash["notified_host"] = element.gsub(/^-[a-z]+=/, "") 
      elsif element =~ /-rc=/
        @request_hash["return_code"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-msg=/
        @request_hash["message"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-tsp=/
        @request_hash["timestamp_passive"] = element.gsub(/^-[a-z]+=/, "")
      end   
    end
    return @request_hash
  end


  def verif_active ( hash )
    # check_command ; args ; 
    @request_hash = hash
    @tab_error = Array.new
    # On verifie que la key check_command est disponible
    if !@request_hash.has_key? "check_command"
      @tab_error.push('check_command')
    end
    # On vérifie que le key "args" est disponible
    if !@request_hash.has_key? "args"
      @tab_error.push('args')
    end
    # on retourne le tableau d'erreur
    return @tab_error
  end

  def verif_passive ( hash )
    # host ; service ; return_code ;
    @request_hash = hash
    @tab_error = Array.new
    @ntype_state = '0'
    

    if !@request_hash.has_key? "notified_type"
      @tab_error.push ('ntype')
      @ntype_state = '1'
    end


    if @ntype_state == '0'

      #On verifie que la key timestamp_passive est disponible
      if !@request_hash.has_key? "timestamp_passive"
        @tab_error.push('timestamp_passive (-tsp)')
      end
      #On verifie que la key notified_host est disponible
      if !@request_hash.has_key? "notified_type"
        @tab_error.push('notified_type (-ntype)')
      end
      #On verifie que la key host est disponible
      if !@request_hash.has_key? "notified_host"
        @tab_error.push('notified_host (-nhost)')
      end 
      #On verifie que la key return_code est disponible
      if !@request_hash.has_key? "return_code"
        @tab_error.push('return_code (-rc)')
      end 
      #On verifie que la key message est disponible
      if !@request_hash.has_key? "message"
        @tab_error.push('message (-msg)')
      end

 
      if @request_hash["notified_type"] == 's'  
        if !@request_hash.has_key? "notified_service"
          @tab_error.push('notified_service (-ntype)')
puts "passage de la spec notified s"
        end 
      end 

      # on retourne le tableau d'erreur
      return @tab_error
    end
  end
  
  def verif_check ( hash_config, hash_request )
    ## Return 1 if check not exist
    @hash_config = hash_config
    @hash_request = hash_request
    @check = @hash_request["check_command"]  
    @file = "#{@hash_config["path_plugin"]}/#{@hash_request["check_command"]}"
    @file_exist = File.exists?(@file)
    @file_exec = File.executable?(@file)
    if @file_exist == false || @file_exec == false
      return 1
    else 
      return 0
    end
  end
### CLASS CLOSE
end
