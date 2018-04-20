defmodule KaufmannEx.EventHandler.EventDocsTest do
  use ExUnit.Case
  alias KaufmannEx.EventHandler.EventDocs

  # consumes_event(
  # produces_event(
  describe "&consumes_event/1" do
    test "with just one event handler and one expected event type" do
      defmodule SampleModuleXNOP do
        use EventDocs

        consumes_event(:expected_event)
        def handle_event(_), do: nil
      end

      assert [:expected_event] == SampleModuleXNOP.expected_events()
    end

    test "if no handle_event declared" do
      defmodule SampleModuleXNOQ do
        use EventDocs

        consumes_event(:"command.test")
      end

      # TODO: Raise an exception or something? Use @behaviour?
      flunk
    end

    test "if consumed command, produces event" do
      defmodule SampleModuleXNOR do
        use EventDocs

        consumes_event(:"command.test")
        produces_event(:"event.test")
        def handle_event(_), do: nil
      end

      # Could Match on event name, but thats only for 7M patterns.
      # Can inspect tail of handle_event to test what's emitted?

      assert [:"command.test"] == SampleModuleXNOR.expected_events()
      assert [:"event.test"] == SampleModuleXNOR.produced_events()
    end

    test "if consumed event, no inherent produces" do
      defmodule SampleModuleXNOS do
        use EventDocs

        consumes_event(:"event.test")
        def handle_event(_), do: nil
      end
    end
  end

  describe "self documenting" do
    test "Uses pattern match in args" do
      defmodule SampleModuleYAAO do
        alias KaufmannEx.Schemas.Event
        use EventDocs

        def handle_event(%Event{name: :"command.test"}) do
          nil
        end
      end

      assert :"command.test" in SampleModuleYAAO.expected_events()
    end

    test "when multiple handle_event definitions" do
      defmodule SampleModuleYAAP do
        alias KaufmannEx.Schemas.Event
        use EventDocs

        def handle_event(%Event{name: :"command.test"}), do: nil
        def handle_event(%Event{name: :"command.another_test", payload: payload} = event), do: nil
      end

      assert :"command.test" in SampleModuleYAAP.expected_events()
      assert :"command.another_test" in SampleModuleYAAP.expected_events()
    end

    test "extracting event name from function pattern args" do
      empty_args = {:_, [line: 14], nil}

      simple_name_match =
        {:%, [line: 74],
         [
           {:__aliases__, [line: 74, counter: -576_460_752_303_420_863], [:Event]},
           {:%{}, [line: 74], [name: :"command.test"]}
         ]}

      more_complex_name_match =
        {:=, [line: 75],
         [
           {:%, [line: 75],
            [
              {:__aliases__, [line: 75, counter: -576_460_752_303_420_863], [:Event]},
              {:%{}, [line: 75],
               [name: :"command.another_test", payload: {:payload, [line: 75], nil}]}
            ]},
           {:event, [line: 75], nil}
         ]}

      assert nil == EventDocs.get_event_name_from_args([empty_args])

      assert :"command.another_test" == EventDocs.get_event_name_from_args([more_complex_name_match])
      assert :"command.test" == EventDocs.get_event_name_from_args([simple_name_match])
    end
  end
end
