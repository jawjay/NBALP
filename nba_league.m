classdef nba_league
	%UNTITLED Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
	all_teams % index in leage- in 1:30
	   % name
	divs   % division 1,2,3
	confs % conference 1,2
	
	threegames		%hold data about irregular matchups
	end
	
	methods
		function n = nba_league(~)
			n.all_teams = 1:30;
			n.confs = [1:15;16:30];
			n.divs = cat(3,[1:5;6:10;11:15],[16:20;21:25;26:30]);
			n.threegames = zeros(30,4);
		end
		function div = div_at(n,c)
			%return indicies of division teams
				if c < 16
					d = 1;
					if c <6
						t = 1;
					elseif  c< 11
						t = 2;
					else 
						t = 3;
					end
				else
					d=2;
					if c < 21
						t = 1;
					elseif c < 26
						t =2;
					else
						t = 3;
					end
					
				end
				div = n.divs(t,:,d);
		end
		function div = div_xat(n,c)
			%returns everyone in division except self
			rmat = rem(c,5);
			if rmat == 0
				rmat = 5
			end
			div = n.div_at(c);
			div(rmat) = [];
		end
		function div = indiv_greater(n,c)
			% returns teams in division with larger index
			rmat = rem(c,5);
			if rmat == 0
				rmat = 5;
			end
			rmat = 1:rmat;
			div = n.div_at(c);
			div(rmat) = [];
		end
		function con = other_conf(n,c)
			%returns indicies of all teams in opposite conference
			if c >15
				con = n.confs(1,:);
			else
				con = n.confs(2,:);
			end
		end
		function mycon = my_conf(n,c)
			%returns indicies of all teams in opposite conference
			if c >15
				mycon = n.confs(2,:);
			else
				mycon = n.confs(1,:);
			end
			
		end
		function myconf = other_div(n,c)
			myconf = n.my_conf(c);
			if c>15 
				c = c-15; 
			end
			my_loc = ceil(c/5);
			myconf(my_loc*5-4:my_loc*5) = [];
		end
		
		function divgames = get4games(n,c)
			% get games in wich teams play opponents 4 times
			divgames = n.other_div(c);
			tgames = n.threegames(c,:);
			tgames(tgames>c) = tgames(tgames>c) -5;
			if c > 15
				tgames = tgames-15;
			end
			divgames(tgames) = [];
		end
		function tgames = get3games(n,c)
			tgames = n.threegames(c,:);
		end
	end
	
end

