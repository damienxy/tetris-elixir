defmodule TetrisWeb.GameLive do
  use TetrisWeb, :live_view
  alias Tetris.Tetromino

  # the mount sets up the initial data for a live view
  # the socket contains the entire info for the state for the live view
  def mount(_params, _session, socket) do
    # trigger tick events
    :timer.send_interval(500, :tick)
    # `:hello, :world` is a key value pair
    # {:ok, assign(socket, :hello, :world)}
    {
      :ok, 
      socket 
      |> new_tetromino
    }
  end

  def new_tetromino(socket) do
    assign(socket, tetro: Tetromino.new_random())
  end

  # the render happens after any change to the socket
  def render(assigns) do
    # LiveView sigil, imported via line 2 above
    ~L"""
    <% {x, y} = @tetro.location %>
    <section class="phx-hero">
      <pre>
      shape: <%= @tetro.shape %>
      rotation: <%= @tetro.rotation %>
      location: {<%= x %>, <%= y %>}
      
      entire tetro:
      <%= inspect @tetro %>
      </pre>
    </section>
    """
  end

  # parameter destructuring
  def down(%{assigns: %{tetro: tetro}} = socket) do
    assign(socket, tetro: Tetromino.down(tetro))
  end

  # handle tick events
  def handle_info(:tick, socket) do
    {:noreply, down(socket)} 
  end
end