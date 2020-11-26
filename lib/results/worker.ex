defmodule Results.Worker do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    config = config()

    port =
      Port.open(
        {:spawn_executable, config.python},
        [
          :binary,
          :nouse_stdio,
          {:packet, 4},
          args: [config.recognize_script, config.model, config.encodings]
        ]
      )

    {:ok, %{port: port, requests: %{}}}
  end

  @default_config [
    python: "python",
    recognize_script: "python_scripts/recognize.py",
    model: "yolov3"
  ]

  def config do
    @default_config
    |> Keyword.merge(Application.get_env(:results, __MODULE__, []))
    |> Enum.map(fn
      {:python, path} ->
        {:python, System.find_executable(path)}

      {option, {:system, env_variable}} ->
        {option, System.get_env(env_variable, @default_config[option])}

      config ->
        config
    end)
    |> Enum.into(%{})
  end

  def request_detection(pid, image) do
    image_id = UUID.uuid4() |> UUID.string_to_binary!()
    request_detection(pid, image_id, image)
  end

  @uuid4_size 16
  def request_detection(pid, image_id, image) when byte_size(image_id) == @uuid4_size do
    GenServer.call(pid, {:detect, image_id, image})
  end

  def handle_call({:detect, image_id, image_data}, {from_pid, _}, worker) do
    Port.command(worker.port, [image_id, image_data])
    worker = put_in(worker, [:requests, image_id], from_pid)
    {:reply, image_id, worker}
  end

  def handle_info(
        {port, {:data, <<image_id::binary-size(@uuid4_size), json_string::binary()>>}},
        %{port: port} = worker
      ) do
    result = get_result!(json_string)

    {from_pid, worker} = pop_in(worker, [:requests, image_id])

    send(from_pid, {:detected, image_id, result})
    {:noreply, worker}
  end

  defp get_result!(json_string) do
    result = Jason.decode!(json_string)

    %{
      shape: %{width: result["shape"]["width"], height: result["shape"]["height"]},
      names: result["names"]
    }
  end

  def await(image_id, timeout \\ 5_000) do
    receive do
      {:detected, ^image_id, result} -> result
    after
      timeout -> {:timeout, image_id}
    end
  end
end
