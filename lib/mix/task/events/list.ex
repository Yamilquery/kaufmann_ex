defmodule Mix.Tasks.Events.List do
  use Mix.Task
  @shortdoc "List Produced and Consumed events"

  def run(_command_line_args) do
    Mix.Task.run("compile")

    load_module()
    |> enumerate_events()
    |> IO.inspect()
  end

  defp load_module do
    case KaufmannEx.Config.event_handler() do
      nil -> raise ArgumentError, "Event Handler module undefined"
      module when is_atom(module) -> module
      _ -> raise ArgumentError, "Unexpected KaufmannEx.Config.event_handler value"
    end
  end

  def enumerate_events(module) do
    unless module_defines?(module, :expected_events) do
      raise ArgumentError, "Event Handler module should use KaufmannEx.EventHandler.EventDocs"
    end

    module.expected_events
  end

  defp module_defines?(module, func) do
    Keyword.has_key?(module.__info__(:functions), func)
  end
end
