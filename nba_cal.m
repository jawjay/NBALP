%% NBA scheduling analysis and test
%
% Plan to start with data from 2015 season for comparison /test
%	Year started oct 27, ended apr 13 (170 total days)

%% Notes
% will use standard matlab matrix-linear indexing ( count by rows )
% vector will be 153000 to account for all possible days/games(usesparse)

%% Variables
	days = 170; 
	teams = 30; 
	total_vars = days*teams*teams;

	number_constraints = 80;
	%A = spalloc(number_constraints,30*30*170,30*82);
	beq = [];
	bleq = [];
	cell_constraints = {};
	current_constraint = 1; % will hold what row constraint vars go into sparse A
	constraint_lengths = [];
	constraint_indicies = [];% hold which row each constraint should be in(should be diff)
	variable_indicies = []; %hold wich variables should be 1
	cell_constraints_leq = {};
	current_constraint_leq = 1; % will hold what row constraint vars go into sparse A
	constraint_lengths_leq = [];

%% Get Linear Index

linInd = @(home,away,day) sub2ind([teams,teams,days],home,away,day);
% travelling tournament problem


%% Constraints
	constraint = (1:31:total_vars);% TEAMS CAN NOT PLAY THEMSELVES
	identity_constraint = zeros(1,30*170);
	for d = 1:170
	identity_constraint((d-1)*30+(1:30)) = (d-1)*900+(1:31:900)	;
	end	
	constraint = identity_constraint;
	beq(end+1) = 0;
	cell_constraints{end+1} = constraint;
	constraint_lengths(end+1) = size(constraint,2);
	current_constraint = current_constraint + 1;
	
%% Teams must play a total of 82 games
	%  41 away games and 41 home games
	for team = 1:30
% 		first = team*30-29;
% 		range_of_games_home = first:first+29;
% 		range_of_games_away = team:30:900-(teams-team);
% 		home_constraint = zeros(teams,days);
% 		away_constraint = zeros(teams,days);
		for d = 1:days
% 			away_c = range_of_games_away+(d-1)*900;
% 			home_c = range_of_games_home+(d-1)*900;
% 			home_constraint(:,d) = home_c;
% 			away_constraint(:,d) = away_c;
			
			% this will ensure one game played per day per team 
			home_c = teamDay2coord(team,1:30,d);
			away_c = teamDay2coord(1:30,team,d);
			
			cell_constraints_leq{end+1} = [home_c away_c];
			bleq(end+1) = 1;
			constraint_lengths_leq(end+1) = teams*2;
			current_constraint_leq = current_constraint_leq + 1;
			
		end
		
		home_c = teamDay2coord(team,1:30,1:days);
		away_c = teamDay2coord(1:30,team,1:days);

		cell_constraints{end+1} = home_c;	
		cell_constraints{end+1} = away_c;
		
		beq(end+1) = 41; % 41 away game
		beq(end+1) = 41;

		constraint_lengths(end+1) = teams*days;
		constraint_lengths(end+1) = teams*days;

		curent_constraint = current_constraint + 2;
	end
	
	
%
%% Teams can only play 1 game per day

% 	leq_variable_indicies = zeros(teams*days,1);
% 	leq_constraint_indicies = zeros(teams*days,1);
% 	leq_current_constraint = 1;
% 	for team = 1:30
% 		for d = 1:days
% 			mark=2;
% 		end
% 		
% 	end
	
	
%% Convert cells of constraints to arrays to sparsce constraint matrix

constraint_indicies = cell2mat(cell_constraints); % gives location in column of a
num_constraints = size(cell_constraints,2);
for at = 1:num_constraints
cell_constraints{at} = cell_constraints{at}*0 + at; % will now hold location of rows
end
variable_indicies = cell2mat(cell_constraints);%will hold location in rows 

% leq stufff 
constraint_indicies_leq = cell2mat(cell_constraints_leq); % gives location in column of a
num_constraints_leq = size(cell_constraints_leq,2);
for at = 1:num_constraints_leq
cell_constraints_leq{at} = cell_constraints_leq{at}*0 + at; % will now hold location of rows
end
variable_indicies_leq = cell2mat(cell_constraints_leq);%will hold location in rows 

%% Find Solution

%cell_constraints_ones = cellfun(@(arr)arr*0+1,cell_constraints,'UniformOutput', false);




Aeq = sparse( constraint_indicies,variable_indicies,ones(size(constraint_indicies)));
beq(size(Aeq,1)+1:end) = [];

f = ones(1,total_vars);

Aleq = sparse( constraint_indicies_leq,variable_indicies_leq,ones(size(constraint_indicies_leq)));

% x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub)
% lb 0 
% ub = ones
an = intlinprog(f,[],Aleq',bleq',Aeq',beq',f*0,f);
matrix_answer = reshape(an,[30,30,days]);

% [r,c,d] = ind2sub([30,30,days],1:total_vars);
mark = 1




%% Run the LP
% 30 teams
