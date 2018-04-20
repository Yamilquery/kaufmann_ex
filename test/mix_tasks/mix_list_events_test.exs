defmodule Mix.Tasks.Events.ListTest do
  use ExUnit.Case

  defmodule TestEventHandler do
    use KaufmannEx.EventHandler.EventDocs

    consumes_event(:first_event)
    produces_event(:second_event)
    def handle_event(:first_event), do: nil

    consumes_event(:second_event)
    produces_event(:third_event)
    def handle_event(:second_event), do: nil

    consumes_event(:"command.test")
    def handle_event(other_events), do: nil
  end

  describe "enumerate_events/1" do
    test "produces a list of events" do
      events = Mix.Tasks.Events.List.enumerate_events(TestEventHandler)

      assert :second_event in events
    end

    test "if module doesn't use EventDocs" do
      defmodule(Sample, do: nil)

      assert_raise ArgumentError, fn ->
        Mix.Tasks.Events.List.enumerate_events(Sample)
      end
    end
  end
end
