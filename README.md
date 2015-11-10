# BakerAlgorithmElixer
###Parallel Systems Elixer Lab

Thomas Harren and Brennan Gensch created this project to try out Elixer by solving the Baker's Algorthim.

We generate a series of servers and customers. Then we have a manager who coordinates the serving, which consists of having the server caluculte fibonacci for the customer. Problem description here: https://docs.google.com/document/d/1R-SpUEgKPDznJjozv5kdUNWxznwx-wSYnwo3CNqn7UA/edit

<hr>

####To run the simple version in iex:
#####(1)> c "baker.ex"
#####(2)> Baker.bake()

####To run the distrubuted version in iex:
######Start iex on the box (aka host) of your choice, repeat this step for each box
#####(1)> iex --sname *nameOfNode* --cookie frogs --erl "-kernel inet_dist_listen_min 60001 inet_dist_listen_max 60100" bakerDist.ex
######Then connect the nodes using things using Node.connect :'nodeName@hostName'
#####(2)> Node.connect :'node1@bebop'
#####(3)> Node.connect :'node2@macross'
######Check that nodes have been added correctly by using Node.list
######Finally, run the program from one of the nodes
#####(4)> Node.connectBaker.bake(10, 100) #arguments: number of servers, number of customers

