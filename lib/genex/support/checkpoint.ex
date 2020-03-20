defmodule Genex.Support.Checkpoint do
  alias Genex.Support.Genealogy
  alias Genex.Support.HallOfFame

  @moduledoc """
  Utilities for saving and loading from checkpoints.
  """

  def save(population, path \\ "") do
    {:ok, dtg} = DateTime.now("Etc/UTC")
    prefix =
      dtg
      |> DateTime.to_string()
      |> String.replace(" ", "_")

    # Save the Hall of Fame to a file
    hof =
      prefix
      |> Kernel.<>(".hall_of_fame")
      |> String.to_charlist()
    {:ok, hof_name} = HallOfFame.save()
    {:ok, hof_bin} = File.read(hof_name)

    # Save the Geneaology tree to a file
    dot =
      prefix
      |> Kernel.<>(".history")
      |> String.to_charlist()
    {:ok, dot_bin} =
      population.history
      |> Genealogy.export()
    dot_bin = String.to_charlist(dot_bin)

    # Serialize Population
    pop =
      prefix
      |> Kernel.<>(".population")
      |> String.to_charlist()
    pop_bin = :erlang.term_to_binary(population)

    # path
    path = if path == "", do: File.cwd!, else: path

    # Save all to zip
    files = [{hof, hof_bin}, {dot, dot_bin}, {pop, pop_bin}]
    :zip.create(String.to_charlist(prefix <> ".zip"), files, [cwd: String.to_charlist(path)])
  end
end
