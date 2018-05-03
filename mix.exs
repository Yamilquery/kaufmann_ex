defmodule KaufmannEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :kaufmann_ex,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: Coverex.Task],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      maintaners: ["sevenmind", "Grant McLendon"],
      links: %{
        GitHub: "https://github.com/sevenmind/kaufmann_ex"
      },
      licenses: ["MIT"]
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
      {:gen_stage, "~> 0.12"},
      {:kafka_ex, "~> 0.8.1", runtime: false},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:avro_ex, "~> 0.1.0-beta.0"},
      {:schemex, "~> 0.1.1"},
      {:nanoid, "~> 1.0"},
      {:memoize, "~> 1.2"},
      {:distillery, "~> 1.5", runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:bypass, "~> 0.8", only: :test},
      {:excoveralls, "~> 0.8", only: :test},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:inch_ex, only: :docs}
    ]
  end

  defp aliases do
    [
      # test: "test --no-start --exclude integration"
    ]
  end
end
