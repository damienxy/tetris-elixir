defmodule Tetris.Points do
  alias Tetris.Point

  def move(points, change) do
    points
    |> Enum.map(fn point -> Point.move(point, change) end)
  end

  def add_shape(points, shape) do
    points 
    |> Enum.map(fn point -> Point.add_shape(point, shape) end)
  end

  def rotate(points, degrees) do
    points
    |> Enum.map(fn point -> Point.rotate(point, degrees) end)
  end

  def valid?(points) do
    Enum.all?(points, &Point.in_bounds?/1)
  end

end