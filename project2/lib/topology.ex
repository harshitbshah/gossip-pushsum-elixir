defmodule Topology do

  def get_neighbour_of(nodePos, numNodes, :twoD) do
    n = numNodes |> :math.sqrt |> round # n * n matrix
    r = mod(nodePos, n)
    q = div(nodePos, n)
    [] |> get_left_pos(r, nodePos) |> get_right_pos(n, nodePos) |> get_up_pos(q,n,r) |> get_down_pos(q,r,n)
  end

  def get_neighbour_of(nodePos, numNodes, :line) do
    rightNodeVal = (numNodes - 1)
    cond do
      nodePos == 0 -> 
        [1]

      nodePos == rightNodeVal ->
        [nodePos-1]
      
      true ->
        [nodePos-1, nodePos+1]
    end
  end

  defp get_up_pos(neighbours, q, n, r) do
    cond do
      q > 0 -> # if up present
        neighbours ++ [(q-1)*n+r]
      true ->
        neighbours
    end
  end

  defp get_down_pos(neighbours, q, r, n) do
    cond do
      q < (n-1) -> # if down present
        neighbours ++ [(q+1)*n+r]
      true ->
        neighbours  
    end
  end  

  defp get_left_pos(neighbours, r, nodePos) do
    cond do
      r > 0 -> # if left present
        neighbours ++ [nodePos-1]
      true ->
        neighbours
    end
  end

  defp get_right_pos(neighbours, n, nodePos) do
    cond do
      mod(nodePos+1, n) > 0 -> # if right present
        neighbours ++ [nodePos+1]
      true ->
        neighbours
    end
  end

  defp mod(n,m) when n>=m, do: rem(n,m)

  defp mod(n,m) when n<m, do: n
  
end
