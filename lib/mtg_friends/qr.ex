defmodule MtgFriends.QR do
  @moduledoc """
  Utility service for QR code generation.
  """

  alias QRCode.Render.SvgSettings

  @spec svg(binary()) :: binary() | nil
  def svg(content) when is_binary(content) do
    svg_settings = %SvgSettings{
      scale: 5,
      structure: :minify
    }

    content
    |> QRCode.create(:high)
    |> QRCode.render(:svg, svg_settings)
    |> case do
      {:ok, qr_svg} -> qr_svg
      {:error, _reason} -> nil
    end
  end
end
