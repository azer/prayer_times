# prayer_times

Configurable calculation package for Muslim prayer times in Elixir.

## Installation

Add `prayer_times` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prayer_times, "~> 0.1.0"}
  ]
end
```

## Usage

To obtain prayer times for a specific location and date:

```elixir
prayer_times = PrayerTimes.compute(%{
  method: :turkiye,
  date: Date.utc_today,
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


### Parameters

* method: The calculation method (e.g., `:mwl`, `:isna`, `:egypt`, `:makkah`, `:karachi`, `:tehran`, `:jafari`).
* date: The date for which to calculate the prayer times (Date struct).
* lat: Latitude of the location.
* long: Longitude of the location.
* timezone: UTC offset for the location's timezone.

### Supported calculation methods:

  * `:mwl` - Muslim World League
  * `:isna` - Islamic Society of North America (ISNA)
  * `:egypt` - Egyptian General Authority of Survey
  * `:makkah` - Umm Al-Qura University, Makkah
  * `:karachi` - University of Islamic Sciences, Karachi
  * `:tehran` - Institute of Geophysics, University of Tehran
  * `:jafari` - Shia Ithna-Ashari, Leva Institute, Qum
  * `:turkiye` - Presidency of Religious Affairs, Türkiye
