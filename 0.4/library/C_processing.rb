class C_processing
 
 def check_active ( hash_config, hash_request )
    @args = hash_request["args"].gsub(/:/, " ")
    @cmd = "#{hash_config["path_plugin"]}/#{hash_request["check_command"]} #{@args}"
    @result = %x(#{@cmd})
    return @result
  end

  def check_passive ( hash_config, hash_request )
    #[1348349172 ] PROCESS_SERVICE_CHECK_RESULT;vm-test-01;NSCA - TEST;2;That's work
    @cmd = "[#{hash_request["timestamp_passive"]} ] PROCESS_SERVICE_CHECK_RESULT;#{hash_request["hostname"]};#{hash_request["service"]};#{hash_request["return_code"]};#{hash_request["message"]}" 
    @file = hash_config["path_cmd_nagios"]
    #@file.write @cmd
    #@file.close
    return @cmd
  end
end
