defmodule Tetris.Points do
  alias Tetris.Point

  def move(points, change) do
    points
    |> Enum.map(fn point -> Point.move(point, change) end)
  end
end