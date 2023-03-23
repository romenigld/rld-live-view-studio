defmodule RldLiveViewStudio.AthletesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RldLiveViewStudio.Athletes` context.
  """

  @doc """
  Generate a athlete.
  """
  def athlete_fixture(attrs \\ %{}) do
    {:ok, athlete} =
      attrs
      |> Enum.into(%{
        emoji: "some emoji",
        name: "some name",
        sport: "some sport",
        status: "some status"
      })
      |> RldLiveViewStudio.Athletes.create_athlete()

    athlete
  end
end
