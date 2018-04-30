defmodule KaufmannEx.EventHandler.EventDocs do
  @moduledoc """
  DSL for documenting event handlers.

  Document events explicity with macros `consumes_event` and `produces_event`

  Expected events are also parsed from patterns specified in `handle_event` arguments.

  ```
  def handle_event(%Event{name: :"Event_name"})
  ```

  In the future this DSL will allow event handlers to describe themselves to a central repo
  """
  alias KaufmannEx.Schemas.Event
  alias KaufmannEx.EventHandler.EventDocs

  @doc "Handle an Event"
  @callback handle_event(Event.t()) :: atom

  defmacro __using__(opts) do
    quote do
      infer_events = !!unquote(opts)[:infer_events]


      Module.register_attribute(__MODULE__, :expected_events, accumulate: true)
      Module.register_attribute(__MODULE__, :produced_events, accumulate: true)

      @before_compile EventDocs
      @on_definition EventDocs
      @behaviour EventDocs
      @event_docs_infer_events = infer_events

      import EventDocs
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def expected_events, do: List.flatten(@expected_events) |> Enum.map(&elem(&1, 0)) |> Enum.uniq()
      def produced_events do
        events = List.flatten(@produced_events) |> Enum.map(&elem(&1, 0)) |> Enum.uniq()
        if @event_docs_infer_events do
          expected_events
        end
      end
    end
  end

  @doc """
  Callback to extract expected events from `handle_event` arguments
  """
  def __on_definition__(env, _kind, :handle_event, args, _guards, _body) when length(args) == 1 do
    case get_event_name_from_args(args) do
      nil -> nil
      event -> Module.put_attribute(env.module, :expected_events, {event, env.line})
    end
  end

  def __on_definition__(_, _, _, _, _, _), do: nil

  def get_event_name_from_args(args) do
    args
    |> Enum.map(&extract_event_name/1)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> List.first()
  end

  defp extract_event_name({_v, _l, rest}) when is_list(rest),
    do: Enum.map(rest, &extract_event_name/1)

  defp extract_event_name({_v, _l, rest}), do: extract_event_name(rest)
  defp extract_event_name({:name, name}), do: name
  defp extract_event_name(_unexpected), do: nil

  defmacro consumes_event(event_name) do
    quote do
      @expected_events {unquote(event_name), __ENV__.line}
    end
  end

  defmacro produces_event(event_name) do
    quote do
      @produced_events {unquote(event_name), __ENV__.line}
    end
  end
end
