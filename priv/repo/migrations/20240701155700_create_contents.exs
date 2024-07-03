defmodule Liveprompt.Repo.Migrations.CreateContents do
  use Ecto.Migration

  def change do
    create table(:contents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :content, :text
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
