#https://gist.github.com/kyanny/2026028
defmodule Fib do
  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n-1) + fib(n-2) end
end

IO.puts Fib.fib(10)

defmodule Random do
  def init do
    :random.seed(:erlang.now)
  end
  def pick_element(list) do
    Enum.at(list, :random.uniform(length(list)) - 1)
  end
end

Random.init
list = Enum.to_list(10..30)
IO.puts Random.pick_element(list)

defmodule Customer do
  def create() do
    waitNum = Random.pick_element(Enum.to_list(1..10))
    fibNum = Random.pick_element(Enum.to_list(10..60))
    thisGuy = spawn(__MODULE__, :loop, [waitNum, fibNum])
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
        send(:manager, {:helpMe, self()})
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
  def create() do
    server = spawn(__MODULE__, :loop, [])
    send(:manager, {:readyToServe, server})
  end
  def loop do
    receive do
      {:calculate, customer, fibNum} ->
        result = Fib.fib(fibNum)
        send(customer, {:done, result})
        send(:manager, {:readyToServe, self()})
    end
    loop
  end
end

defmodule Manager do
  def create() do
    thisGuy = spawn(__MODULE__, :handleRequest, [[], []])
    Process.register(thisGuy, :manager)
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
  def handleRequest([s|servers], [c|customers]) do
    IO.puts("We are in the case with two full arrays, this might not work")
    receive do
      {:readyToServe, newServer} ->
        handleRequest([s] ++ servers ++ [newServer], [c] ++ customers)
      {:helpMe, newCustomer} ->
        send(newCustomer, {:talkToHim, s})
        handleRequest([s] ++ servers, [c] ++ customers ++ [newCustomer])
    end
  end
end

defmodule Baker do
  def init() do
    Process.delete(:manager)
    Manager.create()
    server = Server.create()
    server = Server.create()
    server = Server.create()
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());
    Customer.start(Customer.create());

  end
end
