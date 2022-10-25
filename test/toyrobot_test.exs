defmodule ToyRobot.Test do
  alias ToyRobot.{Robot, Simulation, TableState}
  use ExUnit.Case

  setup do
    IO.puts("==========")
    TableState.start()
    :ok
  end

  test "reading a file" do
    proper = Simulation.read("assets/proper")

    proper_expected = [
      "PLACE 0,0,NORTH",
      "MOVE",
      "RIGHT",
      "MOVE",
      "LEFT",
      "MOVE",
      "REPORT"
    ]

    assert proper == proper_expected
  end

  test "invalid PLACE commands" do
    Simulation.execute([
      "PLACE A,0,C",
      "PLACE 3,3,ASDF",
      "PLACE 1,B,WEST",
      "PLACE 1,0,",
      "PLACE 5,0,NORTH",
      "PLACE 3,3",
      "PLACE 2, 0,EAST",
      "PLACE 2,2,WEST",
      "PLACE 2, 0,EAST",
      "PLACE 1,3, SOUTH",
      "PLACE 1 3 WEST",
      "place 4,4,WEST",
      "PLACE 4,4,west",
      "REPORT"
    ])

    assert TableState.get == %Robot{x: 2, y: 2, dir: 3}
  end

  test "placing, turning, moving" do
    # any commands before placement are ignored
    Simulation.execute([
      "MOVE",
      "LEFT",
      "PLACE 2,2,WEST",
      "RIGHT",
      "RIGHT",
      "MOVE",
      "REPORT"
    ])

    assert TableState.get == %Robot{x: 3, y: 2, dir: 1}
  end

  test "no valid placement command" do
    Simulation.execute([
      "LEFT",
      "MOVE",
      "RIGHT",
      "REPORT"
    ])

    expected = %Robot{x: nil, y: nil, dir: nil}

    assert TableState.get == expected
  end

  test "spinning in both directions" do
    Simulation.execute([
      "PLACE 2,2,NORTH",
      "LEFT",
      "REPORT",
      "LEFT",
      "LEFT",
      "LEFT",
      "REPORT"
    ])

    assert TableState.get == %Robot{x: 2, y: 2, dir: 0}

    Simulation.execute([
      "PLACE 2,2,WEST",
      "RIGHT",
      "REPORT",
      "RIGHT",
      "RIGHT",
      "RIGHT",
      "REPORT"
    ])

    assert TableState.get == %Robot{x: 2, y: 2, dir: 3}
  end

  test "trying to move off the table" do
    Simulation.execute([
      "PLACE 0,4,NORTH",
      "MOVE",
      "LEFT",
      "MOVE",
      "REPORT"
    ])

    assert TableState.get == %Robot{x: 0, y: 4, dir: 3}

    Simulation.execute([
      "PLACE 4,0,SOUTH",
      "MOVE",
      "LEFT",
      "MOVE",
      "REPORT"
    ])

    assert TableState.get == %Robot{x: 4, y: 0, dir: 1}
  end

  test "invalid table dimensions" do
    commands = [
      # bottom left corner
      "PLACE 0,0,SOUTH",
      "REPORT"
    ]

    no_robot = %Robot{x: nil, y: nil, dir: nil}

    Simulation.execute(commands, 0, 1)

    assert TableState.get == no_robot

    Simulation.execute(commands, 4, -2)

    assert TableState.get == no_robot

    Simulation.execute(commands, 0, -2)

    assert TableState.get == no_robot
  end

  test "other board sizes" do
    commands = [
      # bottom left corner
      "PLACE 0,0,EAST",
      "MOVE",
      "MOVE",
      "MOVE",
      "MOVE",
      "MOVE",
      "REPORT"
    ]

    Simulation.execute(commands, 1, 1)

    assert TableState.get == %Robot{x: 0, y: 0, dir: 1}

    Simulation.execute(commands, 3, 1)

    assert TableState.get == %Robot{x: 2, y: 0, dir: 1}

    Simulation.execute(commands, 6, 6)

    assert TableState.get == %Robot{x: 5, y: 0, dir: 1}
  end
end
