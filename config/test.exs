import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :rld_live_view_studio, RldLiveViewStudio.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "rld_live_view_studio_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rld_live_view_studio, RldLiveViewStudioWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "4hBbetP96JzXWbEb5r4V+eYSvjJu6hyPi+El6k/8MDMaIZyJOnzQL7Hfpqz4Qfua",
  server: false

# In test we don't send emails.
config :rld_live_view_studio, RldLiveViewStudio.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
