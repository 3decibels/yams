defmodule Yams.Database.CertAuth do
  use Ecto.Schema

  schema "cert_auth" do
    field :serial, :integer
    field :common_name, :string
    field :encoded_cert, :string
    field :expiration, :utc_datetime
    field :active, :boolean
  end

end