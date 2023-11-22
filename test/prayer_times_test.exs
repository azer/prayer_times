defmodule PrayerTimesTest do
  use ExUnit.Case
  doctest PrayerTimes

  test "when method is MWL for date 2011/2/9, location Waterloo/Canada, timezone -5" do
    actual = PrayerTimes.compute(%{ method: :mwl, date: %Date{year: 2011, month: 2, day: 9}, lat: 43, long: -80, timezone: -5 })

    expected = %{
      imsak: ~N[2011-02-09 05:39:00],
      fajr: ~N[2011-02-09 05:49:00],
      sunrise: ~N[2011-02-09 07:25:00],
      dhuhr: ~N[2011-02-09 12:34:00],
      asr: ~N[2011-02-09 15:19:00],
      sunset: ~N[2011-02-09 17:44:00],
      maghrib: ~N[2011-02-09 10:53:00],
      isha: ~N[2011-02-09 19:14:00],
      midnight: ~N[2011-02-09 00:35:00]
    }

    assert actual == expected
  end

  test "when method is MWL for date 2023/11/22, location Istanbul/Turkiye, timezone +3" do
      actual = PrayerTimes.compute(%{
        method: :turkiye,
        date: %Date{year: 2023, month: 11, day: 22},
        lat: 41.0082,
        long: 28.9784,
        timezone: 3
      })

      expected = %{
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

      assert actual == expected
    end
end
