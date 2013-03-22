class C_processing
 
  def check_active ( hash_config, hash_request )
    @args = hash_request["args"].gsub(/:/, " ")
    @cmd = "#{hash_config["path_plugin"]}/#{hash_request["check_command"]} #{@args}"
    @result = %x(#{@cmd})
    return @result
  end

  def check_passive ( hash_config, hash_request )
    @hash_config = hash_config
    @hash_request = hash_request
    @type = @hash_request["notified_type"]
    @notified_service_value =  "PROCESS_SERVICE_CHECK_RESULT"
    @notified_host_value = "PROCESS_HOST_CHECK_RESULT"
    case @type
      when "s"
      # CREATE PASSIVE CHECK_SERVICE REQUEST
      @cmd = "[#{hash_request["timestamp_passive"]} ] #{@notified_service_value};#{hash_request["notified_host"]};#{hash_request["notified_service"]};#{hash_request["return_code"]};#{hash_request["message"]}" 
      when "h"
      @cmd = "[#{hash_request["timestamp_passive"]} ] #{@notified_host_value};#{hash_request["notified_host"]};#{hash_request["return_code"]};#{hash_request["message"]}" 
    end
    @file = File.open("#{@hash_config["path_cmd_nagios"]}", "a")
    @file.puts @cmd
    @file.close
  end
end
