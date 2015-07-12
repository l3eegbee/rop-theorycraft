classdef ROPSession < handle
	
	properties( Constant )
		URL_ROOT = 'https://s0.reignofpirates.com/perl/';
	end
	
	properties
		
		cookies = java.util.HashMap();
		xsrf = '';
		
	end
	
	methods
		
		function this = ROPSession()
		end
		
		function openSession( this, user, password, numCaptain )
			
			if nargin == 3, numCaptain = 1; end
			
			this.ropPost( 'account.cgi', struct( ...
				'action', 'password_connect', ...
				'login', user, ...
				'password', password ) );
			players = this.ropPost( 'player.cgi', struct( ...
				'action', 'list_players' ) );
			this.ropPost( 'player.cgi', struct( ...
				'action', 'select_player', ...
				'id', players{1}.stash.players{numCaptain}.id ) );
			this.ropPost( 'player.cgi', struct( ...
				'action', 'get_player' ) );
			
		end
		
		function logout( this )
			
			this.ropPost( 'account.cgi', struct( ...
				'action', 'logout' ) );
			
		end
		
		function ids = getAllCaptainId( this )
			
			ids = [ ...
				this.getAllCaptainIdByFaction( 'good' ) ...
				this.getAllCaptainIdByFaction( 'neutral' ) ...
				this.getAllCaptainIdByFaction( 'bad' ) ];
			
		end
		
		function ids = getAllCaptainIdByFaction( this, faction )
			
			ids = [];
			
			r = this.ropPost( 'ranking.cgi', struct( ...
				'action', 'search_faction', ...
				'tab', faction ) );
			players = r{1}.stash.players;
			
			page = 0;
			
			while ~isempty( players )
				
				ids = [ ids cellfun( @(p) p.id, players ) ]; %#ok<AGROW>
				page = page - 1;
				
				r = this.ropPost( 'ranking.cgi', struct( ...
					'action', 'scroll', ...
					'tab', faction, ...
					'page', page, ...
					'context', 'first' ) );
				players = r{1}.stash.players;
				
			end
			
		end
		
		function captain = getCaptainData( this, id )
			c = this.ropPost( 'ranking.cgi', struct( ...
				'action', 'player_infos', ...
				'id', id ) );
			captain = c{1}.stash.captain;
		end
		
		function rep = ropPost( this, url, params )
			
			url = [ this.URL_ROOT url ];
			
			% encode params
			
			pNames = fields( params );
			nParams = length( pNames );
			
			eParams = cell( 1, nParams );
			for i = 1:nParams
				p = params.( pNames{i} );
				if isnumeric( p )
					p = num2str( p );
				end
				eParams{i} = [ pNames{i} '=' char( java.net.URLEncoder.encode( p ) ) ];
			end
			
			encodedParams = strjoin( eParams, '&' );
			
			% open connection
			connection = java.net.URL( url ).openConnection();
			connection.setDoOutput( true );
			connection.setRequestProperty( 'ContentType', 'application/x-www-form-urlencoded' );
			
			% add cookies
			cookieIte = this.cookies.values().iterator();
			while cookieIte.hasNext()
				connection.addRequestProperty( 'Cookie', cookieIte.next() );
			end
			
			% add xsrf token
			if ~isempty( this.xsrf )
				connection.addRequestProperty( 'X-XSRF-TOKEN', this.xsrf );
			end
			
			% write params
			output = connection.getOutputStream();
			output.write( java.lang.String( encodedParams ).getBytes() );
			output.close();
			
			% get reponse
			inputStream = connection.getInputStream();
			scanner = java.util.Scanner(inputStream).useDelimiter('\\A');
			content = char( scanner.next() );
			
			% get cookies
			newcookies = connection.getHeaderFields().get( 'Set-Cookie' );
			if ~isempty( newcookies )
				for i = 1:newcookies.size()
					cookie = char( newcookies.get( i - 1 ) );
					value = strtok( cookie, ';' );
					name = strtok( value, '=' );
					this.cookies.put( name, value );
				end
			end
			
			% get xsrf token
			token = connection.getHeaderField( 'X-xsrf-token' );
			if ~isempty( token )
				this.xsrf = token;
			end
			
			% parse json
			rep = parse_json( content );
			
		end
		
	end
	
end

