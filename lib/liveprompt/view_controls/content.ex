defmodule Liveprompt.ViewControls.Content do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contents" do
    field :name, :string
    field :content, :string

    belongs_to :user, Liveprompt.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{}

  @doc false
  def changeset(content, attrs \\ %{}) do
    content
    |> cast(attrs, [:name, :content])
    |> validate_required([:name, :content])
    |> validate_name()
    |> validate_content()
  end

  def name_changeset(content, attrs \\ %{}) do
    content
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_name()
  end

  def validate_name(changeset) do
    changeset
    |> validate_length(:name, max: 255)
  end

  def validate_content(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:content, max: 20_000)
  end
end
