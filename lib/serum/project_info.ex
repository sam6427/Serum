defmodule Serum.ProjectInfo do
  @moduledoc """
  This module defines a struct for storing Serum project metadata.
  """

  import Serum.Util

  @enforce_keys [
    :site_name, :site_description, :base_url, :author, :author_email
  ]

  @accepted_keys [
    "site_name", "site_description", "base_url", "author", "author_email",
    "date_format", "preview_length", "list_title_all", "list_title_tag"
  ]

  defstruct [
    :site_name, :site_description, :base_url, :author, :author_email,
    date_format: "{YYYY}-{0M}-{0D}", preview_length: 200,
    list_title_all: "All Posts", list_title_tag: "Posts Tagged ~s"
  ]

  @type t :: %Serum.ProjectInfo{}

  @doc "A helper function for creating a new ProjectInfo struct."
  @spec new(map) :: t

  def new(map) do
    default = %Serum.ProjectInfo{
      site_name: "", site_description: "", base_url: "",
      author: "", author_email: ""
    }
    map_checked =
      map |> check_date_format() |> check_list_title_format()
    map_new =
      for {k, v} <- map_checked, k in @accepted_keys, into: %{} do
        {String.to_atom(k), v}
      end
    Map.merge default, map_new
  end

  @spec check_date_format(map) :: map

  defp check_date_format(map) do
    case map["date_format"] do
      nil -> map
      fmt when is_binary(fmt) ->
        case Timex.validate_format fmt do
          :ok -> map
          {:error, message} ->
            warn "Invalid date format string `date_format`:"
            warn "  " <> message
            warn "The default format string will be used instead."
            Map.delete map, "date_format"
        end
    end
  end

  @spec check_list_title_format(map) :: map

  defp check_list_title_format(map) do
    try do
      case map["list_title_tag"] do
        nil -> map
        fmt when is_binary(fmt) ->
          :io_lib.format(fmt, ["test"])
          map
      end
    rescue
      _e in ArgumentError ->
        warn "Invalid post list title format string `list_title_tag`."
        warn "The default format string will be used instead."
        Map.delete map, "list_title_tag"
    end
  end
end
