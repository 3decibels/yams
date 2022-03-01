defmodule Yams.Database.Repo.Migrations.CreateCertAuth do
  use Ecto.Migration

  def change do
    create table("cert_auth", primary_key: false) do
      add :serial, :bigint, null: false, primary_key: true
      add :common_name, :string, null: false
      add :encoded_cert, :string, null: false
      add :expiration, :utc_datetime, null: false
      add :active, :boolean, null: false
    end
    create index("cert_auth", [:common_name])
  end

end
