defmodule ToyrobotTest do
  use ExUnit.Case
  doctest Toyrobot

  test "greets the world" do
    assert Toyrobot.hello() == :world
  end
end
