defmodule Yams.Database.Repo do
  use Ecto.Repo,
    otp_app: :yams,
    adapter: Ecto.Adapters.MyXQL
end
