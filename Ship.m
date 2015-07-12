classdef Ship
	
	properties( Constant )
		
		MECA_FACTOR = 1.33 / 100;
		
		CHARI_FACTOR = 1 / 100;
		
		DEF_FACTOR = 0.5 / 100;
		
	end
	
	properties
		
		% Captain
		
		mechanism = 0;
		
		charisma = 0;
		
		precision = 0;
		
		dodge = 0;
		
		defense = 0;
		
		% Ship
		
		cannon = 0;
		
		crew = 0;
		
		pv = 0;
		
		% Alea
		
		loading = 0;
		
		statPoints = 0;
		
	end
	
	methods
		
		function this = Ship( varargin )
			
			if ~isempty( varargin )
				
				if ischar( varargin{1} )
					st = struct( varargin{:} );
				else
					st = struct( ...
						'mechanism', varargin{1}, ...
						'charisma', varargin{2}, ...
						'precision', varargin{3}, ...
						'dodge', varargin{4}, ...
						'defense', varargin{5}, ...
						'cannon', varargin{6}, ...
						'crew', varargin{7}, ...
						'pv', varargin{8}, ...
						'loading', varargin{9}, ...
						'statPoints', varargin{10} );
				end
				
				this.mechanism = st.mechanism;
				this.charisma = st.charisma;
				this.precision = st.precision;
				this.dodge = st.dodge;
				this.defense = st.defense;
				this.cannon = st.cannon;
				this.crew = st.crew;
				this.pv = st.pv;
				this.loading = st.loading;
				this.statPoints = st.statPoints;
				
			end
			
			
		end
		
		function [ totalLife, totalCannon, totalCrew, totalPrecision, totalDodge ] = getBattleState( array )
			
			array_mechanism = [ array.mechanism ];
			array_charisma = [ array.charisma ];
			array_precision = [ array.precision ];
			array_dodge = [ array.dodge ];
			array_defense = [ array.defense ];
			array_pv = [ array.pv ];
			array_cannon = [ array.cannon ];
			array_crew = [ array.crew ];
			array_loading = [ array.loading ];
			array_statPoints = [ array.statPoints ];
			
			totalLife = floor( array_pv .* ( 1 + array_statPoints .* array_defense * Ship.DEF_FACTOR ) );
			
			baseCannon = floor( array_loading .* array_cannon );
			totalCannon = baseCannon + floor( baseCannon .* array_statPoints .* array_mechanism * Ship.MECA_FACTOR );
			
			baseCrew = floor( array_loading .* array_crew );
			totalCrew = baseCrew + floor( baseCrew .* array_statPoints .* array_charisma * Ship.CHARI_FACTOR );
			
			totalPrecision = floor( array_statPoints .* array_precision );
			
			totalDodge = floor( array_statPoints .* array_dodge );
			
		end
		
		function display( this )
			
			function dispCaptainValue( name, field )
				fprintf( [ '   ' name ' : %5.2f%% (%3d)\n' ], this.(field) * 100, floor( this.(field) * this.statPoints ) );
			end
			
			function dispShipValue( name, field, base, captainField, factor )
				prct = this.(field);
				value = floor( prct * base );
				boost = floor( value * this.(captainField) * this.statPoints * factor );
				fprintf( [ '   ' name ' : %5.2f%% (%5d = %5d + %5d)\n' ], prct * 100, value + boost, value, boost );
			end
			
			if size( this(:) ) == 1
								
				fprintf( 'Ship\n' );
				fprintf( ' --\n' );
				fprintf( '   loading   : %.2f\n', this.loading );
				fprintf( '   stat pts  : %.2f\n', this.statPoints );
				fprintf( ' --\n' );
				dispCaptainValue( 'mechanism', 'mechanism' );
				dispCaptainValue( 'charisma ', 'charisma' );
				dispCaptainValue( 'precision', 'precision' );
				dispCaptainValue( 'dodge    ', 'dodge' );
				dispCaptainValue( 'defense  ', 'defense' );
				fprintf( ' --\n' );
				dispShipValue( 'cannon   ', 'cannon', this.loading, 'mechanism', Ship.MECA_FACTOR );
				dispShipValue( 'crew     ', 'crew', this.loading, 'charisma', Ship.CHARI_FACTOR );
				
				basePV = floor( this.pv );
				boostPV = floor( this.pv * this.defense * this.statPoints * Ship.DEF_FACTOR );
				fprintf( '   PV        : %5d = %5d + %5d\n', basePV + boostPV, basePV, boostPV );

			else
				fprintf( 'Ship fleet: [ %d x %d ]\n', size( this ) );
			end
			
		end
		
	end
	
	methods( Static )
		
		function [ hitRate1, hitRate2 ] = getHitRate( precision1, dodge1, precision2, dodge2 )
			
			function h = hit( p, d )
				h = max( 0.25, 1 - max( 0, ( d - p ) ./ d ) );
			end
			
			hitRate1 = hit( precision1, dodge2 );
			hitRate2 = hit( precision2, dodge1 );
			
		end
		
	end
	
end