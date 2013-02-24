class C_log

  def logWrite ( file, msg )
    @logFile = File.open(file, "a")
    @logFile.write (msg)
    @logFile.close
  end


  def logPush ( lvl_log, lvl_msg, file, msg )
    if lvl_log.to_i >= lvl_msg.to_i
      logWrite file, msg
      puts msg
    end      
  end

end
