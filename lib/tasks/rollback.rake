require 'rubygems'
require 'json'
require 'highline/import'
namespace :db do
  desc "Reverts the system to a previous backup."
  task :revert => :environment do
    if revert
      puts "Done!"
    else
      puts "Revert failed or canceled. Exiting..."
    end
  end
end

def revert
  puts "Please select from one of the following. Press [ENTER] to exit."
  i = 1
  files = []
  Dir::glob("db/backups/*-backup.json").each do |back|
    if JSON.is_json?(File.read(back))
      j_arr = JSON.parse(File.read(back))
      puts i.to_s + " - " + back.split("/")[-1].split("-").first(3).join("/") + " (#{j_arr.length} entries)"
      files[i - 1] = j_arr
      i += 1
    end
  end
  
  correct = false
  back = nil
  until correct
    back = (ask "#: ").to_i
    if (back >= 1 && back <= files.length)
      correct = true
    elsif back == 0
      return false
    else
      puts "Incorrect selection. Please try again."
    end
  end
  
  file = files[back - 1]
  File.open("db/backups/backup.json", "w+") { |f| f.write(JSON.pretty_generate(file)) }
  return true
end