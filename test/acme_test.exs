defmodule AcmeTest do
  use ExUnit.Case
  doctest Acme

  test "greets the world" do
    assert Acme.hello() == :world
  end
end
