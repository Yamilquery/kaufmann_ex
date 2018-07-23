defmodule KaufmannEx.PublisherBenchmark do
  import ExProf.Macro

  alias KafkaEx.Protocol.Produce.Message
  alias KafkaEx.Protocol.Produce.Request

  @topic KaufmannEx.Config.default_topic()
  @message_name :"test.event.publish"
  ## Helpers
  def rand(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end

  ## Functions under test
  def kafk_ex_publish(input) do
    :ok = KafkaEx.produce(@topic, 0, Poison.encode!(input))
  end

  def encode_message(input) do
    {:ok, _} = KaufmannEx.Schemas.encode_message(@message_name, input)
  end

  def get_partition_count(_) do
    KaufmannEx.Publisher.get_partitions_count(@topic)
  end

  def kaufmann_produce(input) do
    :ok = KaufmannEx.Publisher.produce(@topic, @message_name, input, %{})
  end

  def kaufmann_publish(input) do
    :ok = KaufmannEx.Publisher.publish(@message_name, input, %{}, @topic)
  end

  def choose_partition(_) do
    {:ok, _} = KaufmannEx.Publisher.PartitionSelector.choose_partition(@topic, %{})
  end

  def produce_mock(input) do
    with {:ok, payload} <- KaufmannEx.Schemas.encode_message(@message_name, input),
         {:ok, partition} <- KaufmannEx.Publisher.PartitionSelector.choose_partition(@topic, %{}) do
      message = %Message{value: payload, key: to_string(@message_name)}

      produce_request = %Request{
        partition: 0,
        topic: @topic,
        messages: [message]
      }

      KafkaEx.produce(produce_request)
    end
  end

  def setup do
    # Assumes correclty configured Schemas &c, as if used in Docker-Compose
    [{:ok, _, _} | _] = KaufmannEx.ReleaseTasks.MigrateSchemas.migrate_schemas("test/support")
    {:ok, _} = KafkaEx.start([], [])
    {:ok, _} = KaufmannEx.Publisher.PartitionSelector.start_link()
    partitions = 1
    # Call to ensure topic exists
    topic = KaufmannEx.Config.default_topic()
    _metadata = KafkaEx.metadata(topic: topic)
  end

  def run do
    setup
    topic = KaufmannEx.Config.default_topic()

    event_metadata = %{
      message_id: Nanoid.generate(),
      emitter_service: KaufmannEx.Config.service_name(),
      emitter_service_id: KaufmannEx.Config.service_id(),
      callback_id: nil,
      message_name: to_string(@message_name),
      timestamp: DateTime.to_string(DateTime.utc_now())
    }

    :ok = KaufmannEx.Publisher.publish(@message_name, %{payload: "test", meta: event_metadata})

    :ok = KafkaEx.produce(topic, 0, "Hello")
    :ok = Application.put_env(:logger, :level, :warn)

    Logger.configure(level: :warn)

    Benchee.run(
      %{
        "KaufmannEx.publish" => fn input ->
          :ok = KaufmannEx.Publisher.publish(@message_name, input)
        end,
        "kafkaEx.produce" => &kafk_ex_publish/1,
        "KaufmannEx.Schemas.encode_message" => &encode_message/1
      },
      inputs: %{
        "simple payload" => %{payload: "test", meta: event_metadata}
      }
      # before_scenario: global_setup
    )
  end

  def profile do
    # setup

    event_metadata = %{
      message_id: Nanoid.generate(),
      emitter_service: KaufmannEx.Config.service_name(),
      emitter_service_id: KaufmannEx.Config.service_id(),
      callback_id: nil,
      message_name: to_string(@message_name),
      timestamp: DateTime.to_string(DateTime.utc_now())
    }

    profile do
      :ok = KaufmannEx.Publisher.publish(@message_name, %{payload: "test", meta: event_metadata})
    end
  end
end

# Simple Benchmark of how many messages we can shove through a Publisher

# Publisher informs on Debug, disable for sanities sake

# Operating System: Linux"
# CPU Information: Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz
# Number of Available Cores: 8
# Available memory: 15.40 GB
# Elixir 1.6.6
# Erlang 20.3.8.2

# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 0 μs
# parallel: 1
# inputs: 1ong string
# Estimated total run time: 7 s

# Benchmarking Simple Publish with input 1ong string...

# ##### With input 1ong string #####
# Name                                    ips          average    deviation         median         99th %
# KaufmannEx.Schemas.encode_message       44.38 K       22.53 μs    ±61.15%          21 μs          53 μs
# kafkaEx.produce                         23.84 K       41.94 μs  ±1100.51%          28 μs          54 μs
# KaufmannEx.publish (v0.2.2)             77.30         12.94 ms    ±49.47%       11.31 ms       44.14 ms
# KaufmannEx.publish (v0.2.3)             12.97 K       77.12 μs    ±17.23%          71 μs         119 μs
