defmodule RldLiveViewStudio.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :deploy_count, :integer, default: 0
    field :framework, :string
    field :last_commit_message, :string
    field :name, :string
    field :size, :float
    field :status, :string, default: "down"

    timestamps()
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :status, :deploy_count, :size, :framework, :last_commit_message])
    |> validate_required([:name, :size, :framework])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:framework, min: 2, max: 50)
    |> validate_number(:size, greater_than: 0)
    |> validate_inclusion(:status, ["up", "down"])
  end
end
