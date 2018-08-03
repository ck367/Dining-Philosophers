# Dining-Philosophers
A project I created while at University, programmed in Erlang. The purpose of the project was to showcase the programming deadlock and attempt to work around it.

>> Too run on Windows install the latest Erlang OTP: http://www.erlang.org/downloads
>> Add the path to the erlang.exe to your computers "C:\Users" path, or run "werl.exe" in the command prompt.
>> The erlang file will need to be in "C:\Users\yourusername" unless you "cd" to where it is located
>> To start erlang type "erl" (if added to path) or "werl.exe"
>> To compile "c(dine)." (you will get some warnings, this is fine)
>> To run "dine:college()." 
>> The live output of the philosophers actions will be printed to the command line

This projects aim was to create a program in a situation where deadlock would be likely and attempt to avoid deadlock entirely if possible. When run it create 5 philosophers who will have a number of states such as: thinking, eating and picking up forks. A deadlock can happen if all the philosophers were to pick up their left fork within a short time frame, this would cause them to deadlock as they can no longer pick up their right fork to eat and complete their action.
