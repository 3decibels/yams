defmodule Yams.Database.CertAuth do
  use Ecto.Schema

  schema "cert_auth" do
    add :serial, :integer
    add :common_name, :string
    add :encoded_cert, :string
    add :expiration, :utc_datetime
    add :active, :boolean
  end

end