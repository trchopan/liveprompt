defmodule Liveprompt.ViewControlsTest do
  use Liveprompt.DataCase

  alias Liveprompt.ViewControls

  describe "contents" do
    alias Liveprompt.ViewControls.Content

    import Liveprompt.ViewControlsFixtures

    @invalid_attrs %{name: nil, content: nil}

    test "list_contents/0 returns all contents" do
      content = content_fixture()
      assert ViewControls.list_contents() == [content]
    end

    test "get_content!/1 returns the content with given id" do
      content = content_fixture()
      assert ViewControls.get_content!(content.id) == content
    end

    test "create_content/1 with valid data creates a content" do
      valid_attrs = %{name: "some name", content: "some content"}

      assert {:ok, %Content{} = content} = ViewControls.create_content(valid_attrs)
      assert content.name == "some name"
      assert content.content == "some content"
    end

    test "create_content/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ViewControls.create_content(@invalid_attrs)
    end

    test "update_content/2 with valid data updates the content" do
      content = content_fixture()
      update_attrs = %{name: "some updated name", content: "some updated content"}

      assert {:ok, %Content{} = content} = ViewControls.update_content(content, update_attrs)
      assert content.name == "some updated name"
      assert content.content == "some updated content"
    end

    test "update_content/2 with invalid data returns error changeset" do
      content = content_fixture()
      assert {:error, %Ecto.Changeset{}} = ViewControls.update_content(content, @invalid_attrs)
      assert content == ViewControls.get_content!(content.id)
    end

    test "delete_content/1 deletes the content" do
      content = content_fixture()
      assert {:ok, %Content{}} = ViewControls.delete_content(content)
      assert_raise Ecto.NoResultsError, fn -> ViewControls.get_content!(content.id) end
    end

    test "change_content/1 returns a content changeset" do
      content = content_fixture()
      assert %Ecto.Changeset{} = ViewControls.change_content(content)
    end
  end
end
