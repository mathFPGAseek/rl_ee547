%-------------------------------------------------------------------------
% script file: sarsa_cliff_walking.m
% rbd
% ray.duran@und.edu
% EE547
% Last update: 8/2/20
%
% Example 6.6 Cliff Walking SARSA
% Sutton, "Reinforcement Learning,An Introduction, 2nd ed" pg 132
%
%---------------------
% Algo SARSA:
% Parameters: step size: alpha(0,1], small epsilon > 0
% Initialize Q(s,a), for all s,a, except Q(terminal,.) = 0
%
%  Loop for each epsiode
%   Initialize S
%   Choose A from S using policy derived from Q( epsilon greedy)
%   Loop for each step of episode:
%       Take action A, observe R, S'
%       Choose A' from S' using policy dervied from Q( epsilon greedy)
%       Q(S,A) <- Q(S,A) + alpha*[ R + gamma*Q(S',A') - Q(S,A)]
%       S<- S'; A<- A';
%   Until S is terminal
% NOte: Assume for this gridworld that you cannot take action to take
% you off ":edge".
%-------------------------------------------------------------------------
clear all;
x = 12; 
y = 7;
a = 4;                          % Number of actions:{ up,down,left, right}
epsilon = .1;                   % for greedy policy
alpha = .5;                     % step size
gamma = .9;                     % discount rate
q = zeros(y,x,a);               % action-state space(y,x,a)
q(4,12,:) = 0;                  % terminal value zero; Note coordinate from upperleft
avg_time_incr_intervals = 100;  % helps average sum of rewards over 5 episodes
episodes = avg_time_incr_intervals*5; 

%debug
time_steps = 0;
sum_of_rewards_debug = zeros(1,episodes);

for n = 1: episodes
    i_current = 4; % state init row 
    j_current = 1; % state init col
    
    cliffwalking   = 1;
    sum_of_rewards = 0;
    
    % choose with epsilon greedy policy
    random = rand(1); 
    if( 1-epsilon > random)
        [max_value,a_current] = max(q(i_current,j_current,:));
    else
        a_current = randi(4,1);
    end
    
    while cliffwalking
        
        switch a_current
            case 1 % up
                i_update = i_current-1; % reference (1,1)
                j_update = j_current;
            case 2 % down
                i_update = i_current+1;
                j_update = j_current;
            case 3 % right
                i_update = i_current;
                j_update = j_current+1;
            case 4 % left
                i_update = i_current;
                j_update = j_current-1;            
            otherwise
                i_update = 4;
                j_update = 1;
        end
        
  
        % cliff!!
        if (i_update == 4) && (j_update > 1) && (j_update < 12)
            i_update = 4; 
            j_update = 1;
            r = -100;
        
        % other limits
        elseif i_update < 1
            i_update = 1;
            r = -1;
               
        elseif i_update > 4
            i_update = 4;
            r = -1;
                
        elseif j_update > 12;
            j_update = 12;
            r = -1;
       
        elseif j_update < 1
            j_update = 1;
            r = -1;
        else
            r = -1;
        end
       
     
     % choose with epsilon greedy policy
     random = rand(1); 
     if( 1-epsilon > random)
        [max_value,a_update] = max(q(i_update,j_update,:));
     else
        a_update = randi(4,1);
     end
     
     q(i_current,j_current,a_current) =  q(i_current,j_current,a_current) +...
         alpha*(r + gamma*q(i_update,j_update,a_update)  -...
         q(i_current,j_current,a_current) );
     
     i_current = i_update;
     j_current = j_update;
     a_current = a_update;
     
     % debug
     sum_of_rewards = sum_of_rewards + r;
     
     % terminate epsiode
     if i_update==4 && j_update ==12
         cliffwalking = 0;
         % debug
         sum_of_rewards_debug(1,n) = sum_of_rewards;
     end                
        
    end % while
        
end

avg_time_incr = [1: 1: avg_time_incr_intervals];

% avg over 5 columns
temp = reshape( sum_of_rewards_debug,5,avg_time_incr_intervals); % 5 rows
temp_sum = sum(temp);
temp_avg = temp_sum/5;


% Plot
figure(1)
plot(avg_time_incr,temp_avg, '-r')
xlabel('Epsiodes*5');
ylabel('Sum of rewards during episode');
title('SARSA cliff walking performance');
axis([-1 501 -500 -5])



debug = 1;

    
    
    
