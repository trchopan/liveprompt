defmodule LivepromptWeb.PageController do
  use LivepromptWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: {LivepromptWeb.Layouts, :with_topnav})
  end
end
