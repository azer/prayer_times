defmodule PrayerTimes do
  @moduledoc """
  To obtain prayer times for a specific location and date:

  ```elixir
prayer_times = PrayerTimes.compute(%{
  method: :turkiye,
  date: Date.utc_today(),
  lat: 41.0082,
  long: 28.9784,
  timezone: 3
})
```

This will return a map with the prayer times as NaiveDateTime values, for example:

```elixir
%{
  fajr: ~N[2023-11-22 06:21:00],
  sunrise: ~N[2023-11-22 07:53:00],
  dhuhr: ~N[2023-11-22 12:56:00],
  asr: ~N[2023-11-22 15:25:00],
  maghrib: ~N[2023-11-22 17:49:00],
  isha: ~N[2023-11-22 19:13:00],
  imsak: ~N[2023-11-22 06:13:00],
  midnight: ~N[2023-11-22 00:50:00],
  sunset: ~N[2023-11-22 17:40:00]
}
```

Parameters:
```
* method: The calculation method (e.g., `:mwl`, `:isna`, `:egypt`, `:makkah`, `:karachi`, `:tehran`, `:jafari`).
* date: The date for which to calculate the prayer times (Date struct).
* lat: Latitude of the location.
* long: Longitude of the location.
* timezone: UTC offset for the location's timezone.
```
"""
  def compute(params) do
    PrayerTimes.Calculation.get_times(params)
  end

end
