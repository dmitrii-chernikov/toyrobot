defmodule ToyRobot.Test do
  alias ToyRobot.{Robot, Simulation, TableState}
  use ExUnit.Case

  setup do
    IO.puts("==========")
    TableState.start()
    :ok
  end

  test "two players" do
    commands = %{
      robot_a: [
        "PLACE 0,2,EAST",
        "MOVE",
        "MOVE",
        "MOVE",
        "REPORT"
      ],
      robot_b: [
        "PLACE 2,0,NORTH",
        "MOVE",
        "MOVE",
        "MOVE",
        "REPORT"
      ]
    }

    robot_a = %Robot{x: 3, y: 2, dir: 1}
    robot_b = %Robot{x: 2, y: 2, dir: 0}

    Enum.map(commands, &execute_async_delayed/1)
    |> Task.await_many()

    assert TableState.get(:robot_a) == robot_a
    assert TableState.get(:robot_b) == robot_b
  end

  test "three players" do
    commands = %{
      first: [
        "PLACE 0,2,EAST",
        "MOVE",
        "MOVE",
        "MOVE",
        "MOVE",
        "REPORT"
      ],
      second: [
        "PLACE 2,0,NORTH",
        "MOVE",
        "MOVE",
        "MOVE",
        "MOVE",
        "REPORT"
      ],
      third: [
        "PLACE 3,0,NORTH",
        "MOVE",
        "MOVE",
        "MOVE",
        "MOVE",
        "REPORT"
      ]
    }

    first = %Robot{x: 3, y: 2, dir: 1}
    second = %Robot{x: 2, y: 2, dir: 0}
    third = %Robot{x: 3, y: 4, dir: 0}

    Enum.map(commands, &execute_async_delayed/1)
    |> Task.await_many()

    assert TableState.get(:first) == first
    assert TableState.get(:second) == second
    assert TableState.get(:third) == third
  end

  defp execute_async_delayed({key, value}) do
    Process.sleep(30)
    execute_async(value, key)
  end

  defp execute_async(
         commands,
         name,
         delay \\ 100
       ) do
    fn_execute = fn ->
      Simulation.execute(commands, name, delay)
    end

    Task.async(fn_execute)
  end
end
