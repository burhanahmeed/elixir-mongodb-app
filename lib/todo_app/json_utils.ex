defmodule TodoApp.JsonUtils do
  @moduledoc """
  JSON utilities
  """

  @doc """
   Extend BSON to encode MongoDB ObjectIds to string
  """

  defimpl Jason.Encoder, for: BSON.ObjectId do
    def encode(id, options) do
      BSON.ObjectId.encode!(id)
      |> Jason.Encoder.encode(options)
    end
  end

  def normaliseMongoId(doc) do
    doc
    |> Map.put('id', doc["_id"]) # Set the id property to the value of _id
    |> Map.delete("_id") # Delete the _id property
  end
end
