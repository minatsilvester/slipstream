defmodule Slipstream.Ingestion.Formula1CalendarParser do
  @moduledoc false

  def parse(html, year) when is_binary(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("a")
    |> Enum.filter(fn node ->
      case Floki.attribute(node, "href") do
        [href] -> String.starts_with?(href, "/en/racing/#{year}/")
        _ -> false
      end
    end)
    |> Enum.map(&parse_card/1)
    |> Enum.reject(&is_nil/1)
  end

  def extraction_config(year) do
    %{
      "card_selector" => ~s(a[href^="/en/racing/#{year}/"]),
      "round_selector" => ".typography-module_body-2-xs-bold__M03Ei",
      "name_selector" =>
        ".typography-module_display-xl-bold__Gyl5W, .typography-module_display-xl-bold__Gyl5W span",
      "date_selector" =>
        ".typography-module_technical-xs-regular__-W0Gs, .typography-module_technical-m-bold__JDsxP",
      "detail_link_selector" => "a[href^=\"/en/racing/#{year}/\"]",
      "card_kind_selector" => ".typography-module_body-2-xs-bold__M03Ei"
    }
  end

  defp parse_card(node) do
    href = Floki.attribute(node, "href") |> List.first()
    text = node |> Floki.text(sep: " ") |> String.trim()

    with {:ok, kind} <- parse_kind(text),
         {:ok, venue} <- parse_venue(text),
         {:ok, date_label} <- parse_date_label(text) do
      %{
        kind: kind,
        round: parse_round(text),
        venue: venue,
        date_label: date_label,
        href: href,
        raw_text: text
      }
    else
      _ -> nil
    end
  end

  defp parse_kind(text) do
    cond do
      String.contains?(text, "TESTING") -> {:ok, "testing"}
      String.contains?(text, "ROUND") -> {:ok, "race"}
      true -> :error
    end
  end

  defp parse_round(text) do
    case Regex.run(~r/ROUND\s+(\d+)/i, text, capture: :all_but_first) do
      [round] -> String.to_integer(round)
      _ -> nil
    end
  end

  defp parse_venue(text) do
    prefix =
      cond do
        String.contains?(text, "NEXT RACE") -> "NEXT RACE"
        String.contains?(text, "ROUND") -> "ROUND"
        String.contains?(text, "TESTING") -> "TESTING"
        true -> nil
      end

    with true <- not is_nil(prefix),
         [before_formula_one | _] <- String.split(text, "FORMULA 1", parts: 2),
         [_, after_prefix] <- String.split(before_formula_one, prefix, parts: 2) do
      venue =
        after_prefix
        |> String.replace(~r/^\s*\d+\s*/, "")
        |> String.replace("Chequered Flag", "")
        |> String.replace("NEXT RACE", "")
        |> String.trim()

      if venue == "" do
        :error
      else
        {:ok, venue}
      end
    else
      _ -> :error
    end
  end

  defp parse_date_label(text) do
    case Regex.run(
           ~r/(\d{1,2}\s*-\s*\d{1,2}\s+[A-Za-z]{3}|\d{1,2}\s+[A-Za-z]{3}\s*-\s*\d{1,2}\s+[A-Za-z]{3})/,
           text,
           capture: :all_but_first
         ) do
      [date] -> {:ok, String.trim(date)}
      _ -> :error
    end
  end
end
