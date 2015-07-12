
%% LOAD ACCESS PARAMETERS

% NEED A FILE access.properties WITH
% user = <user_name>
% password = <user_password>

accessConfig = readConf( 'access.properties' );

%% OPEN SESSION

session = ROPSession();
session.openSession( accessConfig.user, accessConfig.password );

%% SCAN PROFILES

% get all player ids
ids = session.getAllCaptainId();
lids = length( ids );

% load each captain
captains = cell( 1, lids );
hw = waitbar( 0, sprintf( 'loading %.2f ...', 0 ) );
for i = 1:lids
	captains{i} = session.getCaptainData( ids( i ) );
	if mod( i, 15 ) == 0
		waitbar( i/lids, hw, sprintf( 'loading %.2f%% ...', 100*i/lids ) );
	end
end
close( hw );

% extract profiles
extract = @(f) cellfun( @(c) f(c), captains, 'UniformOutput', false );
all_profiles = struct( ...
	'name', extract( @(c) c.name ), ...
	'level', extract( @(c) c.ship.template.id ), ...
	'mechanism', extract( @(c) c.template.mechanism / 100 ), ...
	'charisma', extract( @(c) c.template.charisma / 100 ), ...
	'precision', extract( @(c) c.template.precision / 100 ), ...
	'dodge', extract( @(c) c.template.dodge / 100 ), ...
	'defense', extract( @(c) c.template.defense / 100 ), ...
	'cannon', extract( @(c) c.template.canon / 100 ), ...
	'crew', extract( @(c) c.template.crew / 100 ) );

