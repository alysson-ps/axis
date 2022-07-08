defmodule Axis.Http do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://gitlab.com/api/v4/" <> url
  end
end
