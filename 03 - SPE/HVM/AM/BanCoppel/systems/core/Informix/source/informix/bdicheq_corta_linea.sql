CREATE PROCEDURE "informix".corta_linea(plinea varchar(255), pcaracteres integer)
RETURNING 	NVARCHAR(255),INTEGER;


DEFINE v_caracter 	CHAR(1);
DEFINE v_pos_actual INTEGER;
DEFINE v_pos_blanco INTEGER;
DEFINE v_renglon	VARCHAR(255);
DEFINE v_palabra	VARCHAR(255);

LET v_caracter 		= "";
LET v_pos_actual 	= 1;
LET v_pos_blanco 	= 1;
LET v_renglon		= "";
LET v_palabra	= "";

--SET DEBUG FILE TO "corta_linea.out";
--TRACE ON;
 
BEGIN

	
	LET plinea = TRIM(plinea); 
	
	IF LENGTH(NVL(plinea,'')) = 0 THEN
		RETURN v_renglon,0 ;
	END IF

	WHILE  v_pos_actual <= LENGTH(plinea)  
	
		----------OBTENGO EL CARACTER ACTUAL
		LET v_caracter = SUBSTR(plinea,v_pos_actual,1);
		
		LET v_palabra = v_palabra || v_caracter;
		
		----------OBTENGO LA POSICION DE LA ULTIMA PALABRA ENCONTRADA
		IF v_caracter = " " OR v_pos_actual = LENGTH(plinea) THEN
			IF LENGTH(TRIM(v_palabra)) > 0 THEN
				IF LENGTH(v_renglon || v_palabra) <= pcaracteres 
						AND v_pos_actual < LENGTH(plinea) THEN
						LET v_renglon = v_renglon || v_palabra;
				ELIF LENGTH(v_renglon || v_palabra) <= pcaracteres 
						AND v_pos_actual = LENGTH(plinea) THEN
						LET v_renglon = v_renglon || v_palabra;
						RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
						LET v_renglon = v_palabra;
				ELSE
						RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
						LET v_renglon = v_palabra;
                        if v_pos_actual >= LENGTH(plinea)  then
                          RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
                        end if;
				END IF

			END IF
			LET v_palabra = "";
		END IF;
		
		LET v_pos_actual = v_pos_actual + 1;

	END WHILE

END
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".sp_cortesig(pFecha date, pMeses integer)
 returning char(6), date;

--Juan Andres 27-08-2008

define vCodret char(6);
define dDiaPrimero date;
define dDiaUltimo  date;
define dFechaMesResultante date;
define dDiaUltimoResultante date;
define vsqlerr     integer;
define vccodret char(6);

Begin
        ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                LET  vcCodRet  = vsqlerr;
                RETURN vcCodRet, pFecha;
            END IF;
        END  EXCEPTION

    If day(pfecha) >= 29 then

        -- Tomar el día 1  y hacer suma de meses

        execute procedure sp_diaprimeroultimomesanio(lpad(month(pFecha), 2, '0'), year(pFecha)) into vCodret, dDiaPrimero, dDiaUltimo;

        Let dFechaMesResultante = dDiaPrimero + pMeses units month;

        -- Obtener dia ultimo del mes de la fecha resultante

        execute procedure sp_diaprimeroultimomesanio(lpad(month(dFechaMesResultante), 2, '0'), year(dFechaMesResultante)) 
into vCodret, dDiaPrimero, dDiaUltimoResultante;

        -- Validar si el dia de mesiversario existe en el mes de fecha resultante

        If day(pFecha) > Day(dDiaUltimoResultante)   then --No existe el día

            -- Tomar el día ultimo de ese mes
            return '00', dDiaUltimoResultante;
        else
            -- Día si existe, suma de meses normal.
            return '00', pFecha + pMeses units month;
        end if;
    Else
        return '00', pFecha + pMeses units month;
    End if;

end;
end procedure;