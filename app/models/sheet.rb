class Sheet < ActiveRecord::Base
  belongs_to :month
  validates :day, :month_id, presence: true
  
  def self.seed(file_name = "db/backups/backup.json")
    file = File.read(file_name)
    objs = JSON.parse(file)
    Sheet.create(objs)
    # objs.each do |obj|
    #   logger.debug(i)
    #   i += 1
    #   logger.debug(obj)
    #   sheet = Sheet.new
    #   if obj.has_key?("in_time")
    #     sheet.in_time = obj['in_time']
    #   end
    #   if obj.has_key?('out_time')
    #     sheet.out_time = obj['out_time']
    #   end
    #   if obj.has_key?('lunch_start')
    #     sheet.lunch_start = obj['lunch_start']
    #   end
    #   if obj.has_key?('lunch_end')
    #     sheet.lunch_end = obj['lunch_end']
    #   end
    #   unless sheet.valid_obj?
    #     next
    #   end
    #   unless sheet.save!
    #     logger.debug("ERROR WITH THE FOLLOWING OBJ: " + JSON.dump(obj))
    #     break
    #   end
    # end
  end
  
  def valid_obj?
    errors = true
    [
      'in_time',
      'out_time',
      'lunch_start',
      'lunch_end'
    ].each do |key|
      unless self[key].nil?
        errors = false
      end
    end
    return !errors
  end
  
  def quarter_round(time)
    array = Time.at(time).to_a
    quarter = ((array[1] % 60) / 15.0).round
    array[1] = (quarter * 15) % 60
    array[0] = 0
    return (Time.local(*array) + (quarter == 4 ? 3600 : 0)).to_i
  end
  
  before_validation do
    months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ]
    unless self.in_time.nil?
      self.in_time = quarter_round(self.in_time)
      if self.day.nil?
        self.day = Time.at(in_time).midnight.to_i
      end
    end
    unless self.out_time.nil?
      self.out_time = quarter_round(self.out_time)
      if self.day.nil?
        self.day = Time.at(self.out_time).midnight.to_i
      end
    end
    unless self.lunch_start.nil?
      self.lunch_start = quarter_round(self.lunch_start)
      if self.day.nil?
        self.day = Time.at(self.lunch_start).midnight.to_i
      end
    end
    unless self.lunch_end.nil?
      self.lunch_end = quarter_round(self.lunch_end)
      if self.day.nil?
        self.day = Time.at(self.lunch_end).midnight.to_i
      end
    end
    logger.debug(self)
    unless self.day.nil?
      d = Time.at(self.day).to_date
      month = Month.where(num: d.month, year: d.year - 2000).first
      unless (month.nil?)
        self.month_id = month.id
        self.month = month
      else
        month = Month.new(
          num: d.month,
          name: months[d.month],
          year: d.year - 2000
        )
        if month.save!
          self.month_id = month.id
        end
      end
    end
  end
end

class SheetValidator < ActiveModel::Validator
  def validate(record)
    
  end
end