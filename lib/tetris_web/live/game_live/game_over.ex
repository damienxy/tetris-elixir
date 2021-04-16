defmodule TetrisWeb.GameLive.GameOver do
  use TetrisWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, 
    assign(socket, score: params["score"] || 0)}
  end

  defp play(socket) do
    push_redirect(socket, to: "/game/playing")
  end

  def handle_event("play", _, socket) do
    {:noreply, play(socket)}
  end
end