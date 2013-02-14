class Canalyzer

attr_reader :rt

#  # Return la chaine
#  def get_chaine
#   return @chaine
#  end


  # Genere un tableau depuis la commande en entree
  def generate_tab ( chaine )
    @chaine = chaine
    @tab_generate = @chaine.split('|')
    return @tab_generate
  end

  # Recherche le type de requete
  def search_rt ( tab )
    @tab_rt = tab
    if @tab_rt[0] =~ /rt=[AP]/
      @temp = @tab_rt[0]
      @rt = @temp.gsub(/^[a-z]+=/, "")
      return @rt
    else
      @rt = "error - No rt field"
      return @rt
    end
  end

  # Recherche si relais
  def search_relay ( tab )
    @tab_d = tab
    if @tab_d[1] =~ /relay=[01]/
      @temp = @tab_d[1]
      @relay = @temp.gsub(/^[a-z]+=/, "")
      return @relay
    else
      @relay = "error - No relay field"
      return @relay
    end
  end

end

