defmodule Gossip do
  use GenServer
  @max_roumor_to_hear 5
  @max_num_to_tell_gossip 3

  def init(args) do
    
    [topo, nodePos, numNodes] = args
    case topo do
      :twoD ->
        neighboursList = Topology.get_neighbour_of(nodePos, numNodes, :twoD)
        {:ok, {0, :twoD, nodePos, numNodes, neighboursList , false} }
      :imp2D ->
        neighboursList = Topology.get_neighbour_of(nodePos, numNodes, :twoD)
        {:ok, {0, :imp2D, nodePos, numNodes, neighboursList , false} }
      :line ->
        neighboursList = Topology.get_neighbour_of(nodePos, numNodes, :line)
        {:ok, {0, :line, nodePos, numNodes, neighboursList , false} }
      :full ->
        {:ok, {0, :full, nodePos, numNodes, [], false} }
    end 
  end

  def handle_cast(:gossip_msg, {gossipsReceivedCount, topo, nodePos, numNodes, neighboursList, gossipStatus}) do
    cond do
      gossipStatus ->
        {:noreply, {gossipsReceivedCount, topo, nodePos, numNodes, neighboursList, true}}

      gossipsReceivedCount+1 < @max_roumor_to_hear ->
        send_roumor(topo, nodePos, numNodes, neighboursList)
        {:noreply, {gossipsReceivedCount+1, topo, nodePos, numNodes, neighboursList, false} }
      
      true ->
        GenServer.cast(:manager, :gossiping_done)
        {:noreply, {gossipsReceivedCount, topo, nodePos, numNodes, neighboursList, true}}
    end
  end

  def send_roumor(:line, _nodePos, _numNodes, neighboursList) do
    Enum.map(neighboursList, 
      fn(nodeId) ->
        GenServer.cast(:"node#{nodeId}", :gossip_msg)
      end)
  end

  def send_roumor(:twoD, _nodePos, _numNodes, neighboursList) do
    randomNum = Enum.random(1..length(neighboursList))
      Enum.map(1..randomNum, 
        fn(_i) ->
          randomNodeId = Enum.random(neighboursList)
          GenServer.cast(:"node#{randomNodeId}", :gossip_msg)
        end)
  end

  def send_roumor(:full, _nodePos, numNodes, _neighboursList) do
    minNumToSendGossip = min(numNodes, @max_num_to_tell_gossip)
    Enum.map(1..minNumToSendGossip, 
        fn(_i) ->
          randomNodeId = Enum.random(0..numNodes-1)
          GenServer.cast(:"node#{randomNodeId}", :gossip_msg)
        end)
  end

  def send_roumor(:imp2D, _nodePos, numNodes, neighboursList) do
    randomNum = Enum.random(1..length(neighboursList))
      Enum.map(1..randomNum, 
        fn(_i) ->
          randomNodeId = Enum.random(neighboursList)
          GenServer.cast(:"node#{randomNodeId}", :gossip_msg)
        end)
      
      randomNodeId = Enum.random(0..numNodes-1)
      GenServer.cast(:"node#{randomNodeId}", :gossip_msg)
  end

end
