CREATE procedure "informix".sp_ctes_osi()
returning char(5);

    DEFINE vsqlerr          integer;
    DEFINE vsecuencia       int ;
    DEFINE vnumerocalle     int ;
    DEFINE vnumerocolonia   int ;
    DEFINE vcodret          char(5);
    DEFINE vcte             char(20);
    DEFINE vcte2             char(20);
    DEFINE vcte3             char(20);
    DEFINE vcasa           char(10);
    DEFINE vcelular         char(10);
    DEFINE vrfc    char(13);
 
    LET vcodret            = "00000";
    LET  vsqlerr           = 0;
    LET vsecuencia         = 0;
    LET vcte          = '';
    LET vcte2          = '';
    LET vcte3          = '';
    LET vcasa          = '';
    LET vcelular         = '';
    LET vrfc             = '';
--     set debug file to "/DBA/Juancho/INC/tiktok/direc.out";
--     trace on;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            return  vcodret  ;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

BEGIN WORK;
    FOREACH cte_cursor FOR
        SELECT rfc, tel_casa, celular
          INTO  vrfc, vcasa, vcelular
          FROM osi_20220817 osi
      

        SELECT FIRST 1 numcte 
          INTO vcte
          FROM si_cliente cte
          WHERE rfc[1,10] = vrfc[1,10];

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			CONTINUE FOREACH;
        ELSE 
           UPDATE osi_20220817 SET numcte=vcte WHERE CURRENT OF cte_cursor;
		END IF;

        SELECT FIRST 1 numcte
          INTO vcte2
          FROM bdinteg:si_telefonos
         WHERE numcte = vcte 
           AND telefono = vcasa
           AND tipo_tel ='1' AND status_tel='A';

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET vcte2='';
        ELSE 
           UPDATE osi_20220817 SET casa='1' WHERE CURRENT OF cte_cursor;
		END IF;

        SELECT FIRST 1 numcte
          INTO vcte3
          FROM bdinteg:si_telefonos
         WHERE numcte = vcte 
           AND telefono = vcelular
           AND tipo_tel ='2' AND status_tel='A';

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET vcte3='';
        ELSE 
           UPDATE osi_20220817 SET cel='1' WHERE CURRENT OF cte_cursor;
		END IF;
        LET vcte='';
        
		
    END FOREACH;

COMMIT WORK;
    return  vcodret;

    END
    
end procedure
;