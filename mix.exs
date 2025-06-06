defmodule PrqlRs.MixProject do
  use Mix.Project

  @source_url "https://github.com/dkuku/prql_rs"
  @upstream_url "https://github.com/PRQL/prql"
  @book "https://prql-lang.org/book/"
  @version "0.1.0"

  def project do
    [
      app: :prql_rs,
      name: "prql_rs",
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps(),
      package: package(),
      description:
        "PRQL (Pipelined Relational Query Language) compiler for Elixir, powered by Rust's prqlc",
      docs: docs(),
      source_url: @source_url,
      homepage_url: @source_url,
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.36", runtime: false},
      {:ex_doc, "~> 0.36", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      name: "prql_rs",
      maintainers: ["Daniel Kukula"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Book" => @book,
        "PRQL Upstream" => @upstream_url
      },
      files: [
        "lib",
        "native/prql_native/src",
        "native/prql_native/Cargo.*",
        ".formatter.exs",
        "mix.exs",
        "README.md"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
