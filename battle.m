function [ life1, life2 ] = battle( b1, b2 )

%% COMPUTE STATS

[ totalLife1, cannonPower1, crewPower1, totalPrecision1, totalDodge1 ] = b1.getBattleState();
[ totalLife2, cannonPower2, crewPower2, totalPrecision2, totalDodge2 ] = b2.getBattleState();

[ hitRate1, hitRate2 ] = Ship.getHitRate( totalPrecision1, totalDodge1, totalPrecision2, totalDodge2 );

cannonPower1 = cannonPower1 .* hitRate1;
crewPower1 = crewPower1 .* hitRate1;

cannonPower2 = cannonPower2 .* hitRate2;
crewPower2 = crewPower2 .* hitRate2;


%% BATTLE!

life1 = totalLife1 - cannonPower2;
life2 = totalLife2 - cannonPower1;

% Cannons
for turn = 1:14
	
	% who's fighting?
	b = ( life1 ./ totalLife1 > 0.25 ) & ( life2 ./ totalLife2 > 0.25 );
	if ~any( b )
		break;
	end
	
	% update lives
	life1(b) = life1(b) - cannonPower2(b);
	life2(b) = life2(b) - cannonPower1(b);
	
end

% Crew
for turn = 1:100
	
	% who's fighting?
	b = life1 > 0 & life2 > 0;
	if ~any( b )
		break;
	end
	
	% update lives
	life1(b) = life1(b) - crewPower2(b);
	life2(b) = life2(b) - crewPower1(b);
	
end

end