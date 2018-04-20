defmodule Sample.EventHandler do
  use KaufmannEx.EventHandler.EventDocs
  alias KaufmannEx.Schemas.Event
  alias Sample.Publisher

  expects_event(:"command.test")

  def given_event(%Event{name: :"command.test", payload: payload} = event) do
    # Do something with event payload 😁
    Publisher.publish(Publisher.coerce_event_name(event.name), payload, event.meta)
  end

  expects_event(:anything)
  def given_event(event), do: IO.inspect(event.name)
end
