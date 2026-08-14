CREATE PROCEDURE "informix".sp_verifica_cp_o_st
											(
												numtarjeta char(16),
												fecha	   date
											)
RETURNING 	VARCHAR(6) as Cod_ret,
			VARCHAR(80) as Men_ret,
			CHAR(16) as numtarjeta,
			DATETIME YEAR TO FRACTION (5) as fechacambio,
			CHAR (45) as usuario,
			char  (30) as desccambio;


-- Variables generales 

	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	
-- Variables de retorno
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	
	DEFINE  vexiste             INTEGER;
	DEFINE  vtarjeta            CHAR (16);
	DEFINE  vfechacambio        DATETIME YEAR TO FRACTION (5);
	DEFINE  vusuario		    CHAR (45);
	DEFINE  vdescripcioncambio  CHAR (30);	
	
	--SET DEBUG FILE TO "/informix/HomeInformix/rrm/sp_verifica.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET  = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
	  
      RETURN 	NVL(P_COD_RET,''),
				NVL (P_MENSAJE,''),
				NVL(vtarjeta,''),
				NVL(vfechacambio,''),
				NVL(vusuario,''),
				NVL(vdescripcioncambio,'');	  
	  
   END EXCEPTION;

--*******************************************************************************
-- Creado por Ricardo Reséndiz Martinez 
-- fecha : Mayo/2013
-- Funcion: Verifica cambios de codigo producto o status tarjeta en la bitacora  
--********************************************************************************
	
	LET  vexiste  = '';
	LET  vtarjeta  = '';
	LET  vusuario = '';
	LET  vfechacambio = current;
	LET  vdescripcioncambio  = '';	
	
	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'No existe registro';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	select count(*) into vexiste
		FROM "informix".bitacoracambiostarjeta
			WHERE 	tarjeta = numtarjeta and
					fechacambio:: date = fecha;
	
	
	if (vexiste > 0) then
		FOREACH
			SELECT limit 1 tarjeta, 
					fechacambio, 
					case 
						when usuariocambio = 'informix' 
							then 'USUARIO_SISTEMAS'
						when usuariocambio = 'interact'
							then 'PROCESO_BACH'
						when usuariocambio = 'paytrue'
							then 'PREVENCION_FRAUDES'
						else
							(select nombre from Bdinteg:"informix".si_ejecut where ejecutivo = substr (usuariocambio,2,8))
						end as usuario,
					descripcioncambio
				INTO 
					vtarjeta,
					vfechacambio,
					vusuario,
					vdescripcioncambio
				FROM "informix".bitacoracambiostarjeta
					WHERE 	tarjeta = numtarjeta and
							fechacambio:: date = fecha
			ORDER BY fechacambio DESC
			
			LET P_COD_RET = '00001';
			LET P_MENSAJE = 'El registro ya fue actualizado hoy';
			
			RETURN NVL(P_COD_RET,''), 
			NVL(P_MENSAJE,''),
			NVL(vtarjeta,''),
			NVL(vfechacambio,''),
			NVL(vusuario,''),
			NVL(vdescripcioncambio,'')
			WITH RESUME;
		END FOREACH;
	else 
			RETURN NVL(P_COD_RET,''), 
					NVL(P_MENSAJE,''),
					NVL(vtarjeta,''),
					NVL(vfechacambio,''),
					NVL(vusuario,''),
					NVL(vdescripcioncambio,'')
					WITH RESUME;

	end if;

END;
END PROCEDURE;