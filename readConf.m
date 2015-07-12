function finalConf = readConf( path )
% conf = READCONF( path ) lit le fichier de configuration
%
%	path est une string contenant le chemin du fichier de configuration.
%	conf est une structure repr�sentant le fichier de configuration.
%
%	Le fichier de configuration est format�e selon les r�gles suivantes:
%   - les lignes commen�ant par # ou ; sont ignor�es (commentaires)
%	- chaque variable est indiqu� sous la forme clef=valeur
%		* les espaces en d�but de ligne, autour du = et en fin de ligne
%		sont supprim�s
%		* les commentaires ne sont pas autoris�s
%		* chaque variable cr�e un champs dans la structure retourn�e
%		* les valeur sont cast�s en double, en array (notation
%		[ val1 val2 ... ]) ou en cell (notation { val1 val2 ... } ) si
%		possible
%	- une section est d�finie par son nom entre crochet: [section]
%		* les espaces sont supprim�s autour du nom de la section
%		* chaque section cr�e un champ dans la stuture retourn�e
%		* les variables d�finies dans la section seront des sous-champs
%		dans la structure retourn�e
%		* les commentaires sont autoris�s apr�s le crochet fermant
%	

finalConf = struct();

% ouverture du fichier
fid = fopen( path, 'r' );
if fid == -1, error( 'READCONF:OpenFile', 'The file can''t be opened' ); end

% boucle principale
currentName = '';
currentConf = struct();
line = fgetl( fid );

while ischar( line )
	
	line = strtrim( line );
	
	if ~( checkEmptyLine( line ) || ...
			checkComment( line ) || ...
			checkNewSection( line ) || ...
			checkNewValue( line ) )
		error( 'READCONF:UnexpectedLine', 'Unexpected line:%s', line );
	end
	
	line = fgetl( fid );
	
end

fclose( fid );

% ajout de la derni�re section lue
addSection( currentName, currentConf );

	function addSection( name, conf )
		% ajout d'une section dans la structure
		
		if isempty( name )
			% pas d'utilisation de section
			finalConf = conf;
			
		elseif isfield( finalConf, name )
			% ajoute dans un struct array
			finalConf.(name) = [ finalConf.(name) conf ];
			
		else
			finalConf.(name) = conf;
			
		end
		
	end

	function ok = checkEmptyLine( line )
		% v�rification ligne vide
		ok = isempty( line );
	end

	function ok = checkComment( line )
		% v�rification commentaire
		ok = ( line(1) == ';' || line(1) == '#' );
	end

	function ok = checkNewSection( line )
		% v�rification nouvelle section
		
		m = regexp( line, '^\[\s*(?<name>\w+)\s*\](?:\s*(#|;).*)?$', 'names' );
		if ~isempty( m )
			
			% enregistrement de l'ancienne section
			addSection( currentName, currentConf );
			
			% demarre une nouvelle section
			currentName = m.name;
			currentConf = struct();
			
			ok = true;
			
		else
			ok = false;
			
		end
		
	end

	function ok = checkNewValue( line )
		% v�rification nouveau param�tre
		
		match = regexp( line, '^(?<name>\w+)\s*=\s*(?<value>.*)$', 'names' );
		if ~isempty( match )
			
			value = match.value;
			
			% check casts
			[ value, ok ] = tryCast2double( value );
			if ~ok && ~isempty( value )
				
				iscellDel = value(1)=='{' && value(end)=='}';
				isarrayDel = value(1)=='[' && value(end)==']';
				if iscellDel || isarrayDel
					m = regexp( value(2:end-1), '[^,]+', 'match' );
					value = cellfun( @strtrim, m, 'UniformOutput', false );
					value = deblank( value );
					
					nbValue = length( value );
					isarray = true;
					for i = 1:nbValue
						[ value{i}, isnum ] = tryCast2double( value{i} );
						isarray = isarray && isnum;
					end
					
					if nbValue==1 && isempty( value{1} ), value = {}; end
					
					if isarrayDel && isarray, value = [ value{:} ]; end
					
				end
				
			end
			
			currentConf.( match.name ) = value;
			
			ok = true;
			
		else
			ok = false;
		end
		
	end

	function [ value, ok ] = tryCast2double( value )
		tmp = str2double( value ); ok = false;
		if ~isnan( tmp )
			value = tmp;
			ok = true;
		end
	end

end
