defmodule DetectiveGameTest do
  use ExUnit.Case
  doctest DetectiveGame

  test "greets the world" do
    assert DetectiveGame.hello() == :world
  end
end
