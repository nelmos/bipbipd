class Cprocessing

  #@plugins = "/usr/lib/nagios/plugins/"


  def active_check ( tab )
    @plugins = "/usr/lib/nagios/plugins"
    @tab = tab
    @temp = @tab[2]
    @cmd = @temp.gsub(/^[a-z]+=/, "")
    #puts @cmd
    %x(#{@plugins}/#{@cmd})
    @result = %x(date)
    return @result
  end

  def passive_check ( tab )
    @file = File.open("/usr/local/nagios/var/rw/nagios.cmd", "a")
    @tab = tab
    @temp = @tab[2]
    @cmd = @temp.gsub(/^[a-z]+=/, "")
    puts " --> Event : #{@cmd}"
    @file.write @cmd
    @file.close
    return " --> Event writed"
  end

end
