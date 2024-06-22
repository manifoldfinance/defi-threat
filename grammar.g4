issues : '[' issue (',' issue)* ']'
issue  : '{' swc ',' severity, ',' description ',' locations '}'

swc    : '{'     'SWC-ID' ':'  STRING
          ( ','  'SWC-title:' STRING ) ?
          ( ',', 'SWC-description:' STRING ) ?
         '}'
	 
severity : [0-4]
         | 'informational'
	 | 'warning' 
	 | 'error'
	 | 'fatal'

description : 'description:' string
            | 'description-lead': string ( ',' 'description-rest' ) ?

locations : srcmap
          | offsets
          | ids
          | line_column_length_files  

offsets : 'offset:' '[' offset (',' offset ) * ']'
        | 'offset:' offset

offset : NUMBER

ids : 'id:' '[' id (',' id ) * ']'
    | 'id:' id

id: NUMBER

line_column_lengths_files : '[' line_column_length_file (',' line_column_length_file ) * ']'
                          | line_column_length_file

line_column_length_file  : 'line:' NUMBER
                          ( ',' 'column:' NUMBER ) ?
  			  ( ',' 'length:' NUMBER ) ?
			    ',' 'filename:' string )


STRING: '"" ~('"')+ '"'
NUMBER [0-9]+
