require 'rubygems'
require 'json'

class SheetsController < ApplicationController
  
  protect_from_forgery :except => :add
  
  def index
    @sheets = Sheet.all                                 # Get all Sheets
    
    render :json => @sheets                             # Return in JSON
  end
  
  def find
    if !params[:month].nil? && !params[:year].nil?
      logger.debug(params[:month])
      logger.debug(params[:year])
      month = Month.where(num: params[:month].to_i, year: params[:year].to_i).first
      logger.debug(JSON.dump(month))
      sheets = month.sheets
      
      objs = {}
      sheets.each do |sheet|
        objs[Time.at(sheet.day).day] = sheet.as_json
      end
      logger.debug(JSON.dump(objs))
      render :json => objs
    else
      render :json => {error: true}
    end
  end
  
  def add
    unless params[:obj].nil?
      obj = JSON.parse(params[:obj])                      # Get objects from params
      error = false
      obj.each do |key, val|
        d = Date.strptime(key, "%m/%d/%Y").to_time.to_i   # Create unix timestamp from date
        sheet = Sheet.where(day: d).first                 # Find existing sheet matching the timestamp
        if sheet.nil?                                     # If the sheet does not yet exist,
          sheet = Sheet.new                               # create a new one
        end
        
        val.each do |k, v| 
          sheet[k] = v                                    # Edit each property given
        end
        unless sheet.save!
          error = true
          logger.error "TIME NOT SAVED."
        end
      end
    else
      render :json => {error: true}
    end
    
    unless params[:deletions].nil?
      deletions = JSON.parse(params[:deletions])
      unless deletions.empty?
        deletions.each do |key, val|
          d = Date.strptime(key, "%d/%m/%Y").to_time.to_i
          sheet = Sheet.where(day: d).first
          logger.debug("\n\nVAL\n\n")
          logger.debug(val)
          val.keys.each do |k, v|
            sheet[k] = nil
          end
          unless sheet.save!
            error = true
          end
        end
      else
        error = true
      end
    end
    
    render :json => {error: error}                      # Return in JSON
  end
end
