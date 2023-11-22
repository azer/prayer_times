defmodule PrayerTimes.Utils do
  @pi :math.pi()

  def float_to_datetime(ftime) do
    ftime = fixhour(ftime + 0.5 / 60)
    hours = :math.floor(ftime)
    minutes = :math.floor((ftime - hours) * 60)
    {hours, minutes}
  end

  def sin(d), do: :math.sin(radians(d))
  def cos(d), do: :math.cos(radians(d))
  def tan(d), do: :math.tan(radians(d))

  def arcsin(x), do: degrees(:math.asin(x))
  def arccos(x), do: degrees(:math.acos(x))
  def arctan(x), do: degrees(:math.atan(x))
  def arccot(x), do: degrees(:math.atan(1.0 / x))
  def arctan2(y, x), do: degrees(:math.atan2(y, x))

  def radians(degrees) do
    degrees * @pi / 180.0
  end

  def degrees(radians) do
    radians * 180.0 / @pi
  end

  def fixangle(angle), do: fix(angle, 360.0)
  def fixhour(hour), do: fix(hour, 24.0)

  def time_diff(time1, time2) do
    fixhour(time2 - time1)
  end

  defp fix(a, mode) do
    a = a - mode * :math.floor(a / mode)
    if a < 0, do: a + mode, else: a
  end


end
