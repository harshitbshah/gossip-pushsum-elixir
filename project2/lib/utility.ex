defmodule Utility do

  def is_parameters_valid(module, numNodesStr, topo) do
    if module != false and isInteger(numNodesStr) and topo != false do
      if(String.to_integer(numNodesStr) < 1) do
        IO.puts "NumNodes should be more than 0"
        false
      else
        true
      end
    else
      false
    end
  end

  def get_num_of_nodes(numNodes, topo) do
    cond do
      topo == :twoD or topo == :imp2D ->
        nearest_square(numNodes)

      true->
        numNodes
    end
   end 

  defp nearest_square(numNodes) do
    sqRootCeilValue = numNodes |> :math.sqrt() |> Float.ceil() |> round
    sqRootCeilValue * sqRootCeilValue
  end

  def get_module(algo) do
    cond do
      String.equivalent?(algo, "gossip") == true ->
        Gossip
      String.equivalent?(algo, "push-sum") == true ->
        PushSum
      true ->
        IO.puts "Invalid algorithm parameter"
        false
    end
  end

  def get_topology(topo) do
    cond do
      String.equivalent?(topo, "full") == true ->
        :full
      String.equivalent?(topo, "2D") == true ->
        :twoD
      String.equivalent?(topo, "line") == true ->
        :line
      String.equivalent?(topo, "imp2D") == true ->
        :imp2D
      true ->
        false
    end
  end

  defp isInteger(val) do
        try do
          _ = String.to_integer(val)
          true
        catch
          _what, _value -> 
            IO.puts "numNodes must be integer"
            false
        end
    end

  def print_valid_format_info do
    IO.puts "Valid format:"
    IO.puts "project2 numNodes topology algorithm"
    IO.puts "  numNodes: Integer type"
    IO.puts "  topology: full, 2D, line, imp2D"
    IO.puts "  algorithm: gossip, push-sum"
  end
end
