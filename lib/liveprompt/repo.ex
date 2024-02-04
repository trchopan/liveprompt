defmodule Liveprompt.Repo do
  use Ecto.Repo,
    otp_app: :liveprompt,
    adapter: Ecto.Adapters.Postgres
end
