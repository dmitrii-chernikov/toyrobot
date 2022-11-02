defmodule ToyRobot.TableState do
  alias ToyRobot.{Robot, TableState}
  use GenServer

  @enforce_keys [:x, :y, :robots]
  defstruct x: nil, y: nil, robots: nil

  def start(x_max \\ 5, y_max \\ 5) do
    name = :table_state
    options = [name: name]

    state = %TableState{
      x: if(x_max < 0, do: 0, else: x_max),
      y: if(y_max < 0, do: 0, else: y_max),
      robots: %{}
    }

    if GenServer.whereis(name) do
      GenServer.stop(name)
    end
    GenServer.start(TableState, state, options)
  end

  def resize(x, y), do: cast({:resize, x, y})

  def place(id, x, y, dir) do
    cast({:place, id, x, y, dir})
  end

  def move(id), do: cast({:move, id})

  def left(id), do: cast({:left, id})

  def right(id), do: cast({:right, id})

  def remove(id), do: cast({:remove, id})

  def ids(), do: call(:ids)

  def get(id), do: call({:get, id})

  def dimensions(), do: call(:dimensions)

  @impl true
  def init(initial_value) do
    {:ok, initial_value}
  end

  @impl true
  def handle_call(call, _from, state) do
    case call do
      :ids ->
        {:reply, Map.keys(state.robots), state}

      {:get, id} ->
        {:reply, state.robots[id], state}

      :dimensions ->
        sizes = %{x: state.x, y: state.y}

        {:reply, sizes, state}

      _ ->
        msg = "Wrong call: #{inspect(call)}"

        {:reply, msg, state}
    end
  end

  @impl true
  def handle_cast(cast, state) do
    case cast do
      {:resize, x_new, y_new} ->
        state_new =
          set_size(state, :x, x_new)
          |> set_size(:y, y_new)

        {:noreply, state_new}

      {:place, id, x, y, dir} ->
        handle_cast_place(state, id, x, y, dir)

      {:move, id} ->
        handle_cast_move(state, id)

      {:left, id} ->
        handle_cast_left(state, id)

      {:right, id} ->
        handle_cast_right(state, id)

      {:remove, id} ->
        handle_cast_remove(state, id)

      _ ->
        IO.puts("Wrong cast: #{inspect(cast)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(info, state) do
    IO.puts("Wrong info: #{inspect(info)}")
    {:noreply, state}
  end

  defp handle_cast_place(state, id, x, y, dir) do
    cond do
      !dir ->
        {:noreply, state}

      # this robot is already placed
      state.robots[id] ->
        {:noreply, state}

      !valid_coords?(state, x, y) ->
        {:noreply, state}

      tile_taken?(state, x, y) ->
        {:noreply, state}

      true ->
        new = %Robot{x: x, y: y, dir: dir}
        updated = Map.put(state.robots, id, new)

        {
          :noreply,
          %TableState{state | robots: updated}
        }
    end
  end

  defp handle_cast_move(state, id) do
    robot = state.robots[id]

    if !robot do
      {:noreply, state}
    else
      moved = Robot.move(robot)

      cond do
        !valid_coords?(state, moved.x, moved.y) ->
          {:noreply, state}

        tile_taken?(state, moved.x, moved.y) ->
          {:noreply, state}

        true ->
          {:noreply, put_robot(state, id, moved)}
      end
    end
  end

  defp handle_cast_left(state, id) do
    handle_cast_turn(state, id, &Robot.left/1)
  end

  defp handle_cast_right(state, id) do
    handle_cast_turn(state, id, &Robot.right/1)
  end

  defp handle_cast_turn(state, id, fn_turn) do
    robot = state.robots[id]

    if !robot do
      {:noreply, state}
    else
      turned = fn_turn.(robot)

      {:noreply, put_robot(state, id, turned)}
    end
  end

  defp handle_cast_remove(state, id) do
    robots_new = Map.delete(state.robots, id)

    state_new = %TableState{
      state
      | robots: robots_new
    }

    {:noreply, state_new}
  end

  defp set_size(state, key, value) do
    current = Map.fetch!(state, key)

    cond do
      !is_integer(value) ->
        state

      value < 0 ->
        state

      true ->
        state_new = Map.replace(state, key, value)

        if value < current do
          remove_invalid_robots(state_new)
        else
          state_new
        end
    end
  end

  defp remove_invalid_robots(state) do
    fn_clean = fn {_key, value} ->
      valid_coords?(state, value.x, value.y)
    end

    %TableState{
      state
      | robots: Map.filter(state.robots, fn_clean)
    }
  end

  defp valid_coords?(state, x, y) do
    valid_x = valid_coord?(state, x, :x)
    valid_y = valid_coord?(state, y, :y)

    valid_x && valid_y
  end

  defp valid_coord?(state, value, key) do
    size = Map.fetch!(state, key)

    cond do
      size <= 0 -> false
      value not in 0..(size - 1) -> false
      true -> true
    end
  end

  defp put_robot(state, id, value) do
    robots = state.robots
    robots_new = Map.put(robots, id, value)

    %TableState{state | robots: robots_new}
  end

  defp tile_taken?(state, x, y) do
    fn_check_coord = fn {_id, robot} ->
      robot.x == x && robot.y == y
    end

    Enum.any?(state.robots, fn_check_coord)
  end

  defp call(message) do
    GenServer.call(:table_state, message)
  end

  defp cast(message) do
    GenServer.cast(:table_state, message)
  end
end
