-module(dine).
-author("ck367").
-compile([export_all]).


-define (Think, 1000).
-define (Eat, 1000).

%setsup philospher and creates randomisation, puts philosopher into thinking state.
philosopher (Data, Left, Right, Name) ->	
	random:seed (now ()),
	timer:sleep((random:uniform(1000-100)+100)),
	philosopher (thinking, Data, Left, Right, Name).

%Thinking process for philosopher,once it finishes thinking transitions to hungry state, reports to the report function to output that is thinking.
philosopher (thinking, Data, Left, Right, Name) ->
	Data ! {Name, "thinking", self()},
	receive {Data, ack} -> true end,
	timer:sleep(random:uniform(?Think)),
	philosopher (hungry, Data, Left, Right, Name);

%Hungry process for philosopher, reports that it is hungry to report, attempts to pickup left and right fork. If it can it will pick up the forks.
philosopher (hungry, Data, Left, Right, Name) ->
	Data ! {Name, "hungry", self()},
	receive {Data, ack} -> true end,
	Left ! {pickedup, self()},
	Right ! {pickedup, self()},
	receive {used, Left} ->
	philosopher (got_l, Data, Left, Right, Name);
	{used, Right} ->
	philosopher (got_r, Data, Left, Right, Name)
	end;

%In this state the philosopher has the left for and will attempt to pick up the right fork.
philosopher(got_l, Data, Left, Right, Name) ->
	Data ! {Name, "I have left fork", self()},
	receive {Data, ack} -> true end,
	receive {used, Right} ->
	Data ! {Name, "I have right fork", self()},
	receive {Data, ack} -> true end,
	philosopher (eating, Data, Left, Right, Name)
	end;
	
%In this state the philosopher has the right fork and will attempt to pick up the left fork.
philosopher(got_r, Data, Left, Right, Name) ->
	Data ! {Name, "I have right fork", self()},
	receive {Data, ack} -> true end,
	receive {used, Left} ->
	Data ! {Name, "I have left fork", self()},
	receive {Data, ack} -> true end,
	philosopher (eating, Data, Left, Right, Name)
	end;
 
%Eating process for philosopher, after delay the philosopher will put down both the forks that it is holding.
 philosopher (eating, Data, Left, Right, Name) ->
	Data ! {Name, "eating", self()},
	receive {Data, ack} -> true end,
	timer:sleep(random:uniform(?Eat)),
	Left ! {down, self()},
	Right ! {down, self()},
	philosopher (thinking, Data, Left, Right, Name).
	
%Sets up the fork
fork (Data, Name) ->
	fork (table, Data, Name).

%Reports that it is on the table, the fork will wait to be picked up, when it is picked up it will report who picked it up.
fork (table, Data, Name) ->
	Data ! {Name, "On table", self()},
	receive {Data, ack} -> true end,
	receive {pickedup, Pid} ->
	Data ! {Name, "used", self()},
	receive {Data, ack} -> true end,
	Pid ! {used, self()},
	fork(in_hand, Data, Name, Pid)
	end.

%Held process for fork, waits to be putdown by the philosopher using it.
fork (in_hand, Data, Name, Phil) ->
   receive {down, Phil} ->
   fork(table, Data, Name)
   end.
	
%Report function, interprets messages from the different states and outputs them.
report () ->
	receive {Name, Status, Pid} ->
	io:format ("~s: ~s~n", [Name, Status]),
	Pid ! {self(), ack}
	end,
	report ().

%Creates and spawns the 5 philosophers and 5 forks and the reporting process.
college () ->

	R = spawn(?MODULE, report, []),

	Fork0 = spawn(?MODULE, fork,[R,"Fork0"]),
	Fork1 = spawn(?MODULE, fork,[R,"Fork1"]),
	Fork2 = spawn(?MODULE, fork,[R,"Fork2"]),
	Fork3 = spawn(?MODULE, fork,[R,"Fork3"]),
	Fork4 = spawn(?MODULE, fork,[R,"Fork4"]),


	spawn(?MODULE, philosopher,[R,Fork0,Fork1,"Bill"]),
	spawn(?MODULE, philosopher,[R,Fork1,Fork2,"Bob"]),
	spawn(?MODULE, philosopher,[R,Fork2,Fork3,"Bart"]),
	spawn(?MODULE, philosopher,[R,Fork3,Fork4,"Billy"]),
	spawn(?MODULE, philosopher,[R,Fork4,Fork0,"Bilbo"]).
	
%	
%	Challenge
%1. Is there any possibility of deadlock?
%Yes there is a possibility of deadlock in this system, it may take a while due to use of randomisation
%but eventually a deadlock will happen. The deadlock should happen if all the philosophers were to pick up
%their left fork within a short amount of miliseconds.
%
%2.
%a) How could the deadlock be avoided?
%Currently the philosophers can only put down the forks if they have eaten, this is what causes the deadlock
%once a philosopher has picked up their left fork they can't put it down until they've eaten.
%To avoid this you could make it so that after a brief period of time of not being able to pick up the
%fork the philosospher doesn't have they can instead put the fork back down and try again later.
%
