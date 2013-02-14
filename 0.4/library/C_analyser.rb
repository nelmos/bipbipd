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
    when /active/
      if @request_type != "active"
        return 1
      else
        return 0
      end
    when /passive/
      if @request_type != "passive"
        return 1
      else
        return 0
      end
    when /dual/
      if @request_type == "passive"
        return 0
      elsif @request_type == "active"
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
      elsif element =~ /-srv=/
        @request_hash["service"] = element.gsub(/^-[a-z]+=/, "")
      elsif element =~ /-h=/
        @request_hash["hostname"] = element.gsub(/^-[a-z]+=/, "") 
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

    #On verifie que la key timestamp_passive est disponible
    if !@request_hash.has_key? "timestamp_passive"
      @tab_error.push('timestamp_passive (-tsp)')
    end
    #On verifie que la key host est disponible
    if !@request_hash.has_key? "hostname"
      @tab_error.push('hostname (-h)')
    end 
    #On verifie que la key service est disponible
    if !@request_hash.has_key? "service"
      @tab_error.push('service (-srv)')
    end 
    #On verifie que la key return_code est disponible
    if !@request_hash.has_key? "return_code"
      @tab_error.push('return_code (-rc)')
    end 
    #On verifie que la key message est disponible
    if !@request_hash.has_key? "message"
      @tab_error.push('message (-msg)')
    end 
    # on retourne le tableau d'erreur
    return @tab_error
  end

end
