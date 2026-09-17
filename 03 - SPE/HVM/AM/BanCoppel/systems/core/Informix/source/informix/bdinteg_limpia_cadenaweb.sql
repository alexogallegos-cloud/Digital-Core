CREATE PROCEDURE "informix".limpia_cadenaweb(Ccadena CHAR(100)) 
    returning CHAR(100);
    
    define i integer;
    define Cregreso CHAR(100);
    
    LET i = 0;
    LET Cregreso = '';           
    BEGIN
   
     --SET DEBUG FILE TO "/informix/vic/limpia_cadena_web.out";
     --TRACE ON;
    
        LET Ccadena = trim(Ccadena);
        LET Ccadena = replace(Ccadena,'ÃÂ','A');
        LET Ccadena = replace(Ccadena,'ÃÂ','E');
        LET Ccadena = replace(Ccadena,'ÃÂ','I');
        LET Ccadena = replace(Ccadena,'ÃÂ','O');
        LET Ccadena = replace(Ccadena,'ÃÂ','U');
			
        LET Ccadena = replace(Ccadena,'á','A');
        LET Ccadena = replace(Ccadena,'é','E');
        LET Ccadena = replace(Ccadena,'í','I');
        LET Ccadena = replace(Ccadena,'ó','O');
        LET Ccadena = replace(Ccadena,'ú','U');
        
        LET Ccadena = replace(Ccadena,'Á','A');
        LET Ccadena = replace(Ccadena,'É','E');
        LET Ccadena = replace(Ccadena,'Í','I');
        LET Ccadena = replace(Ccadena,'Ó','O');
        LET Ccadena = replace(Ccadena,'Ú','U');
		
        LET Ccadena = replace(Ccadena,'¾','N');        
        LET Ccadena = replace(Ccadena,'¡','I');
        LET Ccadena = replace(Ccadena,'¤','N');
        LET Ccadena = replace(Ccadena,'§','5');
        LET Ccadena = replace(Ccadena,'ª','A');
        LET Ccadena = replace(Ccadena,'°','RO');
        LET Ccadena = replace(Ccadena,'´',' ');
        LET Ccadena = replace(Ccadena,'·','A');
        LET Ccadena = replace(Ccadena,'ê','U');
        LET Ccadena = replace(Ccadena,'Ñ','N');
        LET Ccadena = replace(Ccadena,'ñ','N');
        LET Ccadena = replace(Ccadena,'Ô','I');
        LET Ccadena = replace(Ccadena,'Ö','E');
        LET Ccadena = replace(Ccadena,'Ü','U');
        LET Ccadena = replace(Ccadena,'Þ','I');
        LET Ccadena = replace(Ccadena,'?','U');
        LET Ccadena = replace(Ccadena,'µ','A');
        LET Ccadena = replace(Ccadena,'¢','O');
        LET Ccadena = replace(Ccadena,'£','U');
        LET Ccadena = replace(Ccadena,'¦','A');
        LET Ccadena = replace(Ccadena,'¥','N');        
                
        
        
        --LET Ccadena = replace(Ccadena,'#','Ã?Ã?');
		--LET Ccadena = trim(Ccadena); -- mover tempo Aqui
		
        For i=1 to length(Ccadena)
        
            IF upper(substr(Ccadena, i,1)) between chr(65) and chr(90) THEN
                continue;
            ELIF upper(substr(Ccadena, i,1)) between chr(48) and chr(57) THEN
                continue;
           -- ELIF upper(substr(Ccadena, i,1)) IN (chr(58),chr(44),chr(45),chr(46),chr(40),chr(41),chr(32),chr(164),chr(165),chr(209),chr(241), chr(13)) THEN
            ELIF upper(substr(Ccadena, i,1)) IN (chr(58),chr(44),chr(45),chr(46),chr(40),chr(41),chr(32),chr(164),chr(165),chr(209),chr(241)) THEN
                continue;
            ELSE
               LET Ccadena = replace(Ccadena,substr(Ccadena,i,1),'');
            END IF;
           
        End For;
        
        LET Ccadena = replace(Ccadena,chr(165),chr(35));
        LET Ccadena = replace(Ccadena,chr(164),chr(35));
        LET Ccadena = replace(Ccadena,chr(209),chr(35));
        LET Ccadena = replace(Ccadena,chr(241),chr(35));
        --LET Ccadena = replace(Ccadena,chr(46),chr(35)); --MACF
        --LET Ccadena = replace(Ccadena,chr(177),chr(35)); --MACF
        
            
        --LET Cregreso = substr(Ccadena, i-1, 1);
        return trim(Ccadena);
    END;
    
END PROCEDURE;