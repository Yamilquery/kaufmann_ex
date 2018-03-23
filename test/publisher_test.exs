defmodule KuafmannEx.PublisherTest do
  use ExUnit.Case
  alias KaufmannEx.Publisher


  describe "&produce/3" do
      test "publishes error if schema error" do
        #event_name =  mock_register_schema(StreamData.string(:printable))
        # produce(StreamData.string(:printable), event_name, StreamData.term())
      end

      test "publishes descriptive error from schema mismatch" do
        # extract something useful from error_message
      end

      test "raise exception if schema exception" do
        # something upstream is broken
      end


      test "raises exception on produce error" do
        # something something external is broken
      end
  end

  describe "&cmd_to_event/1" do
    test "transforms a command into an event" do
      assert :"event.test.call" == Publisher.cmd_to_event(:"event.test.call")
    end
  end

  describe "&publish/3" do
    test "producer_mod undefined"
  end

  describe "&log_time_took/2" do
    test "if timestamp nil nothing interesting happens" do
      assert nil == Publisher.log_time_took(nil, nil)
    end
  end

end
