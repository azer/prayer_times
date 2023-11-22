defmodule PrayerTimes.MixProject do
  use Mix.Project

  @source_url "https://github.com/azer/prayer_times"

  def project do
    [
      app: :prayer_times,
      version: "0.1.0",
      elixir: "~> 1.14",
      source_url: @source_url,
      homepage_url: @source_url,
      description: "Computes Islamic prayer times for a given location, date, and calculation method.",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
	licenses: ["Waqf"],
	links: %{
          "GitHub" => @source_url,
	}
      ],
      docs: [
	main: "readme", # The main page in the docs
	extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
