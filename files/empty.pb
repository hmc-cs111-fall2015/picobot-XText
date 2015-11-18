state: starting_west;
state: starting_north;
state: moving_south;
state: moving_north;

rule: starting_west  [* * x *] -> W starting_west;    
rule: starting_west  [x * W *] -> N starting_north;   
rule: starting_north [x * * *] -> N starting_north;  
rule: starting_north [N * * x] -> S moving_south;

rule: moving_south [* * * x] -> S moving_south;
rule: moving_south [* x * S] -> E moving_north;

rule: moving_north [x * * *] -> N moving_north;
rule: moving_north [N x * *] -> E moving_south;

startwith: starting_west;