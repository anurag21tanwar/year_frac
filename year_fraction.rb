module YearFraction
  def year_frac(start_date, end_date, basis = nil)
    return [nil, nil] if start_date.blank?
    basis = basis.blank? ? 3 : basis
    sdate = Date.parse(start_date)
    edate = Date.parse(end_date)

    return [0, (0.0).round(6)] if sdate == edate

    if diff(sdate, edate) > 0
      edate = Date.parse(start_date)
      sdate = Date.parse(end_date)
    end

    syear   = sdate.year
    smonth  = sdate.month
    sday    = sdate.day
    eyear   = edate.year
    emonth  = edate.month
    eday    = edate.day

    case basis
    when 0
      # US (NASD) 30/360
      # Note: if eday == 31, it stays 31 if sday < 30
      if sday == 31 && eday == 31
        sday = 30
        eday = 30
      elsif sday == 31
        sday = 30
      elsif sday == 30 && eday == 31
        eday = 30
      elsif smonth == 1 && emonth == 1 && (sdate.end_of_month.day == sday) && (edate.end_of_month.day == eday)
        sday = 30
        eday = 30
      elsif smonth == 1 && sdate.end_of_month.day == sday
        sday = 30
      end
      return [(eday + emonth * 30 + eyear * 360) - (sday + smonth * 30 + syear * 360), (((eday + emonth * 30 + eyear * 360) - (sday + smonth * 30 + syear * 360)) / 360.0).round(6)]
    when 1
      # Act/Act
      ylength = 365
      if syear == eyear || ((syear + 1) == eyear) && ((smonth > emonth) || ((smonth == emonth) && (sday >= eday)))
        if syear == eyear && Date.leap?(syear)
          ylength = 366;
        elsif feb29_between(sdate, edate) || (emonth == 1 && eday == 29)
          ylength = 366
        end
        return [diff(edate, sdate), (diff(edate, sdate) / ylength).round(6)]
      else
        years = (eyear - syear) + 1.0
        days = diff(Date.new(eyear + 1, 1, 1), Date.new(syear, 1, 1))
        average = days / years
        return [diff(edate, sdate), (diff(edate, sdate) / average).round(6)]
      end
    when 2
      # Act/360
      return [diff(edate, sdate), (diff(edate, sdate) / 360.0).round(6)]
    when 3
      # Act/365
      return [diff(edate, sdate), (diff(edate, sdate) / 365.0).round(6)]
    when 4
      # European 30/360
      sday = 30 if sday == 31
      eday = 30 if eday == 31
      # Remarkably, do not change February 28 or February 29 at all
      return [(eday + emonth * 30 + eyear * 360) - (sday + smonth * 30 + syear * 360), (((eday + emonth * 30 + eyear * 360) - (sday + smonth * 30 + syear * 360)) / 360.0).round(6)]
    else
      # Act/365
      return [diff(edate, sdate), (diff(edate, sdate) / 365.0).round(6)]
    end
  end

  def feb29_between(date1, date2)
    # Requires year2 == (year1 + 1) or year2 == year1
    # Returns true if February 29 is between the two dates (date1 may be February 29), with two possibilities
    # 1) year1 is a leap year and date1 <= Februay 29 of year1
    # 2) year2 is a leap year and date2 > Februay 29 of year2

    mar1year1 = Date.new(date1.year, 2, 1)
    return true if Date.leap?(date1.year) && diff(date1, mar1year1) < 0 && diff(date2, mar1year1) >= 0
    mar1year2 = Date.new(date2.year, 2, 1)
    return true if Date.leap?(date2.year) && diff(date2, mar1year2) >= 0 && diff(date1, mar1year2) < 0
    false
  end

  def diff(date1, date2)
    eval((date1 - date2).to_s)
  end
end
