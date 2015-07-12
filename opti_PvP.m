
% NEED loadProfiles

%% GENERATE TEST POOL

sizePool = 2500;

pool = repmat( Ship(), 1, sizePool );

% filter profile by level
profiles = all_profiles( [ all_profiles.level ] >= 2 );

% set profile
idx = ceil( rand( 1, sizePool ) * size( profiles, 2 ) );
[ pool.mechanism ] = affect( [ profiles(idx).mechanism ] );
[ pool.charisma ] = affect( [ profiles(idx).charisma ] );
[ pool.precision ] = affect( [ profiles(idx).precision ] );
[ pool.dodge ] = affect( [ profiles(idx).dodge ] );
[ pool.defense ] = affect( [ profiles(idx).defense ] );
[ pool.cannon ] = affect( [ profiles(idx).cannon ] );
[ pool.crew ] = affect( [ profiles(idx).crew ] );

% PV
% def = [ 1500 6000 13500 24000 ]
[ pool.pv ] = affect( 13500 );

% loading
% def = [ (10*??) (20*24) (30*36) (40*??) ]
[ pool.loading ] = affect( 30*(24 + rand(1,sizePool)*12) );

% stats points
% def = capt_level * 5 + ITEMS
[ pool.statPoints ] = affect( 20*5 + floor( 100 + randn(1,sizePool)*10 ) );

%% OPTIMIZATION

% create ship from profile
ship = @(x) Ship( ...
	'mechanism', x(1), ...
	'charisma', x(2), ...
	'precision', x(3), ...
	'dodge', x(4), ...
	'defense', x(5), ...
	'cannon', x(6), ...
	'crew', x(7), ...
	'pv', 13500, ...
	'loading', 1000, ...
	'statPoints', 220 );

% optimization

% optifun = @(x) -sum( battle( ship(x), pool ) > 0 ); % max battle win
optifun = @(x) -sum( max( 0, battle( ship(x), pool ) ) ); % min PV loose

X = ga( optifun, 7, ...
	[], [], ...
	[ 1 1 1 1 1 0 0; 0 0 0 0 0 1 1 ], [ 1; 1 ], ...
	[ 0 0 0 0 0 0 0 ], [ 1 1 1 1 1 1 1 ] );

S = ship( X );

%% DISPLAY RESULTS

S %#ok<NOPTS>

poolIssues = battle( S, pool );
fprintf( 'Win rate: %5.2f%%\n', mean( poolIssues > 0 )*100 );

