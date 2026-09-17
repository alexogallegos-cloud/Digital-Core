CREATE PROCEDURE "informix".limpia_cadena(Ccadena CHAR(100)) 
    returning CHAR(100);
    
    define i integer;
    define Cregreso CHAR(100);
    
    LET i = 0;
    LET Cregreso = '';

    BEGIN
   
     --SET DEBUG FILE TO "/ifxsif01/macf/limpia_cadena.out";
     --TRACE ON;
    
        LET Ccadena = trim(Ccadena);
        LET Ccadena = replace(Ccadena,'Á','A');
        LET Ccadena = replace(Ccadena,'É','E');
        LET Ccadena = replace(Ccadena,'Í','I');
        LET Ccadena = replace(Ccadena,'Ó','O');
        LET Ccadena = replace(Ccadena,'Ú','U');
    
        LET Ccadena = replace(Ccadena,'Ä','A');
        LET Ccadena = replace(Ccadena,'Ë','E');
        LET Ccadena = replace(Ccadena,'Ï','I');
        LET Ccadena = replace(Ccadena,'Ö','O');
        LET Ccadena = replace(Ccadena,'Ü','U');
        
        LET Ccadena = replace(Ccadena,'#','Ñ');
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