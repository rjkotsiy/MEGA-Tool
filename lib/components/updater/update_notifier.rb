# encoding: utf-8

require 'net/http'

module MGT
  module UpdateNotifier
   extend self  

   def check_version

	   uri = URI("http://crotone:80") # TODO, rkotsiy: in future need move it into config file

     resp = ""
     
     #lets assume what everything is OK
     resp_code = 200;
     checking_update_allowed = true

     begin

       Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
         resp = http.get("/version.txt")
         resp_code = resp.code         
       end

       if resp_code == '401' && response.msg.capitalize == 'Unauthorized'
         puts "Please, check your credentials to update server."
         checking_update_allowed = false
       elsif resp_code == '502'
         puts "Something going wrong on system."
         checking_update_allowed = false
       elsif resp_code == '404'
         puts "Version not found in update server."
         checking_update_allowed = false
       end

       rescue Errno::ECONNREFUSED
         puts "Can't get access to update server - Connection refused."
         checking_update_allowed = false
       rescue Errno::ETIMEDOUT
         puts "Can't get access to update server -  Connection timed out."
         checking_update_allowed = false
       rescue 
         puts "Unknown update server error"
         checking_update_allowed = false
     end
	
	   check_minor_major_version(resp.body) if checking_update_allowed
   end


   private

   @@VERSION_FILE = "version"

   def check_minor_major_version version_on_server

  		puts "MEGA Tool version:#{get_current_version}"

   		current_version = get_current_version.split('.')  

   		if (current_version.size == 0)
   			return
   		end

   		version = version_on_server.split('.')   		
   		if (version.size == 0)
   			return
   		end

   		major_tool_ver = current_version[0].to_i
   		minor_tool_ver = current_version[1].to_i

   		major_ver = version[0].to_i
   		minor_ver = version[1].to_i
   		
   		if (major_tool_ver < major_ver)
  			puts "New MEGA tool version is available, we strongly recommended to update it!!!"
  			puts "Exiting..."
  			exit 1
   		end

   		if (minor_tool_ver < minor_ver)
   			puts "New MEGA tool version is available, please update it."
   		end

   end

   def get_current_version 

   tool_version = "0.0.0"

   if File.file?(@@VERSION_FILE)

  		tool_version_file = File.open(@@VERSION_FILE ).read
  		tool_version_file.each_line do |line|
  	  		tool_version = line
  		end   
    end

    return tool_version # no version file, looks like we have very earlier version and need to update

  end


 end
end
