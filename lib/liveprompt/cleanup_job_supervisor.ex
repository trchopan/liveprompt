defmodule Liveprompt.CleanupJobSupervisor do
  use Supervisor

  @moduledoc """
  This CleanupJobSupervisor will periodically check and clean up Public content that not in use.
  """
  alias Liveprompt.GenServers.CleanupJob

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    children = [
      {CleanupJob, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
