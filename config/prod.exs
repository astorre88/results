import Config

config :results, Results.Repo,
  load_from_system_env: true,
  pool_size: 10

config :results, ResultsWeb.Endpoint,
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  code_reloader: false

config :logger, level: :info

config :results, Results.Worker,
  python: "/home/deploy/anaconda3/envs/py37/bin/python",
  recognize_script: "/home/deploy/results/builds/python_scripts/recognize.py",
  encodings: "/home/deploy/results/builds/python_scripts/encodings.pickle",
  model: {:system, "YOLO_MODEL"}
