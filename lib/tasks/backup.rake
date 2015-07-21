require 'rubygems'
require 'json'
namespace :db do
  desc "Backs up current data in case of emergency."
  task :backup => :environment do
    if File.exists?("db/backups/backup.json")
      old_data = JSON.parse(File.read("db/backups/backup.json"))
      new_data = JSON.parse(JSON.dump(Sheet.all.as_json))
      unless old_data == new_data
        File.rename("db/backups/backup.json", "db/backups/" + Time.now.midnight.strftime("%m-%d-%Y") + "-backup.json")
      end
    end
    File.open("db/backups/backup.json", "w") { |file| file.write(JSON.pretty_generate(Sheet.all.as_json))}
  end
end