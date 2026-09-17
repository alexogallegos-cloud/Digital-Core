CREATE PROCEDURE "informix".cons_img_nula1_web(pempresa  CHAR(3),
                                          pcvebanco   	 CHAR(3),
                                          pnumcuenta   	 CHAR(20),
                                          pnumcheque   	 CHAR(7),
                                          plado_ft       CHAR(1),
                                          pfechapresenta CHAR(10))
RETURNING CHAR(5);  

    DEFINE v_codret CHAR(5);
    DEFINE sql_err,isam_err INT;   
	DEFINE iimagen  INT;

    -- // Inicializa variables
    LET v_codret    = "00000";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  IS NULL OR
       pcvebanco      IS NULL OR
       pnumcuenta     IS NULL OR
       pnumcheque     IS NULL OR
       plado_ft       IS NULL OR
       pfechapresenta IS NULL THEN
		LET v_codret = "00110"; -- // datos de entrada incompletos
		RETURN v_codret; 
    END IF;
	
	--SET DEBUG FILE TO "/tmp/Guicho/cons_img_nula1.out";
	--TRACE ON;
    
    BEGIN
		ON EXCEPTION SET sql_err,isam_err
			IF sql_err <> 0 OR isam_err <> 0 THEN
				LET v_codret = sql_err;
				RETURN v_codret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT COUNT(1)
		INTO iimagen
		FROM "informix".cce_cheques_img
		WHERE empresa = pempresa
		AND cvebanco = pcvebanco
		AND numcuenta = pnumcuenta
		AND numcheque = pnumcheque
		AND fechapresenta = today
		AND (imagen IS NULL OR length(imagen::lvarchar) =0);

		IF iimagen > 0 THEN
			LET v_codret = "00130"; 
			RETURN v_codret;  
        END IF;    
    END;
    RETURN v_codret;

END PROCEDURE
DOCUMENT
'FECHA: 30/11/2017',
'AUTOR: Jesus Ivan Garcia Guicho.',
'FOLIO: 1856',
'SUSTENTO: INC 24 066 Cheque en blanco.pdf.',
'SOLICITA: Cutberto Gonzalez Perez.',
'DESCRIPCION: Se modifica nombre del SP para ponerlo en pruebas en piloto.',
'BD: bditef';

create procedure "informix".cons_tels_web(pnumcte char(20))
                        returning char(5),char(13),char(13);

define vcodret char(5);
define vtel1 char(13);
define vtel2 char(13);
DEFINE vsqlerr int;   


let vcodret = "00000";
let vtel1 = " ";
let vtel2 = " ";


begin
        on exception set vsqlerr
        if vsqlerr <> 0 then
                let vcodret = vsqlerr;
                RETURN vcodret, vtel1, vtel2;
        end if
        end exception;
        
	IF  	pnumcte is null then	
		   -- datos de entrada incompletos	   
		LET vcodret = '00110'; 
		RETURN vcodret, vtel1, vtel2;
	END IF;

        FOREACH

                select telefono
                into vtel1
                from bdinteg:si_telefonos_actual
                where numcte = trim(pnumcte)
                and tipo_tel=1
                order by secuencia desc
        
                EXIT FOREACH;
        END FOREACH
        
        FOREACH

                select telefono
                into vtel2
                from bdinteg:si_telefonos_actual
                where numcte = trim(pnumcte)
                and tipo_tel=2
                order by secuencia desc
        
                EXIT FOREACH;
        END FOREACH

        RETURN vcodret, vtel1, vtel2;

end   
end procedure;