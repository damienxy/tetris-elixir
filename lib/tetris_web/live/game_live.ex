defmodule TetrisWeb.GameLive do
  use TetrisWeb, :live_view
  alias Tetris.Game

  @rotate_keys ["ArrowDown", "ArrowUp", " "]

  # the mount sets up the initial data for a live view
  # the socket contains the entire info for the state for the live view
  def mount(_params, _session, socket) do
    # this makes sure the socket is connected before starting the timer
    if connected?(socket) do
      # trigger tick events
      :timer.send_interval(500, :tick)
    end
    {:ok, new_game(socket)}
  end

  # the render happens after any change to the socket
  def render(assigns) do
    # properties of `assigns` can be accessed via @, e.g. @points
    ~L"""
    <section class="phx-hero">
      <div phx-window-keydown="keystroke">
        <h1>Welcome to Tetris</h1>
        <%= render_board(assigns) %>
        <pre>
          <%= inspect @game.tetro %>
        </pre>
      </div>
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
    <%= for {x, y, shape} <- @game.points do %>
      <rect 
        width="20" height="20" 
        x="<%= (x - 1) * 20 %>"
        y="<%= (y - 1) * 20 %>"
        style="fill:<%= color(shape) %>;"
      />
    <% end %>
    """
  end

  # one-line function syntax
  defp color(:l), do: "red"
  defp color(:j), do: "royalblue"
  defp color(:s), do: "limegreen"
  defp color(:z), do: "yellow"
  defp color(:o), do: "magenta"
  defp color(:i), do: "silver"
  defp color(:t), do: "saddlebrown"
  defp color(_), do: "white"

  defp new_game(socket) do
    assign(socket, game: Game.new())
  end

  defp new_tetromino(socket) do
    assign(socket, game: Game.new_tetromino(socket.assigns.game))
  end

  # reducers related to handling events

  def rotate(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.rotate(game))
  end

  def left(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.left(game))
  end

  def right(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.right(game))
  end

  def down(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.down(game))
  end

  # handle tick events
  def handle_info(:tick, socket) do
    {:noreply, socket |> down} 
  end

  def handle_event("keystroke", %{"key" => key}, socket) when key in @rotate_keys do
    {:noreply, socket |> rotate}
  end
  def handle_event("keystroke", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, socket |> left}
  end
  def handle_event("keystroke", %{"key" => "ArrowRight"}, socket) do
    {:noreply, socket |> right}
  end
end