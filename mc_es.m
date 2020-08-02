%---------------------------------------------------------------- 
% file:mc_es.m
% rbd
% ray.duran@und.edu
% EE547
% Last update: 8/2/20
%
% Description:
% Program in Matlab that solves the blackjack problem as outlined
% in "Reinforcement Learning, An Introduction 2nd edition", by Sutton and 
% Barto.
%
% Theory of Operation:
%
%
% keywords: Monte carlo, Exploring Starts, for estimating policy
%----------------------------------------------------------------

%% Init values:
E = 1000000;
S = 200; % Player hand 12-21; Dealer 2-Ace; Usable Ace
A = 2; % 0 = stand ; 1 = hit
D = .9; % Discount factor

policy = randi([0 1], S, 1);
policy = policy';
q = randi([1 100],S,A); % States: row 1 is No Hit; row 2 is Hit
%q = q';
r = []; % empty list

c = zeros(S,1);  % State-action pair count for calculating q(s,a) avg.
c = c';

elistS = [];
elistA = [];
elistR = [];


eCount = 1;


debug = 0;
tic

%% Loop Forever for each episode
while ( eCount <  E )
    
    % Generate State-Action Pairs
    %epairS = randi([1 S], S, 1); % episode list
    %epairS = epairS';
    %epairA = randi([0 1], S, 1);
    %epairA = epairA';
    
    % Generate Episodes from policy
    [T_count,elistS,elistA,elistR] = playBlackJack(policy,S);
    
    G = 0;

    % Process last first
    elistS = flip(elistS);
    elistA = flip(elistA);
    elistR = flip(elistR);
    
    %% Loop for each step of episode
   
    T_finish = T_count + 1;
    T = 1;
    while( T < T_finish )
        G = D*G + elistR(T); % Matlab does not have a zero!
                             % so start here; diff than RL pseudo code
                             % in Sutton Example
        % Here I am making an assumption that states are acyclic in
        % blackjack and that we will not revisit states in an 
        % episode, so then we are always a monte carlo first visit
        % and do not need to check if we have visited state.
        
        % incr q state pair count
        idxqS = elistS(T);    % index q state
        idxqA = elistA(T);    % index q action
        
        c(idxqS) = c(idxqS) + 1; % incr count for state-action
        num = c(idxqS); % Use current state-action count for calc avg.
        % Append G to Returns(St,At)
        r = G;
        actionIndex = idxqA + 1;
        stateIndex  = idxqS;
        q(stateIndex,actionIndex) = q(stateIndex,actionIndex) + ...
                                 (1/(num))*(r - q(stateIndex,actionIndex));
        % Max index in columns
        temp1 = q(stateIndex,1); % value of Q for Action Not Hit
        temp2 = q(stateIndex,2);
        if( temp1 > temp2)
         policy(stateIndex) = 0;
        else
         policy(stateIndex) = 1;
        end
        % debug
        %policy(elistS(T)) = max(q, []
        T = T + 1;
    end
    eCount = eCount + 1;
debug = 0;


end
toc
debug = 0;


%----------------------
% Function: 
%----------------------
% Description: 
% This function generates the episodes while playing blackjack
%
% Information: 
% Player hand 12-21; Dealer 2-Ace; Usable Ace:
% Examples:
% Player cards:12,dealer cards showing:2, Player No Ace -->State 1
% Player cards:20,dealer cards showing:7, Player No Ace -->State 87
% Player cards:12,dealer cards showing:2, Player Ace    -->State 101
% Player cards:13,dealer cards showing:2, Player Ace    -->State 110
%
%

function[T,elistS,elistA,elistR] = playBlackJack(policy,S)
elistS = [];
elistA = [];
elistR = [];
dealerHandFinal = 0;
dealerHand = 0;
nonAceCard = 0;
delta = 0;

doNothing = 0;

T = 0;   % Here we capitalize T , not following our convention
         % of capitalzing constants
r = 0;
hand  = 0;
index = randi([1 S],1,1);
halfStates = S/2; % This is to copy matrics since only usable ace is different
stateTable = zeros(3,halfStates);
i = 1;
j = 1;


% Assign Dealer show cards to StateTable
k= 0;
dealerShow = 2;
stateRowLength = 10;
stateRows = 10;
for j = 1 : stateRows
    for i = 1 :stateRowLength
        i = i + k*stateRowLength;   
        stateTable(2,i) = dealerShow + k;  
    end
    k = k+ 1;
end

% Assign Player cards
k = 0;
m = 1;
lowestHand = 12;
for j = 1 : stateRows
    for i = 1 : stateRowLength
        i = i + k*stateRowLength; 
        stateTable(1,i) = lowestHand + (m-1);
        m = m + 1;
    end
    m = 1;
    k = k + 1;
end

copystateTable = stateTable;
finalStateTable = [ stateTable copystateTable];

% Assign Usable Ace to States
for j = 101 : S
    finalStateTable(3,j) = 1;
end

    % Form our epsiodes
    elistS = [elistS, index];
    elistA = [elistA, policy(index)];
   

    % Determine dealer's hand at start
    playerHandStart =  finalStateTable(1,index);
    % Dealer's show card
    dealerShow =  finalStateTable(2,index);
    % First determine card not shown to player
    dealerHiddencard = randi([2 11],1,1); % Assume dealer has to use Ace
                                           % as 11
    % Dealer's hand at time of deal
    dealerHandStart = dealerHiddencard + dealerShow;
    
    dealerHand = dealerHandStart;
    playerHand = playerHandStart;
    
    
    
    
     while ( (policy(index) ~= 0) && (playerHand <= 21 ) ) % Policy says hit
                                                    % or we have busted
                                                         
        if( index < 101) % Player has no usable ace
            
           % Hit me dealer!
           newCard    = randi([2 11],1,1); 
           playerHand = playerHand + newCard; 
            
           % calculate new state
           if newCard == 11
                  playerHand = playerHand + 1; % Use Ace as "1"
                  
                  if playerHand > 21
                      
                    % The last index was our terminal state
                    r = -1;
                    %elistR = [elistR,r]; % Assign this to last S, A  
                  else

                   index = index + 1;

                   % we haven't lost at this point, but we still can
                   r = 0;
                   %elistR = [elistR,r]; % Assign this to last S, A 
                
                   % Form our epsiodes
                   elistS = [elistS, index];
                   elistA = [elistA, policy(index)];
                  end
      
                 
           elseif playerHand <= 21
              % Find new state stayed in same decade of states
              index = index + newCard; 
              
              % we haven't lost at this point, but we still can
              r = 0;
              %elistR = [elistR,r]; % Assign this to last S, A
              
              % Form our epsiodes
              elistS = [elistS, index];
              elistA = [elistA, policy(index)];
                
           elseif playerHand > 21
               % The last index was our terminal state
               r = -1;
               %elistR = [elistR,r]; % Assign this to last S, A                             
               
           end % if -player hand / new card
        
        else % we deal with usable ace or "soft hand"
              
              nonAceCard = playerHand - 11;
              playerSoftHand = playerHand;
              % Hit me dealer!
              newCard    = randi([2 11],1,1); 
              playerHand = playerHand + newCard; 
        
              
              if playerHand <= 21
                  
                 % Find new state stayed in same decade of states
                 index = index + newCard; 
              
                 % we haven't lost at this point, but we still can
                 r = 0;
                 %elistR = [elistR,r]; % Assign this to last S, A
              
                 % Form our epsiodes
                 elistS = [elistS, index];
                 elistA = [elistA, policy(index)];
               
              else playerHand > 21
                  playerHand = nonAceCard + newCard + 1;
                  
                   delta  = playerSoftHand - playerHand;
                   index = index - 100 -delta;
                                        

                   % we haven't lost at this point, but we still can
                   r = 0;
                   %elistR = [elistR,r]; % Assign this to last S, A 
                
                   % Form our epsiodes
                   elistS = [elistS, index];
                   elistA = [elistA, policy(index)];
                                  
                 
              end
              
        end % if- index
        elistR = [elistR,r]; % Assign this to last S, A 
        T = T + 1; % number of steps in our episode
        
        debug = 0;
        
    end % while    
           
           


    if ( (r == -1) && ( T ~= 0) )
        % dealer does nothing
        doNothing = 0;
        %elistR = [elistR,r]; % Assign this to last S, A 
        %T = T + 1; % number of steps in our episode
    elseif T ~= 0  % Now dealer plays based on player's cards
        while ( dealerHand < 17) 
          % Dealer has to hit!
          newCard    = randi([2 11],1,1); 
          dealerHand = dealerHand + newCard;                   
        end
        % Now determine final outcome
        if dealerHand > 21
            r = 1;
        elseif dealerHand == playerHand
            r = 0;
        elseif dealerHand < playerHand
            r = 1;
        else
            r = -1; % player loses
        end
        elistR = [elistR,r]; % Assign this to last S, A
        T = T + 1; % number of steps in our episode
    end
    
    
    
    if (T == 0) % Our first step was no action
        T = 1;
        % Player stands on 17 or less and dealer 17 or greater
        if (dealerHandStart >=  17)
            case_value = 1;
        end
        
        if (dealerHandStart < 17)
            case_value = 2;
        end
        
        switch case_value
            
            case 1 % Dealer stays even on soft 17
                dealerHandFinal = dealerHandStart;
                
            case 2 % Dealer must hit
        
                dealerHand = dealerHandStart;
                while( dealerHand <=  17)
                     dealerHand = dealerHand + randi([2 11],1,1);
                end
                dealerHandFinal = dealerHand;
            otherwise
                disp('Something wrong');
        end
        
        % Our policy for this state was no action
        % we can assign rewards based on cards at start
        
        % First check if dealer busts.
        if (dealerHandFinal > 21)
            r = 1; %Player wins!             
        elseif ( playerHandStart > dealerHandFinal)
            r = 1; % We won
        elseif ( playerHandStart == dealerHandFinal)
            r = 0; % We tied
        else
            r = -1; % We lost
        end
        
        % Form our epsiodes
        %elistS = [elistS, index];
        %elistA = [elistA, policy(index)];
        elistR = [elistR, r];
            
   end 
        
  
    
    

        

end



