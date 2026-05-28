defmodule SlipstreamWeb.PageController do
  use SlipstreamWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
