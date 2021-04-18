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

  def get_shape(points_with_shape) do
    points_with_shape 
    |> Enum.map(fn {_x, _y, shape} -> shape end)
    |> List.first
  end

  def remove_shape(points_with_shape) do
    points_with_shape
    |> Enum.map(fn point -> Point.remove_shape(point) end)
  end

  def move_one_down(points_with_shape) do
    points_with_shape 
    |> remove_shape
    |> move({0,1})
  end

  def rotate(points, degrees, grid) do
    points
    |> Enum.map(fn point -> Point.rotate(point, degrees, grid) end)
  end

  def valid?(points, junkyard) do
    Enum.all?(points, &Point.valid?(&1, junkyard))
  end
end