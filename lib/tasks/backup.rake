require 'rubygems'
require 'json'
namespace :db do
  desc "Backs up current data in case of emergency."
  task :backup => :environment do
    if File.exists?("db/backups/backup.json")
      File.rename("db/backups/backup.json", "db/backups/" + Time.now.midnight.strftime("%m-%d-%Y") + "-backup.json")
    end
    File.open("db/backups/backup.json", "w") { |file| file.write(JSON.pretty_generate(Sheet.all.as_json))}
  end
end