%% NBA scheduling analysis and test
%
% Plan to start with data from 2015 season for comparison /test
%	Year started oct 27, ended apr 13 (170 total days)

%% Notes
% will use standard matlab matrix-linear indexing ( count by rows )
% vector will be 153000 to account for all possible days/games(usesparse)

%% Get Linear Index

linInd = @(home,away,day) sub2ind([30,30,170],home,away,day);
% travelling tournament problem

%% Variables
	days = 170; 
	teams = 30; 
	total_vars = 170*30*30;

	number_constraints = 80;
	%A = spalloc(number_constraints,30*30*170,30*82);
	b = zeros(number_constraints,1);
	current_constraint = 1; % will hold what row constraint vars go into sparse A
	
	constraint_indicies = [];% hold which row each constraint should be in(should be diff)
	variable_indicies = []; %hold wich variables should be 1

%% Constraints
% TEAMS CAN NOT PLAY THEMSELVES
	
	%A(current_constraint,1:31:end) = 1;
	constraint = (1:31:total_vars);
	
	variable_indicies = [variable_indicies,constraint];
	constraint_indicies = [constraint_indicies; ones(size(constraint,2),1)'*current_constraint];
	
	
	b(current_constraint) = 0;
	current_constraint = current_constraint + 1;
	
%% Teams must play a total of 82 games
	%  41 away games
	for team = 1:30
		%A(current_constraint,1:2) = 1;
		first = team*30-29;
		range_of_games = first:first+29;
		constraint = []
		for d = 1:days
% 			range_of_games+d*900
			constraint = [constraint,range_of_games+(d-1)*900];	
		end
		variable_indicies = [variable_indicies,constraint];
		constraint_indicies = [constraint_indicies, ones(size(constraint,2),1)'*current_constraint];
		b(current_constraint) = 41;
		current_constraint = current_constraint + 1;
	end
	% 41 home games
	for team = 1:30
		first = team;
		range_of_games = first:30:900-team;
		constraint = [];
		for d = 1:days
			constraint = [constraint,range_of_games+(d-1)*900];
		end
		variable_indicies = [variable_indicies,constraint];
		constraint_indicies = [constraint_indicies, ones(size(constraint,2),1)'*current_constraint];
		b(current_constraint) = 41;
		current_constraint = current_constraint + 1;
	end
%

A = sparse( constraint_indicies,variable_indicies,ones(size(constraint_indicies)));
b(size(A,1)+1:end) = [];
beq = b(size(A,1)+1:end);
f = ones(1,total_vars);


% x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub)
% lb 0 
% ub = ones
an = intlinprog(f,f,[],[],A,b,f*0,f);
matrix_answer = reshape(an,[30,30,days]);

% [r,c,d] = ind2sub([30,30,days],1:total_vars);
mark = 1
%% Run the LP
% 30 teams
