defmodule Serum.PageInfo do
  @moduledoc "This module defines PageInfo struct."

  alias Serum.Build

  @type t :: %Serum.PageInfo{}
  @type state :: Build.state

  defstruct [:file, :title, :label, :group, :order, :url]

  @doc "A helper function for creating a new PageInfo struct."
  @spec new(binary, map, state) :: t

  def new(filename, header, state) do
    {_, url} = get_type_and_destpath(filename, state)
    %Serum.PageInfo{
      file: filename,
      title: header[:title],
      label: header[:label] || header[:title],
      group: header[:group],
      order: header[:order],
      url: state.project_info.base_url <> url
    }
  end

  @doc """
  Given a page source file name, this function extracts source file extension
  and generates destination file name (`.html`).
  """
  @spec get_type_and_destpath(binary, state) :: {binary, binary}

  def get_type_and_destpath(srcpath, state) do
    [type|temp] = srcpath |> String.split(".") |> Enum.reverse
    temp = (type == "eex") && tl(temp) || temp
    destpath =
      temp
      |> Enum.reverse
      |> Enum.join(".")
      |> String.replace_prefix("#{state.src}pages/", "")
      |> Kernel.<>(".html")
    {type, destpath}
  end
end

defimpl Inspect, for: Serum.PageInfo do
  def inspect(info, _opts), do: ~s(#Serum.PageInfo<"#{info.title}">)
end
