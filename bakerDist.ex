#to run in iex:
#(1)> c "baker.ex"
#(1)> Baker.bake()


defmodule Fib do
  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n-1) + fib(n-2) end
end
#Fib from: https://gist.github.com/kyanny/2026028
#Test Fib
#IO.puts Fib.fib(10)

defmodule Random do
  def init do
    :random.seed(:erlang.now)
  end
  def pick_element(list) do
    Enum.at(list, :random.uniform(length(list)) - 1)
  end
end




defmodule Customer do
  def create(host) do
    waitNum = Random.pick_element(Enum.to_list(1..10))
    fibNum = Random.pick_element(Enum.to_list(10..40))
    IO.puts("Customer being made at: #{host}")
    thisGuy = Node.spawn(host, __MODULE__, :loop, [waitNum, fibNum])
  end
  def start(customer) do
    send(customer, {:wait})
  end
  def loop(waitNum, fibNum) do
    receive do
      {:wait} ->
        IO.puts("Waiting for #{waitNum} than calling fib on #{fibNum}")
        #wait fro waitNum seconds
        :timer.sleep(waitNum * 1000)
        send(:global.whereis_name(:manager), {:helpMe, self()})
        loop(waitNum, fibNum)
      {:done, result} ->
        IO.puts("I'm done! The result was #{result}!")
      {:talkToHim, server} ->
        send(server, {:calculate, self(), fibNum})
        loop(waitNum, fibNum)
    end

  end
end

defmodule Server do
  def create(host) do
    server = Node.spawn(host,__MODULE__, :loop, [])
    IO.puts("Server being made at: #{host}")
    send(:global.whereis_name(:manager), {:readyToServe, server})
  end
  def loop do
    receive do
      {:calculate, customer, fibNum} ->
        IO.puts("Server #{inspect self} is now serving customer #{inspect customer}!!")
        result = Fib.fib(fibNum)
        send(customer, {:done, result})
        send(:global.whereis_name(:manager), {:readyToServe, self()})
    end
    loop
  end
end

defmodule Manager do
  def create() do
    thisGuy = spawn(__MODULE__, :handleRequest, [[], []])
    :global.register_name(:manager, thisGuy)
    thisGuy
  end
  def handleRequest([], []) do
    IO.puts("1: Nobody")
    receive do
      {:readyToServe, newServer} ->
        IO.puts("1: Added server")
        handleRequest([] ++ [newServer], [])
      {:helpMe, newCustomer} ->
        IO.puts("1: Added Customer")
        handleRequest([], [] ++ [newCustomer])
    end
  end
  def handleRequest([s|servers], []) do
    IO.puts("2: Lots of servers, no customers")
    receive do
      {:readyToServe, newServer} ->
        IO.puts("2: Added server")
        handleRequest([s] ++ servers ++ [newServer], [])
      {:helpMe, newCustomer} ->
        IO.puts("2: Sent off pair")
        send(newCustomer, {:talkToHim, s})
        handleRequest(servers, [])
    end
  end
  def handleRequest([], [c|customers]) do
    IO.puts("3: No servers, Lots of customer")
    receive do
      {:readyToServe, newServer} ->
        IO.puts("3: Sent of pair")
        send(c, {:talkToHim, newServer})
        handleRequest([], customers)
      {:helpMe, newCustomer} ->
        IO.puts("3: Added customer")
        handleRequest([], [c] ++ customers ++ [newCustomer])
    end
  end
end

#The "main"
defmodule Baker do
  def bake(numOfServers, numOfCustomers) do
    #Process.delete(:manager) #Delete old manager if one still exists
    Random.init
    Manager.create() #Adding a new node after manager has initialzed requires :manager's node to be restarted
    #create_customers: number of customers, list of hosts -> create x customers with random host form list
    create_servers(numOfServers, Node.list ++ [Node.self])
    create_customers(numOfCustomers, Node.list ++ [Node.self])
  end
  def create_customers(num, hosts) do
    if num > 0 do
      Customer.start(Customer.create(Random.pick_element(hosts)))
      create_customers(num - 1, hosts)
    end
  end
  def create_servers(num, hosts) do
    if num > 0 do
      Server.create(Random.pick_element(hosts))
      create_servers(num - 1, hosts)
    end
  end
end
