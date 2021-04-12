defmodule Tetris.Point do
  def origin() do
    {0, 0}
  end

  def left({x, y}) do
    {x-1, y}
  end

  def right({x, y}) do
    {x+1, y}
  end

  def down({x, y}) do
    {x, y+1}
  end

  def move({x, y}, {change_x, change_y}) do
    {x + change_x, y + change_y}
  end

  def transpose({x, y}) do
    {y, x}
  end

  def mirror({x, y}) do
    {5-x, y}
  end

  def flip({x, y}) do
    {x, 5-y}
  end

  def rotate(point, 0) do
    point
  end

  def rotate(point, 90) do
    point
    |> flip
    |> transpose
  end

  def rotate(point, 180) do
    point
    |> mirror
    |> flip
  end
  
  def rotate(point, 270) do
    point
    |> mirror
    |> transpose
  end

  def add_shape({x, y}, shape) do
    {x, y, shape}
  end

  def add_shape(point_with_shape, _shape) do
    point_with_shape
  end
end