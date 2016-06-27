classdef nba_league
	%UNTITLED Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
	all_teams % index in leage- in 1:30
	   % name
	divs   % division 1,2,3
	confs % conference 1,2
	
	end
	
	methods
		function n = nba_league(~)
			n.all_teams = 1:30;
			n.confs = [1:15;16:30];
			n.divs = cat(3,[1:5;6:10;11:15],[16:20;21:25;26:30]);
		end
		function div = div_at(n,c)
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
			rmat = rem(c,5);
			if rmat == 0
				rmat = 5
			end
			div = n.div_at(c);
			div(rmat) = [];
		end
		function div = indiv_greater(n,c)
			rmat = rem(c,5);
			if rmat == 0
				rmat = 5;
			end
			rmat = 1:rmat;
			div = n.div_at(c);
			div(rmat) = [];
		end
		function con = other_conf(n,c)
			if c >15
				con = n.confs(1,:);
			else
				con = n.confs(2,:);
			end
		end
	end
	
end

