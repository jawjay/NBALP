function [mark ] = visualizeSched(sched,varagin )
%Schedule visualizer for solution to LP optimization as provided  in ____
%should be a binary data, where 1 represents a game between 2 teams
%  if days are not provided then assume 170
%  sched should either be a 30x30xdays matrix or a linear vector
mark = 1
team = 1

games = find(sched>0);
[home,away,day ] = ind2sub([30,30,170],games);
team1 = find(home==1 | away == 1)
versus = day(team1)

mark = 1
end

