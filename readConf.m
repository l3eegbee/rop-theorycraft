function finalConf = readConf( path )
% conf = READCONF( path ) lit le fichier de configuration
%
%	path est une string contenant le chemin du fichier de configuration.
%	conf est une structure représentant le fichier de configuration.
%
%	Le fichier de configuration est formatée selon les règles suivantes:
%   - les lignes commençant par # ou ; sont ignorées (commentaires)
%	- chaque variable est indiqué sous la forme clef=valeur
%		* les espaces en début de ligne, autour du = et en fin de ligne
%		sont supprimés
%		* les commentaires ne sont pas autorisés
%		* chaque variable crée un champs dans la structure retournée
%		* les valeur sont castés en double, en array (notation
%		[ val1 val2 ... ]) ou en cell (notation { val1 val2 ... } ) si
%		possible
%	- une section est définie par son nom entre crochet: [section]
%		* les espaces sont supprimés autour du nom de la section
%		* chaque section crée un champ dans la stuture retournée
%		* les variables définies dans la section seront des sous-champs
%		dans la structure retournée
%		* les commentaires sont autorisés après le crochet fermant
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

% ajout de la dernière section lue
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
		% vérification ligne vide
		ok = isempty( line );
	end

	function ok = checkComment( line )
		% vérification commentaire
		ok = ( line(1) == ';' || line(1) == '#' );
	end

	function ok = checkNewSection( line )
		% vérification nouvelle section
		
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
		% vérification nouveau paramètre
		
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
