CREATE PROCEDURE "informix".sp_espacios_blancos2( pcadena CHAR(50) )
RETURNING CHAR(30) as posicion;   
   
    DEFINE  isqlerr INTEGER;   
    DEFINE     ciclo    INTEGER;
    DEFINE    l       INTEGER;
    DEFINE    vp      INTEGER;
    DEFINE  cont    INTEGER;
    DEFINE     aux        INTEGER;   
BEGIN
        LET l=1;
        let aux =1;
        LET ciclo = LENGTH(pcadena);
        let cont = 1;
        IF  ciclo > 0 THEN       
	   
			IF (CHARINDEX(' ',trim(pcadena),cont)) > 0 then
	   
				SET ISOLATION TO DIRTY READ;
					WHILE (l <> 0 )               
						let vp=  CHARINDEX(' ',trim(pcadena),cont)  ;           
					if vp <> 0 then
							if aux = 1 THEN
								RETURN SUBSTR(pcadena,l,vp) WITH RESUME;
								--RETURN vp WITH RESUME;
								ELSE
								RETURN SUBSTR(pcadena,l+1,(vp-1)- (l)  ) WITH RESUME;
							end IF                      
						ELSE               
							RETURN SUBSTR(pcadena,l+1,(ciclo)- (l)  ) WITH RESUME;
										  
					end if                                   
					  LET l =  vp;
					  let cont =vp + 1;
					  let aux = aux + 1;
					END WHILE
			ELSE
				RETURN pcadena WITH RESUME;
			END IF;	
        END IF
       
END
END PROCEDURE;