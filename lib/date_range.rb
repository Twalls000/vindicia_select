class DateRange

  attr_accessor :starting, :ending

  def initialize(starting = Date.today, ending = nil)
    self.starting = Date.parse(starting) rescue Date.now
    self.ending = Date.parse(ending) rescue starting
  end

  def beginning_of_week(start_day_of_week = :sunday)
    starting.beginning_of_week(start_day_of_week).beginning_of_day
  end

  def week_range
    beginning_of_week..end_of_week
  end

  def month_range
    starting.beginning_of_month.beginning_of_day..starting.end_of_month.end_of_day
  end

  def ytd_range
    starting.beginning_of_year.beginning_of_day..end_of_week
  end

  def end_of_week(end_day_of_week = :sunday)
    starting.end_of_week(end_day_of_week).end_of_day
  end

end
