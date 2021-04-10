defmodule TetrisWeb.GameLive do
  use TetrisWeb, :live_view
  alias Tetris.Tetromino

  # the mount sets up the initial data for a live view
  # the socket contains the entire info for the state for the live view
  def mount(_params, _session, socket) do
    # trigger tick events
    :timer.send_interval(200, :tick)
    {
      :ok, 
      socket 
      |> new_tetromino
      |> show
    }
  end

 

  # the render happens after any change to the socket
  def render(assigns) do
    # properties of `assigns` can be accessed via @, e.g. @points
    ~L"""
    <% {x, y} = @tetro.location %>
    <section class="phx-hero">
      <h1>Welcome to Tetris</h1>
      <%= render_board(assigns) %>
      <pre>
        <%= inspect @tetro %>
      </pre>
    </section>
    """
  end

  # reducers related to render

  # width and height of the svg are calculated by assuming that 
  # the board will have 10 columns and 20 rows, and
  # every point will be 20x20
  defp render_board(assigns) do
    ~L"""
    <svg width=200" height="400">
      <rect width="200" height="400" style="fill:rgb(0,0,0);" />
      <%= render_points(assigns) %>
    </svg>
    """
  end

  defp render_points(assigns) do
    ~L"""
    <%= for {x, y} <- @points do %>
      <rect 
        width="20" height="20" 
        x="<%= (x - 1) * 20 %>" 
        y="<%= (y - 1) * 20 %>" 
        style="fill:rgb(255,0,0);"
      />
    <% end %>
    """
  end

  defp new_tetromino(socket) do
    assign(socket, tetro: Tetromino.new_random())
  end

  defp show(socket) do
    assign(socket, 
      points: Tetromino.show(socket.assigns.tetro)
    )
  end

  # reducers related to handling events

  # parameter destructuring
  # pattern matching for when it is all the way down (y = 20)
  def down(%{assigns: %{tetro: %{location: {_, 20}}}} = socket) do
    socket
    |> new_tetromino
    |> show
  end

  def down(%{assigns: %{tetro: tetro}} = socket) do
    assign(socket, tetro: Tetromino.down(tetro))
  end

  # handle tick events
  def handle_info(:tick, socket) do
    {:noreply, socket |> down |> show} 
  end
end