defmodule Yams.Database.Repo.Migrations.CreateCertAuth do
  use Ecto.Migration

  def change do
    create table(:cert_auth) do
      add :serial, :integer, null: false
      add :common_name, :string, null: false
      add :encoded_cert, :string, null: false
      add :expiration, :utc_datetime, null: false
      add :active, :boolean, null: false
    end
  end

end
