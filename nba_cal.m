%% NBA scheduling analysis and test
%
% Plan to start with data from 2015 season for comparison /test
%	Year started oct 27, ended apr 13 (170 total days)
% We have accounted for the following constraints
% -82 total games(41 home and 41 away)
% - Teams can only play 1 game per day
% - teams can not play themselves
% We need to account for these(for each team)
% 4 games against the other 4 division opponents, [4x4=16 games]
% 4 games against 6 (out-of-division) conference opponents, [4x6=24 games]
% 3 games against the remaining 4 conference teams, [3x4=12 games]
% 2 games against teams in the opposing conference. [2x15=30 games]
% note: A five year rotation determines which out-of-division conference teams are played only 3 times.
% NO GAMES on christmass, all star break etc..
% NOTES
% will use standard matlab matrix-linear indexing ( count by rows )
% vector will be 153000 to account for all possible days/games(usesparse)
% We will define the teams as follows
% East 1:15
%	Atlantic 1:5
% 		Toronto
% 		Boston
% 		New York
% 		Brooklyn
% 		Philidelphia
% %	Central 6:10
% 		Cleveland
% 		Indiana
% 		Detroit
% 		Chicago
% 		Milwaukee
% %	Southeast 11:15
% 		Miami
% 		Atlanta
% 		Charlotte
% 		Washington
% 		Orlando
% West 16:30
% % Northwest 16:20
% 		Oklahoma City
% 		Portland
% 		Utah
% 		Denver
% 		Minnesota
% %	Pacific 21:25
% 		Golden State
% 		L.A. Clippers
% 		Sacramento
% 		Phoenix
% 		L.A. Lakers
% %	Southwest 26:30
% 		San Antonio
% 		Dallas
% 		Memphis
% 		Houston
% 		New Orleans
%% Variables
	days = 170; % Length of season ( currently actual days of week are of  no factor)
	teams = 30; 
	total_vars = days*teams*teams; 
	league = nba_league();
	divs = league.divs();
	beq = [];
	bleq = [];
	cell_constraints = {};
	current_constraint = 1; % will hold what row constraint vars go into sparse A
	constraint_lengths = [];

	cell_constraints_leq = {};
	current_constraint_leq = 1; % will hold what row constraint vars go into sparse A
	constraint_lengths_leq = [];


%% Constraints
	% Teams can not play themselves
	identity_constraint = zeros(1,30*170);
	for d = 1:170
	identity_constraint((d-1)*30+(1:30)) = (d-1)*900+(1:31:900)	; % main diagonal must be 0
	end	
	constraint = identity_constraint;
	beq(end+1) = 0;
	cell_constraints{end+1} = constraint;
	constraint_lengths(end+1) = size(constraint,2);
	current_constraint = current_constraint + 1;
	
%% Teams must play a total of 82 games
	%  41 away games and 41 home games
	% Can not play multiple games per day
	for team = 1:30
		for d = 1:days	
%% One game per day			% this will ensure one game played per day per team 
			home_c = teamDay2coord(team,1:30,d);
			away_c = teamDay2coord(1:30,team,d);
			cell_constraints_leq{end+1} = [home_c away_c];%all possible home and away games for given team on specific day d
			bleq(end+1) = 1; % must be leq 1
			constraint_lengths_leq(end+1) = teams*2;
			current_constraint_leq = current_constraint_leq + 1;
		end
%% Home and away constraints	
% 		home_c = teamDay2coord(team,1:30,1:days); %Home games for a specific team for all days of season
% 		away_c = teamDay2coord(1:30,team,1:days);% Away games for a specific team for all days of season
% 
% 		cell_constraints{end+1} = home_c;	
% 		cell_constraints{end+1} = away_c;
% 		
% 		beq(end+1) = 41; %#ok<*SAGROW> % 41 away game
% 		beq(end+1) = 41; % 41 home games... Also ensures 82 total
% 		
% 		constraint_lengths(end+1) = teams*days;
% 		constraint_lengths(end+1) = teams*days;
% 		
% 		curent_constraint = current_constraint + 2;
	end
%% 4 games against the other 4 division opponents,( two home and two away )
	% loop through divs from nba class without repetition
	for conference = [0 1]
		for division = [0 1 2]
			for team =[1 2 3 4] % 5th team is uneeded at this point
				ind = (5*division)+team+(15*conference);
				
				%NEED A FOR LOOP FOR EACH TEAM!!! DUH
				for other_team = league.indiv_greater(ind)
					home_c = teamDay2coord(ind,other_team,1:days);
					away_c = teamDay2coord(other_team,ind,1:days);

					cell_constraints{end+1} = home_c;	
					cell_constraints{end+1} = away_c;
					beq(end+1) = 2; %#ok<*SAGROW> % 41 away game
					beq(end+1) = 2; 

					constraint_lengths(end+1) = days;
					constraint_lengths(end+1) = days;

					current_constraint = current_constraint + 2;
				end
				
			end
		end
	end
% 	
	
%% Convert cells of constraints to arrays for sparsce constraint matrix
	% we stored the 'locations' of our constraints in cell_constraints. To
	% enter these into a sparse matrix for lin prog we need a vector that
	% reflects the row each constraint is at in our global matrix. This can
	% be thought of as which constraint we are at(defined by when it was
	% added)
	constraint_indicies = cell2mat(cell_constraints); % gives location in column of a for all constraints as vector
	num_constraints = size(cell_constraints,2);
	cell_constraints_first = cell_constraints;
	for at = 1:num_constraints
		cell_constraints{at} = cell_constraints{at}*0 + at; % will now hold location of rows in global matrix for constraints
	end
	variable_indicies = cell2mat(cell_constraints);%will hold location in rows as vector not cell 

	% leq stufff, same as above
	constraint_indicies_leq = cell2mat(cell_constraints_leq); % gives location in column of a
	num_constraints_leq = size(cell_constraints_leq,2);
	for at = 1:num_constraints_leq
		cell_constraints_leq{at} = cell_constraints_leq{at}*0 + at; % will now hold location of rows
	end
	variable_indicies_leq = cell2mat(cell_constraints_leq);%will hold location in rows 

%% Define Objective Function
% Currently our objective funciton(f) is trivial. Before we optimize a
% solution we need to ensure we can find one in the first place
	f = ones(1,total_vars);  

%% Define main matricies
	Aeq = sparse( constraint_indicies,variable_indicies,ones(size(constraint_indicies)));
	Aleq = sparse( constraint_indicies_leq,variable_indicies_leq,ones(size(constraint_indicies_leq)));
%% Run Linea Program
	%options = optimoptions('intlinprog','MaxTime',120,'Heuristics','rss','IPPreprocess','advanced','BranchingRule','mostfractional')
	an = intlinprog(f,1:total_vars,Aleq',bleq',Aeq',beq',f*0,f);
%% Convert Solution into better format
	matrix_answer = reshape(an,[30,30,days]); % gives the solutin in a format that is easier to see

	games = find(matrix_answer>0);%a 1 indicates a game is played

	[home,away,day ] = ind2sub([30,30,170],games);
	
	%% Program Completion
	mark = 1 % program completed
%% Test Answers
 
	testc = @(x) sum(matrix_answer(cell_constraints_first{x}))
	getc = @(x) find(matrix_answer(cell_constraints_first{x}))

% arrayfun(@(x) testc(x),1:length(beq))
