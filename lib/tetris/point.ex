defmodule Tetris.Point do
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

  def rotate(point, 0, _grid) do
    point
  end
  def rotate(point, 90, grid) do
    point
    |> flip(grid)
    |> transpose
  end
  def rotate(point, 180, grid) do
    point
    |> mirror(grid)
    |> flip(grid)
  end
  def rotate(point, 270, grid) do
    point
    |> mirror(grid)
    |> transpose
  end

  def add_shape({x, y}, shape) do
    {x, y, shape}
  end
  def add_shape(point_with_shape, _shape) do
    point_with_shape
  end

  def remove_shape({x, y, _shape}) do
    {x, y}
  end

  def valid?(point, junkyard) do
    in_bounds?(point) and !collide?(point, junkyard)
  end

  defp transpose({x, y}) do
    {y, x}
  end

  defp mirror({x, y}, grid) do
    {grid - x, y}
  end

  defp flip({x, y}, grid) do
    {x, grid - y}
  end

  defp in_bounds?({x, y, _shape}), do: in_bounds?({x, y})
  defp in_bounds?({x, _y}) when x < 1, do: false
  defp in_bounds?({x, _y}) when x > 10, do: false
  defp in_bounds?({_x, y}) when y > 20, do: false
  defp in_bounds?(_point), do: true

  defp collide?({x, y, _shape}, junkyard), do: collide?({x, y}, junkyard)
  defp collide?(point, junkyard), do: !!junkyard[point]
end