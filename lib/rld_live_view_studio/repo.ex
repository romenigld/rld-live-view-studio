defmodule RldLiveViewStudio.Repo do
  use Ecto.Repo,
    otp_app: :rld_live_view_studio,
    adapter: Ecto.Adapters.Postgres
end
