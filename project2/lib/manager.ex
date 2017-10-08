defmodule MainApplication do
  use GenServer
  @convergence 90

  def start_process(numNodes, topo, algo, mainPid) do
    IO.puts "Starting #{topo} topology with #{numNodes} nodes"
    {:ok, _pid} = GenServer.start_link(__MODULE__, [numNodes, topo, algo, mainPid], name: :manager)
  end
  
  def init(config) do
    [numNodes, topo, algo, _mainPid] = config
    start_n_actors(numNodes-1, algo, topo, numNodes)
    #IO.puts "process started"
    {:ok, {config, 0} }
  end

  defp start_n_actors(-1, _algo, _topo, _numNodes) do
    GenServer.cast(:manager, :actors_created)
  end

  defp start_n_actors(numNode, algo, topo, totalNodes) do
    GenServer.start_link(algo, [topo, numNode, totalNodes], name: :"node#{numNode}")
    start_n_actors(numNode-1, algo, topo, totalNodes)
  end

  #callbacks
  def handle_cast(:actors_created, state) do
    { config, _} = state
    [numNodes, _topo, algo, _mainPid] = config
    
    case algo do
      Gossip ->
        randomPos = Enum.random(0..(numNodes-1))
        :"node#{randomPos}" |> GenServer.cast(:gossip_msg)
        {:noreply, state}
      PushSum ->
        randomPos = Enum.random(0..(numNodes-1))
        :"node#{randomPos}" |> GenServer.cast({:gossip_msg, 0, 0})
        {:noreply, state}
      end
  end

  def handle_cast(:gossiping_done, {config, doneGossipingCount}) do
    [numNodes, topo, algo, mainPid] = config
    cond do
      (doneGossipingCount+1)/numNodes >= @convergence/100 or (topo == :line and algo == PushSum) ->
        #IO.puts "#{doneGossipingCount+1} converged"
        send(mainPid, :close)
         {:noreply, {config, doneGossipingCount+1 } }
      
      true ->
         {:noreply, {config, doneGossipingCount+1 } }
    end
  end

end
