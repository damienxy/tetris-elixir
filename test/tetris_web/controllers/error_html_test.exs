defmodule TetrisWeb.ErrorHTMLTest do
  use TetrisWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders custom 404 page" do
    assert render_to_string(TetrisWeb.ErrorHTML, "404", "html", []) =~ "Nothing here"
  end

  test "renders 500.html" do
    assert render_to_string(TetrisWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
