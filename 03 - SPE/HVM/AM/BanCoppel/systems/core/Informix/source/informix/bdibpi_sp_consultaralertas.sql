CREATE PROCEDURE "informix".sp_consultaralertas (pDesde INTEGER, pNumRegistros INTEGER)
	RETURNING CHAR (5) AS Retorno,
		CHAR(150) AS ErrorActividad,
		CHAR(10) AS Solicitud,
		CHAR(9) AS NumCte,
		CHAR(200) AS NombreCompleto,
		CHAR(20) AS Fec_alerta,
		CHAR(20) AS vsIdStatus,
		CHAR(20) AS Fecstatus,
		CHAR(20) AS Dias;
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE ALERTAS   --------------------------------------------------------------
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

	DEFINE vsSolicitud CHAR(10);
	DEFINE vsNumCte CHAR(9);
	DEFINE vsNombreCompleto CHAR(200);
	DEFINE vdFec_alerta DATE;
	DEFINE vsFec_alerta CHAR(20);
	DEFINE viIdStatus SMALLINT;
	DEFINE vsIdStatus CHAR(20);
	DEFINE vdFecstatus DATE;
	DEFINE vsFecstatus CHAR(20);

	DEFINE vdFechaAux DATE;
	DEFINE viDias INTEGER;
	DEFINE vsDias CHAR(20);
	DEFINE vsRetornoSp CHAR(5);

	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET vsErrorActividad ='';

	LET vsSolicitud = '';
	LET vsNumCte = '';
	LET vsNombreCompleto = '';
	LET vdFec_alerta = CURRENT::DATE;
	LET vsFec_alerta = CAST(CURRENT::DATE AS CHAR(20));
	LET viIdStatus = 0;
	LET vsIdStatus = '';
	LET vdFecstatus = CURRENT::DATE;
	LET vsFecstatus = CAST(CURRENT::DATE AS CHAR(20));

	LET vdFechaAux = CURRENT::DATE;
	LET viDias = 0;
	LET vsDias = '0';
	LET vsRetornoSp = '00000';

	SET LOCK MODE TO WAIT 10;

	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsErrorActividad = 'ERROR ' || TRIM(vssqlerr) ||' ISAM '|| isam_err ||' INFORMIX '||TRIM(error_info) || ' EN sp_consultarAlertas';

		RETURN
			NVL(vssqlerr,''),
			NVL(vsErrorActividad,''),
			NVL(vsSolicitud,''),
			NVL(vsNumCte,''),
			NVL(vsNombreCompleto,''),
			NVL(vsFec_alerta,''),
			NVL(vsIdStatus,''),
			NVL(vsFecstatus,''),
			NVL(vsDias,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/iccat/TraceSPCONSULTARALERTAS.txt';
	--SET DEBUG FILE TO '/home/informix/ivonne/SPCONSULTARALERTAS.out';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;


		FOREACH
			SELECT SKIP pDesde LIMIT pNumRegistros solicitud, numcte, nombre, fec_alerta, id_status, fecstatus
			INTO vsSolicitud, vsNumCte, vsNombreCompleto, vdFec_alerta, viIdStatus, vdFecstatus
			FROM BDIBPI:"informix".tkn_reporte
			WHERE id_status IN (1,3)
			ORDER BY solicitud

				LET vsFec_alerta = CAST(vdFec_alerta AS CHAR(20));
				LET vsFecstatus = CAST(vdFecstatus AS CHAR(20));
				LET vsIdStatus = viIdStatus;

				IF (viIdStatus = 1)THEN
					LET vdFechaAux = vdFec_alerta;
				ELIF (viIdStatus = 3)THEN
					LET vdFechaAux = vdFecstatus;
				END IF;

				EXECUTE PROCEDURE bdibpi:"informix".diferenciaDLaborables ( vdFechaAux, current )
					INTO vsRetornoSp, vsErrorActividad, viDias;
				LET vsDias = CAST(viDias AS CHAR(20));
				LET vssqlerr = vsRetornoSp;
				IF ((viDias>5)AND(viIdStatus=1))THEN
					UPDATE BDIBPI:"informix".tkn_reporte
					SET id_status = 3, fecstatus = current
					WHERE solicitud = vsSolicitud and numcte = vsNumCte;
				END IF;

			RETURN
				NVL(vssqlerr,''),
				NVL(vsErrorActividad,''),
				NVL(vsSolicitud,''),
				NVL(vsNumCte,''),
				NVL(vsNombreCompleto,''),
				NVL(vsFec_alerta,''),
				NVL(vsIdStatus,''),
				NVL(vsFecstatus,''),
				NVL(vsDias,'')
				WITH RESUME;

		END FOREACH;

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: ICCAT Y BPI',
'Solicito: ISMAEL HERNANDEZ MONROY',
'Descripcion: CONSULTA DE ALERTAS',
'Fecha: 2012/02/03',
'Version: 20120203.1103',
'BD: bdibpi',
'******************************',
'MODIFICÓ: Walber Castro',
'Razón: Se agrega paginación a la consulta',
'Fecha: 2012/04/16';

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