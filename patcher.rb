#!/usr/bin/env ruby
require 'digest'
require 'trollop'
require 'net/http'
require 'uri'
require 'open-uri'
require 'fileutils'

#
# Set the options via Trollop
#
opts = Trollop::options do
  opt :client, "Client type", :type => :string, :required => "true"
  opt :force, "Force patcher run"
end

#
# Lets add some color!!
#
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(93)
  end

end

banner = 
"
 #     #                                           
 ##    # ######  ####   ####  #####   ####  #    # 
 # #   # #      #    # #    # #    # #    # ##   # 
 #  #  # #####  #    # #      #    # #    # # #  # 
 #   # # #      #    # #      #####  #    # #  # # 
 #    ## #      #    # #    # #   #  #    # #   ## 
 #     # ######  ####   ####  #    #  ####  #    # 

     Neocron Classic  -- Linux Patcher v1.0.1
                                          by Gnisha
 =================================================
"
puts "#{banner}"
puts " [ PATCHER ] Cleaning up from previous runs."
File.delete("#{opts[:client]}.manifest") if File.exist?("#{opts[:client]}.manifest")
File.delete("#{opts[:client]}.download") if File.exist?("#{opts[:client]}.download")

#
# Get patch level of specified client
# and get server patch level of client.
#
if File.exist?("#{opts[:client]}/Neocron.tll")
  if "#{opts[:force]}" == "true"
    # Set patch level to 0 to force a file check
    CLIENT_PATCH_LEVEL = "0"
    puts " [ PATCHER ] Forcing a file system check!".yellow
    puts " [ PATCHER ] Client patch level set to '0'".yellow
  else
    CLIENT_PATCH_LEVEL = File.read("#{opts[:client]}/Neocron.tll")[0,16].gsub(/\D/, "").chomp
  end

  SERVER_PATCH_LEVEL = open("http://patches.neocron.org/clients/#{opts[:client]}/Neocron.tll") {|f| f.read[0,16].gsub(/\D/, "").chomp }
  puts " => Client Patch Level: #{CLIENT_PATCH_LEVEL}"
  puts " => Server Patch Level: #{SERVER_PATCH_LEVEL}" 
  if "#{CLIENT_PATCH_LEVEL}" == "#{SERVER_PATCH_LEVEL}"
    puts " [ PATCHER ] Client is up to date.".green
    exit
  else
    puts " [ PATCHER ] Client is out of date.".red
  end
else
  puts " [ PATCHER ] Unable to determine local '#{opts[:client]}' version.".red
  puts " [ PATCHER ] => Proceeding to patch (or install) '#{opts[:client]}' to current release.".yellow
end

#
# Grab the specified client manifest from the patch server
#
uri = URI("http://patches.neocron.org/clients/#{opts[:client]}/.manifest")
remote_manifest_verify = Net::HTTP.get_response(uri).code.chomp
if remote_manifest_verify == "200"
  puts " [ PATCHER ] Verified #{opts[:client]} exists on patch server."
  puts " [ PATCHER ] Downloading #{opts[:client]} manifest."
  File.write("#{opts[:client]}.manifest", Net::HTTP.get(uri))
else
  puts " [ ERROR ] Cannot find #{opts[:client]} mainifest on patch server.".red
  exit
end

#
# Open the manifest for the client and check SHA hashes
# and determine which files need updating.
#
# Files needing updating are put into CLIENT_TYPE.download
#
puts " [ PATCHER ] Verifying '#{opts[:client]}'.  Please wait.".yellow
File.open("#{opts[:client]}.manifest").drop(1).each do |line|
  filename = line.split(/:/)[2].chomp
  server_hash = line.split(/:/)[0].chomp
  local_hash = Digest::SHA1.file ("#{opts[:client]}/#{line.split(/:/)[2]}").chomp if File.exist?("#{opts[:client]}/#{filename}")
  if "#{server_hash}" != "#{local_hash}"
    print "\t => #{filename}"
    print " [ OUT OF DATE ]\n".red
    IO.write("#{opts[:client]}.download", "#{filename}\n", mode: 'a')
  end
end

#
# Download out of date files.
#
def download(url, path)
  File.open("#{path}", "w") do |f|
    IO.copy_stream(open("#{url}"), f)
  end
end

if File.exist?("#{opts[:client]}.download")
  patch_server = "http://patches.neocron.org/clients/#{opts[:client]}"
  puts " [ PATCHER ] Patching files".yellow
  File.open("#{opts[:client]}.download").each do |line|
    file = line.chomp
    print "\t => #{file}"
    print " [ OK ]\n".green
    dirname = File.dirname("#{opts[:client]}/#{file}")
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    url_to_file = URI.escape("#{patch_server}/#{file}")
    download("#{url_to_file}","#{opts[:client]}/#{file}")
  end
end
puts " [ PATCHER ] Complete.".green
