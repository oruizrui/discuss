defmodule Discuss.Topic do
  use Discuss.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(topic, params \\ %{}) do
    topic
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end
