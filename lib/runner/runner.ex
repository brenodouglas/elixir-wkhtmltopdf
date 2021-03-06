defmodule Wkhtmltopdf.Runner do
  use GenServer

  ### GenServer API

  @doc """
  GenServer.init/1 callback
  """
  def init(state), do: {:ok, state}

  @doc """
  GenServer.handle_cast/2 callback
  """
  def handle_cast({:exec, command, args}, state) do
    task = Task.async(fn -> System.cmd command, args end)
    {:noreply, [Task.await(task)|state]}
  end

  ### Client API / Helper methods
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def exec(command, args), do: GenServer.cast(__MODULE__, {:exec, command, args})
end