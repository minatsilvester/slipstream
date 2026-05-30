# Calendar Ingestion Plan

Last updated: 2026-05-30

This file is the durable tracker for the Formula 1 calendar ingestion work.  
Keep it updated as tasks land so the plan survives context loss.

## Goal

Build a reliable ingestion path for the official Formula 1 calendar page and persist the current season into the database as the source of truth.

Primary source:
- `https://www.formula1.com/en/racing/2026`

## Architecture Decisions

- Use `Slipstream.Motorsport` as the domain boundary, not direct `Repo` calls from LiveViews.
- Keep calendar data canonical in the database.
- Store scrape provenance separately from the parsed calendar data.
- Use `Req` for HTTP fetches.
- Use `Floki` for HTML parsing.
- Use a `DynamicSupervisor` for transient scraping processes.
- Keep the first implementation manual-trigger only.
- Do not add Oban or scheduled jobs yet.

## Data Model

### `series_sources`
Status: done

Purpose:
- Store the Formula 1 calendar source configuration.

Key fields:
- `series_id`
- `name`
- `url`
- `source_type`
- `format`
- `http_method`
- `request_headers`
- `request_params`
- `extraction_config`
- `is_active`
- `priority`
- `notes`

### `seasons`
Status: done

Purpose:
- Store one calendar season per year for a series.

Proposed fields:
- `series_id`
- `year`
- `is_current`
- `starts_on`
- `ends_on`
- timestamps

Recommended constraint:
- unique index on `[series_id, year]`

### `events`
Status: done

Purpose:
- Store the parsed races and related session data for a season.

Proposed fields:
- `season_id`
- `round`
- `name`
- `venue_name`
- `location`
- `country`
- `starts_on`
- `ends_on`
- `timezone`
- `event_kind`
- `sessions` jsonb
- timestamps

Recommended constraint:
- unique index on `[season_id, round]`

### `ingestion_runs`
Status: not started

Purpose:
- Track each scrape attempt and its result.

Proposed fields:
- `series_source_id`
- `season_id`
- `status`
- `started_at`
- `finished_at`
- `http_status`
- `response_checksum`
- `raw_payload` or `raw_body`
- `error`

## Ingestion Flow

1. Trigger a manual sync for the current year.
2. Load the active Formula 1 series source.
3. Fetch the calendar page with `Req`.
4. Parse the schedule list with `Floki`.
5. Normalize round data into season/event structs. Status: partial
6. Upsert the current season. Status: done
7. Upsert all events for that season. Status: not started
8. Persist an ingestion run record. Status: not started
9. Mark the source success or failure metadata. Status: partial

## Process Model

### Supervisor
Status: done

Use a `DynamicSupervisor` dedicated to ingestion jobs.

Responsibilities:
- start one worker per sync request
- isolate scraper failures
- avoid keeping scraper processes alive when idle

### Worker
Status: done

Proposed worker responsibilities:
- fetch page
- parse HTML
- normalize payload
- persist season and events
- record run outcome

Suggested module shape:
- `Slipstream.Ingestion.CalendarSyncWorker`

## UI Work

### Admin actions
Status: done

Add a manual sync action to the series show page or source page.

### Monitoring
Status: partial

Expose basic sync status in the admin UI:
- last success
- last failure
- failure count
- current season year

## Task Tracker

| Task | Status | Notes |
| --- | --- | --- |
| Add `seasons` table | done | Unique by series/year |
| Add `events` table | done | Season-scoped events schema and CRUD exist |
| Add ingestion run tracking | not started | Keep raw payload and status |
| Add calendar parser for F1 2026 page | done | Parser exists and is tested against the F1 page shape |
| Add dynamic supervisor for scraper workers | done | Added to application supervision tree |
| Add manual sync domain function | done | `Motorsport.sync_season_calendar/1` |
| Add admin sync action | done | Season show page trigger + status display |
| Add event admin LiveViews | done | Nested under seasons for list, show, create, edit, and delete |
| Add season events entry point | done | Season show page links directly to events |
| Add tests for parsing and persistence | partial | Parser and LiveView tests exist; persistence tests remain |

## Notes

- The current app already has `series` and `series_sources`.
- The Formula 1 calendar page currently exposes the round list in the HTML, so an HTML scraper is sufficient for the first pass.
- Prefer upserts for season and event records so repeated syncs update existing rows instead of duplicating them.
