defmodule PrayerTimes.Calculation do
  alias PrayerTimes.Utils
  alias PrayerTimes.Methods

  @moduledoc """
  Handles the internal calculations for determining Islamic prayer times.

  This module is primarily used by `PrayerTimes` to calculate accurate prayer times based on various methods and parameters like latitude, longitude, timezone, and date.

  ## Details

  The calculation involves converting the given date to the Julian date, computing the sun's position, and then adjusting the times according to the selected method and high latitude rules.

  This module is not typically used directly in user applications; instead, use `PrayerTimes.compute/1`.

  ## Supported Methods

  - `:mwl`: Muslim World League
  - `:isna`: Islamic Society of North America
  - `:egypt`: Egyptian General Authority of Survey
  - `:makkah`: Umm al-Qura University, Makkah
  - `:karahci`: University of Islamic Sciences, Karachi
  - `:tehran`: Institute of Geophysics, University of Tehran
  - `:jafari`: Shia Ithna-Ashari
  """

  def get_times(%{method: method, timezone: tz, lat: lat, long: long, date: date}) do
    julian_date = Timex.to_julian(date) - long / (15 * 24.0)
    times = compute_times(method, julian_date, tz, lat, long)

    Enum.map(times, fn {key, value} ->
      {hours, minutes} = Utils.float_to_datetime(times[key])

      d = %NaiveDateTime{ year: date.year, month: date.month, day: date.day,
		 minute: trunc(minutes), hour: trunc(hours), second: 0
		  }
      {key, d}
    end)
    |> Enum.into(%{})
  end

  def compute_times(method, jdate, tz, lat, long) do
    times = %{
      imsak: 5,
      fajr: 5,
      sunrise: 6,
      dhuhr: 12,
      asr: 13,
      sunset: 18,
      maghrib: 18,
      isha: 18
    }

    times =
      times
      |> compute_prayer_times(method, jdate, lat)
      |> adjust_times(method, tz, long)

    midnight_diff =
      if Methods.param(method, :midnight) == 'Jafari',
        do: Utils.time_diff(times.sunset, times.fajr),
        else: Utils.time_diff(times.sunset, times.sunrise)

      times
      |> Map.put(:midnight, times.sunset + midnight_diff / 2)
      |> apply_offsets(method)
  end

  def compute_prayer_times(times, method, jdate, lat) do
    times = Enum.map(times, fn {key, value} -> {key, day_portion(value)} end)

    imsak =
      sun_angle_time(jdate, Methods.param(method, %{int: :imsak}), times[:imsak], lat, false)

    fajr = sun_angle_time(jdate, Methods.param(method, %{int: :fajr}), times[:fajr], lat, false)
    sunrise = sun_angle_time(jdate, rise_set_angle(0), times[:sunrise], lat, false)
    dhuhr = mid_day(jdate, times[:dhuhr])
    asr = asr_time(jdate, asr_factor(Methods.param(method, :asr)), times[:asr], lat)
    sunset = sun_angle_time(jdate, rise_set_angle(0), times[:sunset], lat)
    maghrib = sun_angle_time(jdate, Methods.param(method, %{int: :maghrib}), times[:maghrib], lat)
    isha = sun_angle_time(jdate, Methods.param(method, %{int: :isha}), times[:isha], lat)

    %{
      asr: asr,
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      sunset: sunset,
      maghrib: maghrib,
      isha: isha
    }
  end

  def adjust_times(times, method, timezone, long) do
    tz_adjust = timezone - long / 15.0

    times =
      times
      |> Enum.map(fn {key, value} -> {key, value + tz_adjust} end)
      |> Enum.into(%{})

    times =
      if Methods.param(method, :high_lats) != :none,
        do: adjust_high_lats(method, times),
        else: times

    min_imsak = Methods.param(method, %{min: :imsak})
    min_maghrib = Methods.param(method, %{min: :maghrib})
    min_isha = Methods.param(method, %{min: :isha})

    imsak = if min_imsak != nil, do: times.fajr - min_imsak / 60.0, else: times.imsak
    maghrib = if min_maghrib != nil, do: times.sunset + min_maghrib / 60.0, else: times.maghrib
    isha = if min_isha != nil, do: times.maghrib + min_isha / 60.0, else: times.isha
    dhuhr = times.dhuhr + Methods.param(method, %{int: :dhuhr}) / 60.0

    times
    |> Map.put(:imsak, imsak)
    |> Map.put(:maghrib, maghrib)
    |> Map.put(:isha, isha)
    |> Map.put(:dhuhr, dhuhr)
  end

  def adjust_high_lats(method, times) do
    night_time = Utils.time_diff(times[:sunset], times[:sunrise])

    times
    |> Map.put(
      :imsak,
      adjust_high_lats_time(
        method,
        times.imsak,
        times.sunrise,
        Methods.param(method, %{int: :imsak}),
        night_time,
        false
      )
    )
    |> Map.put(
      :fajr,
      adjust_high_lats_time(
        method,
        times[:fajr],
        times[:sunrise],
        Methods.param(method, %{int: :fajr}),
        night_time,
        false
      )
    )
    |> Map.put(
      :isha,
      adjust_high_lats_time(
        method,
        times[:isha],
        times[:sunset],
        Methods.param(method, %{int: :isha}),
        night_time
      )
    )
    |> Map.put(
      :maghrib,
      adjust_high_lats_time(
        method,
        times[:maghrib],
        times[:sunset],
        Methods.param(method, %{int: :maghrib}),
        night_time
      )
    )
  end

  def adjust_high_lats_time(method, time, base, angle, night, clock_wise \\ true) do
    high_lats_method = Methods.param(method, :high_lats)
    portion = night_portion(angle, night, high_lats_method)

    diff = if !clock_wise, do: Utils.time_diff(time, base), else: Utils.time_diff(base, time)

    cond do
      diff > portion ->
        base - portion

      true ->
        time
    end
  end

  def apply_offsets(times, method) do
    times
    |> Enum.map(fn {key, value} -> {key, value + Methods.offset(method, key) / 60.0} end)
    |> Enum.into(%{})
  end

  def night_portion(angle, night, high_lats_method) do
    portion =
      case high_lats_method do
        :angle_based -> 1 / 60.0 * angle
        :one_seventh -> 1 / 7.0
        # Default to midnight
        _ -> 1 / 2.0
      end

    portion * night
  end

  def sun_angle_time(jdate, angle, time, lat, clockwise \\ true) do
    {decl, _} = sun_position(jdate + time)

    noon = mid_day(jdate, time)

    t =
      1 / 15.0 *
        Utils.arccos(
          (-Utils.sin(angle) - Utils.sin(decl) * Utils.sin(lat)) /
            (Utils.cos(decl) * Utils.cos(lat))
        )

    if clockwise == false, do: noon - t, else: noon + t
  end

  def mid_day(jdate, time) do
    jdatetime = jdate + time
    {_, eqt} = sun_position(jdatetime)
    Utils.fixhour(12 - eqt)
  end

  def day_portion(hours) do
    hours / 24.0
  end

  def rise_set_angle(elevation \\ 0) do
    elevation = if elevation == nil, do: 0, else: elevation
    0.833 + 0.0347 * :math.sqrt(elevation)
  end

  def asr_time(jdate, factor, time, lat) do
    {decl, _} = sun_position(jdate + time)
    angle = -Utils.arccot(factor + Utils.tan(abs(lat - decl)))
    sun_angle_time(jdate, angle, time, lat)
  end

  def asr_factor(asr_setting) do
    methods = %{standard: 1, hanafi: 2}
    Map.get(methods, asr_setting, asr_setting)
  end

  def sun_position(jd) do
    d = jd - 2_451_545.0

    g = Utils.fixangle(357.529 + 0.98560028 * d)
    q = Utils.fixangle(280.459 + 0.98564736 * d)
    l = Utils.fixangle(q + 1.915 * Utils.sin(g) + 0.020 * Utils.sin(2 * g))

    # r = 1.00014 - 0.01671 * Utils.cos(g) - 0.00014 * Utils.cos(2 * g)
    e = 23.439 - 0.00000036 * d

    ra = Utils.arctan2(Utils.cos(e) * Utils.sin(l), Utils.cos(l)) / 15.0
    eqt = q / 15.0 - Utils.fixhour(ra)
    decl = Utils.arcsin(Utils.sin(e) * Utils.sin(l))

    {decl, eqt}
  end
end
