import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phx_liveview_chat, ChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zqAdkWSQZq3+0vSyp5lGQRxxbE24BpTR52oRRVbffkYGRUlUaZiC0+DACRjLpdvc",
  server: false

# In test we don't send emails.
config :phx_liveview_chat, Chat.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
