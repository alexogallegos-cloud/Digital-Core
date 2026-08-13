CREATE PROCEDURE "informix".diferenciadlaborables ( pdInicio DATE, pdFin DATE )
	RETURNING CHAR (5) AS Retorno,
		CHAR(150) AS ErrorActividad,
		INTEGER AS DiasDiferencia;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION: Diferencia de días laborales   ------------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 03/02/2012  ------------------------------------------------------------------------------
	-- BD: bdibpi  --------------------------------------------------------------------------------------
	-- SISTEMA : ICCAT Y BPI  ---------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE vsErrorActividad CHAR(150);
	
	DEFINE vdFechaAux DATE;
	DEFINE vdFechaAuxSp DATE;
	DEFINE viDias INTEGER;
	DEFINE vsRetornoSp CHAR(5);
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET vsErrorActividad ='';
	
	LET vdFechaAux = CURRENT;
	LET vdFechaAuxSp = CURRENT;
	LET viDias = 0;
	LET vsRetornoSp = '';
	
	BEGIN

		ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
			LET vssqlerr = viCodigo;
			LET vsErrorActividad = 'ERROR ' || TRIM(vssqlerr) ||' ISAM '|| isam_err ||' INFORMIX '||TRIM(error_info) || ' EN diferenciaDLaborables';
			RETURN 	NVL(vssqlerr,''),
				NVL(vsErrorActividad,''),
				NVL(viDias,0);
					
		END EXCEPTION;

		--SET DEBUG FILE TO '/home/sysifx/soporte/iccat/TraceSPDIFERENCIADLABORABLES.txt';
		--SET DEBUG FILE TO '/tmp/iccat/TraceSPDIFERENCIADLABORABLES.txt';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
			
		LET vdFechaAux = pdInicio;

		IF(pdInicio<pdFin)THEN 
			
			WHILE (vdFechaAux  <  pdFin)
				EXECUTE PROCEDURE bdinteg:"informix".sp_valfecha_banca('001',vdFechaAux,0) 
				INTO vsRetornoSp, vdFechaAuxSp;
				
				IF (vdFechaAuxSp = vdFechaAux)THEN 
				--- ES DIA DE TRABAJO
					LET vdFechaAuxSp = vdFechaAuxSp + 1 UNITS DAY;
					LET viDias = viDias + 1;
				END IF;
				
				IF(vsRetornoSp='000' )THEN
					LET vdFechaAux = vdFechaAuxSp;

					IF (vdFechaAux  >=  pdFin) THEN 
						EXIT WHILE;
					END IF;
					
				ELSE
					--OCURRIO UN ERROR EN EL SP
					LET vssqlerr = vsRetornoSp;
					LET vsErrorActividad = 'OCURRIO UN ERROR EN EL sp_valfecha_banca ';
					EXIT WHILE;
				END IF;
				
			END  WHILE;
		ELSE 
			LET vssqlerr = '00000';
			LET vsErrorActividad = 'LA FECHA FINAL DEBE SER MAS RECIENTE QUE LA FECHA INICIAL ';
		END IF;
		RETURN 	NVL(vssqlerr,''),
			NVL(vsErrorActividad,''),
			NVL(viDias,0);
	END
END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: ICCAT Y BPI',
'Solicito: ISMAEL HERNANDEZ MONROY',
'Descripcion: VALIDA USUARIO AVANZADO',
'Fecha: 2012/02/13',
'Version: 20120213.1103',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_validausuarioavanzado ( psNumCte CHAR(9) )
	RETURNING CHAR (5) AS Retorno,
		CHAR(150) AS ErrorActividad;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  VALIDA USUARIO AVANZADO  -----------------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 03/02/2012  ------------------------------------------------------------------------------
	-- BD: bdibpi  --------------------------------------------------------------------------------------
	-- SISTEMA : ICCAT Y BPI  ---------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE vsErrorActividad CHAR(150);
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET vsErrorActividad ='';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsErrorActividad = 'ERROR ' || TRIM(vssqlerr::CHAR(150)) ||' ISAM '|| isam_err ||' INFORMIX '||TRIM(error_info::CHAR(150)) || ' EN sp_validaUsuarioAvanzado';
		
		RETURN 	NVL(vssqlerr,''),
			NVL(vsErrorActividad,'');
				
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/informix/ivonne/sp_validaUsuarioAvanzado.out';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		IF(NOT EXISTS(SELECT numcte
			FROM bdinteg:"informix".si_bpiusuarios
			WHERE numcte = psNumCte AND servicio = '2')) THEN
		
			LET vssqlerr = '00001';
			LET vsErrorActividad = 'EL USUARIO NO TIENE TOKEN ASIGNADO';
		
		END IF;
		
		RETURN 	NVL(vssqlerr,''),
			NVL(vsErrorActividad,'');
				
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: ICCAT Y BPI',
'Solicito: ISMAEL HERNANDEZ MONROY',
'Descripcion: VALIDA USUARIO AVANZADO',
'Fecha: 2012/02/03',
'Version: 20120203.1103',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_set_statustoken_admtoken(pNumToken char(9), pStatusViejo char(3), pStatusNuevo char(3), pUsrAtendio char(9),pCanal char(2))
   returning char(5) ;

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Actualiza el estatus del token del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 10/11/2009

---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicito: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
--Realizo: Berenice Noriega Guevara
--Modificación:Se modifico para que en caso de que sea desbloqueo (160) grabe en las tablas (140).
--Fecha:11/05/2012
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    
   
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';
    

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

    
    IF EXISTS(SELECT ns_token FROM bdibpi:tkn_nseries WHERE ns_token = pNumToken AND id_status = pStatusViejo) THEN
      IF pStatusNuevo='160' THEN --Cuando es desploqueo guardara en la tkn_nseries 140
	  UPDATE bdibpi:tkn_nseries 
        SET id_status = '140', f_status = current ,canal=pCanal
        WHERE ns_token = pNumToken AND id_status = pStatusViejo; 
		--insertara el 160 152 para que quede evidencia del desbloqueo,y 140 160 para que exista correspondencia
        INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
        VALUES(pNumToken, pStatusViejo, pStatusNuevo, CURRENT, pUsrAtendio,pCanal);
	  INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
        VALUES(pNumToken, pStatusNuevo, '140', CURRENT, pUsrAtendio,pCanal);

	ELSE
	  UPDATE bdibpi:tkn_nseries 
        SET id_status = pStatusNuevo, f_status = current ,canal=pCanal
        WHERE ns_token = pNumToken AND id_status = pStatusViejo; 

        INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
        VALUES(pNumToken, pStatusViejo, pStatusNuevo, CURRENT, pUsrAtendio,pCanal);
	END IF;

    ELSE
        LET cod_ret = '001'; -- No se encontro token con el estatus indicado
    END IF;
    
    RETURN cod_ret;
   
END

END PROCEDURE ;