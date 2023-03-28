defmodule RldLiveViewStudio.MenuFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RldLiveViewStudio.Menu` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        name: "some name",
        price: "some price",
        tags: "some tags",
        type: "some type"
      })
      |> RldLiveViewStudio.Menu.create_product()

    product
  end
end
