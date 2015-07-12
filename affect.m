function varargout = affect( V )
% [ data.field ] = affect( V )
%
%	Affecte chaque vecteur de V à chaque structure de data dans le champs
%	field.
%	
%	Code d'une fonction similaire:
%
%	for k = 1:length( V )
%		data(k).field = V(k);
%	end
%

if numel(V)==1
	V(1:nargout) = V;
end

if size(V,1)==1
	varargout = num2cell( V );
else
	varargout = mat2cell( V, size(V,1), repmat( 1, 1, size(V,2) ) );
end
