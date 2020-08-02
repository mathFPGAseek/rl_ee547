%-------------------------------------------------------------------------
% script file: sarsa_windy_gridworld_kings_moves.m
% rbd
% ray.duran@und.edu
% EE547
% Last update: 8/2/20
%
% github repository: https://github/mathFPGAseek/rl
% Example of sarsa algorithm
% Sutton, "Reinforcement Learning,An Introduction, 2nd ed" pg 131
% Algo:
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
x = 10; 
y = 7;
epsilon = .1;      % for greedy policy
alpha = .5;        % step size
gamma = .9;        % discount rate
q = zeros(7,10,9); % action-state space
q(4,8,:) = 0;      % terminal value zero; Note coordinate from upperleft
episodes = 170;


%debug
time_steps = 0;
episode_debug = zeros(1,episodes);

for n = 1: episodes
    i_current = 4; % state init row 
    j_current = 1; % state init col
    % choose with epsilon greedy policy
    random = rand(1); 
    if( 1-epsilon > random)
        [max_value,a_current] = max(q(i_current,j_current,:));
    else
        a_current = randi(9,1); % note 9 moves , inc no move
    end
    
    windsurfing = 1;
    
    
    while windsurfing
        
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
            case 5 % upper rt diagonal
                i_update = i_current-1;
                j_update = j_current+1;
            case 6 % upper lft diagonal
                i_update = i_current-1;
                j_update = j_current-1;
            case 7 % lower rt diagonal
                i_update = i_current+1;
                j_update = j_current+1;
            case 8 % lower lft diagonal
                i_update = i_current+1;
                j_update = j_current-1;
            case 9 % no move
                i_update = i_current;
                j_update = j_current;
                
            otherwise
                i_update = 4;
                j_update = 1;
        end
        
        % strength of wind by column; See Sutton book page 130
        switch j_update
            case 1
             i_update = i_update;
            case 2
             i_update = i_update;
            case 3
             i_update = i_update;
            case 4
             i_update = i_update-1;
            case 5
             i_update = i_update-1;
            case 6
             i_update = i_update-1;
            case 7
             i_update = i_update-2;
            case 8
             i_update = i_update-2;
            case 9
             i_update = i_update-1;
            case 10
             i_update = i_update;
             
             otherwise
                i_update = 1;
        end
             
        % limits on i & j
        if i_update > 7
            i_update = 7;
        end
        if i_update < 1
            i_update = 1;
        end
        if j_update > 10;
            j_update = 10;
        end
        if j_update < 1
            j_update = 1;
        end
        

     %  Observe r and s'= i_update & j_update
     r = -1;
     
     % choose with epsilon greedy policy
     random = rand(1); 
     if( 1-epsilon > random)
        [max_value,a_update] = max(q(i_update,j_update,:));
     else
        a_update = randi(9,1);
     end
     q(i_current,j_current,a_current) =  q(i_current,j_current,a_current) +...
         alpha*(r + gamma*q(i_update,j_update,a_update) - ...
         q(i_current,j_current,a_current) );
     
     i_current = i_update;
     j_current = j_update;
     a_current = a_update;
     
     % debug
     time_steps = time_steps + 1;
     
     % terminate epsiode
     if i_update==4 && j_update ==8
         windsurfing = 0;
         % debug
         episode_debug(1,n) = time_steps;
     end                
        
    end % while
        
end

time_incr = [ 1:1:episodes];
% Plot
figure(1)
plot(episode_debug(1,time_incr),time_incr, '-r')
xlabel('Time Steps');
ylabel('Epsiodes');
axis([-1 10001 -1 200])

% debug
debug = 1;

    
    
    
