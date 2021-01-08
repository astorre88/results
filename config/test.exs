use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :results, Results.Repo,
  username: "postgres",
  password: "postgres",
  database: "results_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :results, ResultsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :results, start_worker: false

config :results, Results.Worker,
  python: "/Users/astorre/miniconda3/bin/python",
  recognize_script: "/Users/astorre/phoenix/results/python_scripts/recognize.py",
  encodings: "/Users/astorre/phoenix/results/python_scripts/encodings.pickle",
  model: {:system, "YOLO_MODEL"}
