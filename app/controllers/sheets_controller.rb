require 'rubygems'
require 'json'

class SheetsController < ApplicationController
  
  protect_from_forgery :except => :add
  
  def build_sheet
    d = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    start_time = d.beginning_of_week(:sunday).to_time.to_i
    end_time = d.end_of_week(:saturday).to_time.to_i
    
    if start_time.nil? || end_time.nil?
      return
    end
    
    sheets = Sheet.where(day: start_time..end_time)
    
    week = [
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil
    ]
    
    sheets.each do |sheet|
      duration = sheet.get_duration.split(":").map {|x| x.to_i}
      duration[1] = duration[1] / 60.0
      week[Time.at(sheet["day"]).strftime("%u").to_i - 1] = duration[0] + duration[1]
    end
    
    @week = week
    
    # render :xlsx => 'build_sheet', :template => 'sheets/build_sheet'
    # respond_to do |format|
    #   format.xlsx {
    #     render xlsx: 'build_sheet', disposition: 'inline'
    #   }
    # end
    render json: {asdf: ActionView::Template::Handlers.extensions}
  end
  
  def photon_test
    respond_to do |format|
      format.html
      format.json { render :json => {} }
    end
  end
  
  def index
    @sheets = Sheet.all                                # Get all Sheets
    @objs = {}
    @sheets.each do |sheet|
      @objs[sheet.get_date] = {
        in_time: sheet.get_time(:in_time),
        out_time: sheet.get_time(:out_time),
        lunch_start: sheet.get_time(:lunch_start),
        lunch_end: sheet.get_time(:lunch_end),
        duration: sheet.get_duration,
        pay: sheet.get_pay
      }
    end
    @objs = JSON.dump(@objs)
    respond_to do |format|
      format.html
      format.json { render :json => @sheets }
    end
    # render :json => @sheets                             # Return in JSON
  end
  
  def find
    objs = {}
    if !params[:month].nil? && !params[:year].nil?
      logger.debug(params[:month])
      logger.debug(params[:year])
      month = Month.where(num: params[:month].to_i, year: params[:year].to_i).first
      logger.debug(JSON.dump(month))
      sheets = month.sheets
      
      sheets.each do |sheet|
        objs[Time.at(sheet.day).day] = sheet.as_json
      end
      logger.debug(JSON.dump(objs))
      # render :json => objs
    else
      objs = {error: true}
    end
    @objs = objs
    render :json => @objs
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
