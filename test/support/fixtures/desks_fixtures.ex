defmodule RldLiveViewStudio.DesksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RldLiveViewStudio.Desks` context.
  """

  @doc """
  Generate a desk.
  """
  def desk_fixture(attrs \\ %{}) do
    {:ok, desk} =
      attrs
      |> Enum.into(%{
        name: "some name",
        photo_locations: ["option1", "option2"]
      })
      |> RldLiveViewStudio.Desks.create_desk()

    desk
  end
end
