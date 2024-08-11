defmodule Liveprompt.GenServers.CleanupJob do
  use GenServer

  alias Liveprompt.ViewControls

  def start_link(
        cleanup_interval: cleanup_interval,
        cleanup_update_allowance: cleanup_update_allowance
      ) do
    GenServer.start_link(
      __MODULE__,
      %{
        should_continue: true,
        cleanup_interval: cleanup_interval,
        cleanup_update_allowance: cleanup_update_allowance
      },
      name: __MODULE__
    )
  end

  @impl true
  def init(state) do
    schedule_clean_up(state.cleanup_interval)

    {:ok, state}
  end

  @impl true
  def handle_info(:clean_up, state) do
    ts = DateTime.utc_now() |> DateTime.add(-state.cleanup_update_allowance, :millisecond)

    tobe_deleted_ids =
      ViewControls.list_public_content_older_than(ts)
      |> Enum.map(fn %ViewControls.Content{id: id} -> id end)

    if !Enum.empty?(tobe_deleted_ids) do
      {deleted_count, _} = ViewControls.bulk_delete_contents(tobe_deleted_ids)
      IO.inspect(deleted_count, label: "deleted_count")
    end

    if state.should_continue do
      schedule_clean_up(state.cleanup_interval)
    end

    {:noreply, state}
  end

  @impl true
  def handle_call(:stop, _from, state) do
    state = Map.put(state, :should_continue, false)
    IO.inspect(state, label: "state")
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:resume, _from, state) do
    IO.inspect(state, label: "state")
    schedule_clean_up(state.cleanup_interval)
    {:reply, :ok, %{state | should_continue: true}}
  end

  @impl true
  def handle_call(:status, _from, state) do
    IO.inspect(state, label: "state")
    {:reply, :ok, state}
  end

  defp schedule_clean_up(delay) do
    current_time = DateTime.utc_now()
    IO.puts("#{current_time} Scheduling cleanup job #{delay} ms")
    Process.send_after(self(), :clean_up, delay)
  end
end
