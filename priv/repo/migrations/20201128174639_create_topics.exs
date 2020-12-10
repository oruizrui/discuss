defmodule Discuss.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string

      timestamps()
    end
  end
end
