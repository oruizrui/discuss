# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

# Configures the endpoint.
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

# Postgres username
username = System.fetch_env!("POSTGRES_USERNAME")
# Postgres password
password = System.fetch_env!("POSTGRES_PASSWORD")
# Postgres database
database = System.fetch_env!("POSTGRES_DATABASE_NAME")
# Postgres hostname
hostname = System.fetch_env!("POSTGRES_HOSTNAME")

config :notifier, Notifier.Repo,
  username: username,
  password: password,
  database: database,
  hostname: hostname,
  port: String.to_integer(System.get_env("POSTGRES_PORT", "5432")),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  show_sensitive_data_on_connection_error: true

config :notifier, NotifierWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :discuss, DiscussWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
