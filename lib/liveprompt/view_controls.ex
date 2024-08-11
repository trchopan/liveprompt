defmodule Liveprompt.ViewControls do
  @moduledoc """
  The ViewControls context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Liveprompt.Accounts.User
  alias Liveprompt.Repo

  alias Liveprompt.ViewControls.Content

  @doc """
  Returns the list of contents.

  ## Examples

      iex> list_contents()
      [%Content{}, ...]

  """
  def list_contents_by_user(%User{} = user) do
    Repo.all(from c in Content, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])
  end

  @doc """
  Gets a single content.

  Raises `Ecto.NoResultsError` if the Content does not exist.

  ## Examples

      iex> get_content!(123)
      %Content{}

      iex> get_content!(456)
      ** (Ecto.NoResultsError)

  """
  def get_content!(id), do: Repo.get!(Content, id)

  @doc """
  Gets a single content.

  Returns `nil` if Content does not exist.

  ## Examples

      iex> get_content("123e4567-e89b-12d3-a456-426614174000")
      %Content{}

      iex> get_content("000e4567-e89b-12d3-a456-426614174000")
      nil

  """
  @spec get_content(Ecto.UUID.t()) :: Content.t() | nil
  def get_content(id) do
    Repo.get(Content, id)
  end

  @doc """
  Lists the public content that has updated_at older than the given timestamp.

  ## Examples

      iex> ts = DateTime.utc_now() |> DateTime.add(-10, :second)
      iex> list_public_content_older_than(ts)
      [Content{}, ...]

  """
  def list_public_content_older_than(timestamp) when is_struct(timestamp, DateTime) do
    from(c in Content, where: is_nil(c.user_id) and c.updated_at < ^timestamp)
    |> Repo.all()
  end

  @doc """
  Create a public content. Without user association.

  ## Examples

      iex> create_public_content(content)
      {:ok, %Content{}}

  """
  @spec create_public_content(String.t()) :: {:ok, Content.t()}
  def create_public_content(content) do
    %Content{}
    |> Content.changeset(%{name: "Public", content: content})
    |> Repo.insert()
  end

  @doc """
  Creates a content for a user.

  ## Examples

      iex> create_content_for_user(user, %{field: value})
      {:ok, %Content{}}

      iex> create_content_for_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_content_for_user(%User{} = user, attrs \\ %{}) do
    %Content{}
    |> Content.name_changeset(attrs)
    |> put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a content.

  ## Examples

      iex> update_content(content, %{field: new_value})
      {:ok, %Content{}}

      iex> update_content(content, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content(%Content{} = content, attrs) do
    content
    |> Content.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a content.

  ## Examples

      iex> delete_content(content)
      {:ok, %Content{}}

      iex> delete_content(content)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content(%Content{} = content) do
    Repo.delete(content)
  end

  @doc """
  Deletes a content.

  ## Examples

      iex> bulk_delete_contents(content)
      {:ok, %Content{}}

  """
  def bulk_delete_contents(ids) do
    from(c in Content, where: c.id in ^ids) |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content changes.

  ## Examples

      iex> change_content(content)
      %Ecto.Changeset{data: %Content{}}

  """
  def change_content(%Content{} = content, attrs \\ %{}) do
    Content.changeset(content, attrs)
  end

  def change_content_name(%Content{} = content, attrs \\ %{}) do
    Content.name_changeset(content, attrs)
  end
end
