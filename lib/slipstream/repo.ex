defmodule Slipstream.Repo do
  use Ecto.Repo,
    otp_app: :slipstream,
    adapter: Ecto.Adapters.Postgres
end
