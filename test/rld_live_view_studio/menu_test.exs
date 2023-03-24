defmodule RldLiveViewStudio.MenuTest do
  use RldLiveViewStudio.DataCase

  alias RldLiveViewStudio.Menu

  describe "products" do
    alias RldLiveViewStudio.Menu.Product

    import RldLiveViewStudio.MenuFixtures

    @invalid_attrs %{description: nil, image: nil, name: nil, price: nil, tags: nil, type: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Menu.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Menu.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{description: "some description", image: "some image", name: "some name", price: "some price", tags: "some tags", type: "some type"}

      assert {:ok, %Product{} = product} = Menu.create_product(valid_attrs)
      assert product.description == "some description"
      assert product.image == "some image"
      assert product.name == "some name"
      assert product.price == "some price"
      assert product.tags == "some tags"
      assert product.type == "some type"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Menu.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{description: "some updated description", image: "some updated image", name: "some updated name", price: "some updated price", tags: "some updated tags", type: "some updated type"}

      assert {:ok, %Product{} = product} = Menu.update_product(product, update_attrs)
      assert product.description == "some updated description"
      assert product.image == "some updated image"
      assert product.name == "some updated name"
      assert product.price == "some updated price"
      assert product.tags == "some updated tags"
      assert product.type == "some updated type"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Menu.update_product(product, @invalid_attrs)
      assert product == Menu.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Menu.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Menu.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Menu.change_product(product)
    end
  end
end
