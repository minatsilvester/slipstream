defmodule Slipstream.Motorsport do
  @moduledoc """
  The Motorsport context.
  """

  import Ecto.Query, warn: false
  alias Slipstream.Repo

  alias Slipstream.Motorsport.Series

  @doc """
  Returns the list of series.

  ## Examples

      iex> list_series()
      [%Series{}, ...]

  """
  def list_series do
    Repo.all(Series)
  end

  @doc """
  Gets a single series.

  Raises `Ecto.NoResultsError` if the Series does not exist.

  ## Examples

      iex> get_series!(123)
      %Series{}

      iex> get_series!(456)
      ** (Ecto.NoResultsError)

  """
  def get_series!(id), do: Repo.get!(Series, id)

  @doc """
  Creates a series.

  ## Examples

      iex> create_series(%{field: value})
      {:ok, %Series{}}

      iex> create_series(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_series(attrs) do
    %Series{}
    |> Series.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a series.

  ## Examples

      iex> update_series(series, %{field: new_value})
      {:ok, %Series{}}

      iex> update_series(series, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_series(%Series{} = series, attrs) do
    series
    |> Series.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a series.

  ## Examples

      iex> delete_series(series)
      {:ok, %Series{}}

      iex> delete_series(series)
      {:error, %Ecto.Changeset{}}

  """
  def delete_series(%Series{} = series) do
    Repo.delete(series)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking series changes.

  ## Examples

      iex> change_series(series)
      %Ecto.Changeset{data: %Series{}}

  """
  def change_series(%Series{} = series, attrs \\ %{}) do
    Series.changeset(series, attrs)
  end

  alias Slipstream.Motorsport.SeriesSource

  @doc """
  Returns the list of sources for a series.
  """
  def list_series_sources(%Series{} = series), do: list_series_sources(series.id)

  def list_series_sources(series_id) do
    SeriesSource
    |> where([source], source.series_id == ^series_id)
    |> order_by([source], asc: source.priority, asc: source.name)
    |> Repo.all()
  end

  @doc """
  Gets a single series source scoped to its parent series.
  """
  def get_series_source!(%Series{} = series, id), do: get_series_source!(series.id, id)

  def get_series_source!(series_id, id) do
    Repo.get_by!(SeriesSource, id: id, series_id: series_id)
  end

  @doc """
  Creates a source for a series.
  """
  def create_series_source(%Series{} = series, attrs), do: create_series_source(series.id, attrs)

  def create_series_source(series_id, attrs) do
    %SeriesSource{series_id: series_id}
    |> SeriesSource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a series_source.

  ## Examples

      iex> update_series_source(series_source, %{field: new_value})
      {:ok, %SeriesSource{}}

      iex> update_series_source(series_source, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_series_source(%SeriesSource{} = series_source, attrs) do
    series_source
    |> SeriesSource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a series_source.

  ## Examples

      iex> delete_series_source(series_source)
      {:ok, %SeriesSource{}}

      iex> delete_series_source(series_source)
      {:error, %Ecto.Changeset{}}

  """
  def delete_series_source(%SeriesSource{} = series_source) do
    Repo.delete(series_source)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking series_source changes.

  ## Examples

      iex> change_series_source(series_source)
      %Ecto.Changeset{data: %SeriesSource{}}

  """
  def change_series_source(%SeriesSource{} = series_source, attrs \\ %{}) do
    SeriesSource.changeset(series_source, attrs)
  end
end
