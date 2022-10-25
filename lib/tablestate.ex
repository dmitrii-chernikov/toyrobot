defmodule ToyRobot.TableState do
  alias ToyRobot.{Robot, TableState}
  use GenServer

  def start() do
    options = [name: :table_state]

    if alive?() do
      GenServer.stop(:table_state)
    end
    GenServer.start_link(TableState, :start, options)
  end

  def place(x, y, dir) do
    command = {:place, x, y, dir}

    GenServer.cast(:table_state, command)
  end

  def move() do
    GenServer.cast(:table_state, :move)
  end

  def right() do
    GenServer.cast(:table_state, :right)
  end

  def left() do
    GenServer.cast(:table_state, :left)
  end

  def report() do
    GenServer.call(:table_state, :report)
  end

  def get() do
    GenServer.call(:table_state, :get)
  end

  @impl true
  def init(:start) do
    {:ok, %Robot{x: nil, y: nil, dir: nil}}
  end

  @impl true
  def handle_call(operation, _from, robot) do
    case operation do
      :report ->
        {:reply, Robot.report(robot), robot}

      :get ->
        {:reply, robot, robot}
    end

  end

  @impl true
  def handle_cast(operation, robot) do
    case operation do
      # dir is 0..3, not a bitstring
      {:place, x, y, dir} ->
        {:noreply, Robot.place(x, y, dir)}

      _ ->
        {
          :noreply,
          apply(Robot, operation, [robot])
        }
    end
  end

  @impl true
  def handle_info(msg, robot) do
    IO.puts("Unexpected message: #{inspect(msg)}.")
    {:noreply, robot}
  end

  defp alive?() do
    processes = Process.registered()

    Enum.member?(processes, :table_state)
  end
end
