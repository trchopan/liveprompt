defmodule Liveprompt.ViewControlsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Liveprompt.ViewControls` context.
  """

  @doc """
  Generate a content.
  """
  def content_fixture(attrs \\ %{}) do
    {:ok, content} =
      attrs
      |> Enum.into(%{
        content: "some content",
        name: "some name"
      })
      |> Liveprompt.ViewControls.create_content()

    content
  end
end
