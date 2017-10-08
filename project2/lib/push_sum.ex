defmodule PushSum do
use GenServer
  @num_of_no_change_ratio 3
  @max_num_to_tell_gossip 5
  @condition_ratio 1.0e-10

  def init(args) do
    
    [topo, nodePos, numNodes] = args
    case topo do
      :twoD ->
        neighboursList = Topology.get_neighbour_of(nodePos, numNodes, :twoD)
        #{:ok, {s, w, oldRatio, noChangeCount, :twoD, nodePos, numNodes, neighboursList , false} }
        {:ok, {nodePos/1, 1/1, nodePos/1, 0, :twoD, nodePos, numNodes, neighboursList , false} }
      :imp2D ->
        neighboursList = Topology.get_neighbour_of(nodePos, numNodes, :twoD)
        randomNonNeighbour = get_random_non_neighbour(neighboursList ++ [nodePos], numNodes)
        {:ok, {nodePos/1, 1/1, nodePos/1, 0, :imp2D, nodePos, numNodes, neighboursList ++ randomNonNeighbour , false} }
      :line ->
        neighboursList = Topology.get_neighbour_of(nodePos, numNodes, :line)
        {:ok, {nodePos/1, 1/1, nodePos/1, 0, :line, nodePos, numNodes, neighboursList , false} }
      :full ->
        {:ok, {nodePos/1, 1/1, nodePos/1, 0, :full, nodePos, numNodes, [], false} }
    end 
  end

  def handle_cast({:gossip_msg, sRec, wRec }, {s, w, oldRatio, noChangeCount, topo, nodePos, numNodes, neighboursList, gossipStatus}) do
    sNew = (s+sRec)/2
    wNew = (w+wRec)/2
    newRatio = sNew/wNew
    #IO.puts "Received gossip_msg newRatio #{newRatio} and oldRatio #{oldRatio}"
    cond do
      gossipStatus ->
        if topo != :line do
          send_roumor_multiple(topo, nodePos, numNodes, neighboursList, s, w)
        end
        {:noreply, {s, w, oldRatio, noChangeCount, topo, nodePos, numNodes, neighboursList, true}}

      noChangeCount < @num_of_no_change_ratio and abs(newRatio - oldRatio) < @condition_ratio ->
        send_roumor(topo, nodePos, numNodes, neighboursList, sNew, wNew)
        {:noreply, {sNew, wNew, newRatio, noChangeCount+1, topo, nodePos, numNodes, neighboursList, false} }
      
      noChangeCount < @num_of_no_change_ratio ->
        send_roumor(topo, nodePos, numNodes, neighboursList, sNew, wNew)
        {:noreply, {sNew, wNew, newRatio, 0, topo, nodePos, numNodes, neighboursList, false} }
      
      true ->
        #IO.puts "node#{nodePos} completed converge with avg #{newRatio}"
        GenServer.cast(:manager, :gossiping_done)
        if topo != :line do
          send_roumor_multiple(topo, nodePos, numNodes, neighboursList, s, w)
        end
        {:noreply, {s, w, newRatio, noChangeCount, topo, nodePos, numNodes, neighboursList, true}}
    end
  end

  def send_roumor_multiple(:full, _nodePos, numNodes, _neighboursList, s, w) do
    minNumToSendGossip = min(numNodes, @max_num_to_tell_gossip)
    Enum.map(1..minNumToSendGossip, 
        fn(_i) ->
          randomNodeId = Enum.random(0..numNodes-1)
          GenServer.cast(:"node#{randomNodeId}", {:gossip_msg, s, w})
        end)
  end

  def send_roumor_multiple(_topo, _nodePos, _numNodes, neighboursList, s, w) do
    randomNum = Enum.random(1..length(neighboursList))
      Enum.map(1..randomNum, 
        fn(_i) ->
          randomNodeId = Enum.random(neighboursList)
          GenServer.cast(:"node#{randomNodeId}", {:gossip_msg, s, w})
      end)
  end

  def send_roumor(:line, _nodePos, _numNodes, neighboursList, s, w) do
      nodeId = Enum.random(neighboursList)
      GenServer.cast(:"node#{nodeId}", {:gossip_msg, s, w})
  end

  def send_roumor(:twoD, _nodePos, _numNodes, neighboursList, s, w) do
    randomNodeId = Enum.random(neighboursList)
    GenServer.cast(:"node#{randomNodeId}", {:gossip_msg, s, w})
  end

  def send_roumor(:full, _nodePos, numNodes, _neighboursList, s, w) do
    randomNodeId = Enum.random(0..numNodes-1)
    GenServer.cast(:"node#{randomNodeId}", {:gossip_msg, s, w})
  end

  def send_roumor(:imp2D, _nodePos, _numNodes, neighboursList, s, w) do
      randomNodeId = Enum.random(neighboursList)
      GenServer.cast(:"node#{randomNodeId}", {:gossip_msg, s, w})
      
  end

  def get_random_non_neighbour(neighboursList, numNodes) do
    randomNode = Enum.random(0..numNodes-1) 
    if Enum.find(neighboursList, fn(x) -> x == randomNode end) == nil do
      [randomNode]
    else
      get_random_non_neighbour(neighboursList, numNodes)
    end
  end
end
