function [ coords ] = teamDay2coord(home,away,day,order,teams,days )
% Convert team and day to specific matrix coordinates bases on total days
% and teams. Total teams and days default to 30 and 70 respectively. 
% Enter home and away as row vectors.

%%Nargin
if nargin <5
	teams = 30;
	days = 170;
end
total_home = length(home);
total_away = length(away);
total_days = length(day);
total_coords = total_home*total_away*total_days;
coords = zeros(total_coords,1);


% Suppose you have a 3D matrix A, and you want to get the singleton index for A(i1, i2, i3) which is given by  sub2ind(size(A), i1, i2, i3). This is the equivalent expression: 
% i1 + (i2-1)*size(A,1) + (i3-1)*size(A,1)*size(A,2) 
% works much much faster than sub2ind, especially when  i1, i2, and i3 are column matrices.

for di = 1:total_days
	d=day(di);
	daytoadd= total_away*total_home*(di-1);
	for h = 1:total_home
		this_home = home(h);
		start_c =	total_away*(h-1)+1 + daytoadd;
		end_c = total_away*h+daytoadd;
		coords(start_c:end_c) = sub2ind([teams teams days],away*0+this_home,away,away*0+d);
	end
end
coords = coords';

end

