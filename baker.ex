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
  def start() do
    waitNum = 2#Random.pick_element(Enum.to_list(1..10))
    fibNum = Random.pick_element(Enum.to_list(10..60))
    thisGuy = spawn(__MODULE__, :loop, [waitNum, fibNum])
    send(thisGuy, {:wait})
  end
  def loop(waitNum, fibNum) do
    receive do
      {:wait} ->
        IO.puts("did something #{waitNum}")
        IO.puts("here's fib #{fibNum}")
        IO.puts("start!")
        #wait fro waitNum the send {manager self() fibNum}
        :timer.sleep(waitNum * 1000) ##to make seconds
        IO.puts("done!")
        #loop(num-1)
        #send(thisGuy, {:wait, thisGuy, num - 1})
    end
  end
end
