defmodule Project2Main do

    def main(args) do
      cond do
        length(args)!= 3 ->
          IO.puts "Number of arguments do not match"
          Utility.print_valid_format_info()
        true ->
          [numNodesStr, topo, algo] = args
          module = Utility.get_module(algo)
          topology = Utility.get_topology(topo)
          cond do
            Utility.is_parameters_valid(module, numNodesStr, topology) ->
              numNodes = numNodesStr |> String.to_integer() |> Utility.get_num_of_nodes(topology)
              prev = System.monotonic_time(:millisecond)
              MainApplication.start_process(numNodes, topology, module, self())

              receive do
                _ -> 
                  #IO.puts "End"
                  next = System.monotonic_time(:millisecond)
                  IO.puts "Time to converge: #{(next-prev)} milliseconds"
              end
            true ->
              Utility.print_valid_format_info()

          end
      end  
    end


  
end
