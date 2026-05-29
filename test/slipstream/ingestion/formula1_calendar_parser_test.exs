defmodule Slipstream.Ingestion.Formula1CalendarParserTest do
  use ExUnit.Case, async: true

  alias Slipstream.Ingestion.Formula1CalendarParser

  test "parses race and testing cards from the formula1 calendar page shape" do
    html = """
    <a href="/en/racing/2026/canada">
      <div>
        <span>ROUND 5</span>
        <span>Canada</span>
        <span>FORMULA 1 LENOVO GRAND PRIX DU CANADA 2026</span>
        <span>22 - 24 May</span>
      </div>
    </a>
    <a href="/en/racing/2026/pre-season-testing-1">
      <div>
        <span>TESTING</span>
        <span>Bahrain</span>
        <span>FORMULA 1 ARAMCO PRE-SEASON TESTING 1 2026</span>
        <span>11 - 13 Feb</span>
      </div>
    </a>
    """

    config = Formula1CalendarParser.extraction_config(2026)
    entries = Formula1CalendarParser.parse(html, config)

    assert [
             %{
               kind: "race",
               round: 5,
               venue: "Canada",
               date_label: "22 - 24 May",
               href: "/en/racing/2026/canada"
             },
             %{
               kind: "testing",
               round: nil,
               venue: "Bahrain",
               date_label: "11 - 13 Feb",
               href: "/en/racing/2026/pre-season-testing-1"
             }
           ] = entries

    assert Formula1CalendarParser.extraction_config(2026)["card_selector"] ==
             ~s(a[href^="/en/racing/2026/"])
  end
end
