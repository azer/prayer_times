defmodule PrayerTimes.Methods do
  @moduledoc """
  Handles the different calculation methods for determining Islamic prayer times.

  ## Supported Calculation Methods

  The following calculation methods are supported, each with its specific parameters for Fajr and Isha prayers:

  * `:mwl` - Muslim World League
    - Fajr angle: 18, Isha angle: 17
  * `:isna` - Islamic Society of North America (ISNA)
    - Fajr angle: 15, Isha angle: 15
  * `:egypt` - Egyptian General Authority of Survey
    - Fajr angle: 19.5, Isha angle: 17.5
  * `:makkah` - Umm Al-Qura University, Makkah
    - Fajr angle: 18.5, Isha time: 90 minutes after Maghrib
  * `:karachi` - University of Islamic Sciences, Karachi
    - Fajr angle: 18, Isha angle: 18
  * `:tehran` - Institute of Geophysics, University of Tehran
    - Fajr angle: 17.7, Isha angle: 14, Maghrib angle: 4.5, Midnight: Jafari
  * `:jafari` - Shia Ithna-Ashari, Leva Institute, Qum
    - Fajr angle: 16, Isha angle: 14, Maghrib angle: 4, Midnight: Jafari
  * `:turkiye` - Presidency of Religious Affairs, Türkiye
    - Fajr angle: 18, Isha angle: 17, Maghrib time: 9 minutes after sunset
    - Time offsets: Fajr: -2, Sunrise: -7, Dhuhr: 6, Asr: 4, Isha: 2

  ## Usage

  Each method can be specified when calling the `PrayerTimes.compute/1` function to get the prayer times according to that method.
  """

  @default_settings %{
    imsak: '10 min',
    dhuhr: '0 min',
    maghrib: '0 min',
    midnight: 'Standard',
    asr: :standard,
    high_lats: :night_middle
  }

  @methods %{
    mwl: %{
      name: "Muslim World League",
      params: %{fajr: 18, isha: 17},
      offsets: %{}
    },
    isna: %{
      name: "Islamic Society of North America (ISNA)",
      params: %{fajr: 15, isha: 15},
      offsets: %{}
    },
    egypt: %{
      name: "Egyptian General Authority of Survey",
      params: %{fajr: 19.5, isha: 17.5},
      offsets: %{}
    },
    makkah: %{
      name: "Umm Al-Qura University, Makkah",
      params: %{fajr: 18.5, isha: '90 min' },
      offsets: %{}
    },
    karachi: %{
      name: "University of Islamic Sciences, Karachi",
      params: %{fajr: 18, isha: 18},
      offsets: %{}
    },
    tehran: %{
      name: "Institute of Geophysics, University of Tehran",
      params: %{fajr: 17.7, isha: 14, maghrib: 4.5, midnight: "Jafari"},
      offsets: %{}
    },
    jafari: %{
      name: "Shia Ithna-Ashari, Leva Institute, Qum",
      params: %{fajr: 16, isha: 14, maghrib: 4, midnight: "Jafari"},
      offsets: %{}
    },
    turkiye: %{
      name: "Presidency of Religious Affairs, Türkiye",
      params: %{fajr: 18, isha: 17, maghrib: '9 min' },
      offsets: %{
	fajr: -2, sunrise: -7, dhuhr: 6, asr: 4, isha: 2
      }
    }
  }

  def offset(method, time_key) do
    get_offsets(method)[time_key] || 0
  end

  def param(method, param) when is_atom(param) do
    get_params(method)[param] || @default_settings[param]
  end

  def param(method, %{ int: param }) do
    value = param(method, param)
    cond do
      is_list(value) ->
	String.to_integer(Regex.replace(~r/[a-zA-Z\s]+/, List.to_string(value), ""))
      is_integer(value) ->
	value
      true ->
	0
    end
  end

  def param(method, %{ min: param }) do
    value = param(method, param)
    cond do
      is_list(value) and String.contains?(List.to_string(value), "min") ->
	String.to_integer(Regex.replace(~r/[a-zA-Z\s]+/, List.to_string(value), ""))
      true ->
	nil
    end
  end

  def get_settings(method) do
    Map.get(@methods, method, %{ name: "default", params: @default_settings })
  end

  def get_params(method) do
    #Map.get(@methods, method, %{ name: "default", params: @default_settings }).params
    get_settings(method).params
  end

  def get_offsets(method) do
    get_settings(method).offsets
  end
end
