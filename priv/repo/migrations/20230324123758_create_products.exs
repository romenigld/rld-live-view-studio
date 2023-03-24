defmodule RldLiveViewStudio.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :string
      add :price, :string
      add :image, :string
      add :type, :string
      add :tags, :string

      timestamps()
    end
  end
end
