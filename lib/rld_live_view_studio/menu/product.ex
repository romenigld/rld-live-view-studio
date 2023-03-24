defmodule RldLiveViewStudio.Menu.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :image, :string
    field :name, :string
    field :price, :string
    field :tags, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :image, :type, :tags])
    |> validate_required([:name, :description, :price, :image, :type, :tags])
  end
end
