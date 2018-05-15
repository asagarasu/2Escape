# 2Escape
A final project for Cornell CS 3110, Spring 2018.

Team Members: Aaron Lou, Betsy Fu, Yilin Lu, Siyan Zheng, 
 
## Overview
2Escape is a two player light novel/ puzzle escape game that can be played on two different computers. Players collaborate to escape various rooms (often times not having to work in tandem to fix different parts). Text chat will be enabled to allow players to communicate over text. 

### Installation
We assume that you had some experience with Ocaml. If you don't have Ocaml installed, please refer to: http://www.cs.cornell.edu/courses/cs3110/2018sp/install.html

Install: js_of_ocaml, yojson, nodejs, websocket

### How it plays
Comile: 

 make build -> builds GUI.
 make server -> makes ocaml server. Will prompt you for port number.
 node server.js [ocamlport] [jsport] -> ocamlport is the port you entered earlier. You will receive a string with you server's ip. 
 
Play: 
 
 open up index.html. You will be asked to input the server's ip address (from the last step) and player id.

### Sample Screenshots

![alt text](https://raw.githubusercontent.com/betsyfu/2Escape/screen.png)

### Acknowledgement
Course professor: Professor Nate Poster. 

Project advising teaching assistant: Yuchen Shen

If you have any question regarding the game, please feel free to email al968@cornell.edu, zf48@cornell.edu, sz488@cornell.edu, or yl668@cornell.edu.



 
