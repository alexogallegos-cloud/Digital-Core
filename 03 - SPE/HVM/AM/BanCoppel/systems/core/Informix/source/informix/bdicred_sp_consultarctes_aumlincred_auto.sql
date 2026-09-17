CREATE PROCEDURE "informix".sp_consultarctes_aumlincred_auto( pEmpresa char(3),
																pNumCte char(20),
																pRFC char(13),
																pNumTarjeta char(20),
																pTipoConsulta char(2),
																pSucursal char(4),
																pRegistros integer,
                                                                pMonitor integer)
RETURNING 	char(5) as codigoRetorno,
			char(80) as mensaje,
			char(1) as vIsCtePros,
			char(20) as NumCte,
			char(120) as NomCte,
			char(13) as RFC,
			date as FechaSol,
			date as FechaAut,
			decimal(18,2) as LinCredAct,
			decimal(18,2) as LincredCal,
			char(1) as origen,
			char(2) as Status,
			char(40) as DescStatus,
			char(80) as Comentario,
			char(20) as NumSol,
			char(20) as NumTarjeta,
			char(1) as incrementoAutomatico	;

---DECLARACIONES
DEFINE cod_ret char(5);
DEFINE vRespCte char(2);
DEFINE vCont smallint;
DEFINE vIsCtePros char(1);
DEFINE sql_err integer;
DEFINE vMen char(80);
DEFINE vFechaIni date;
DEFINE vFechaFin date;
DEFINE vRFC char(13);
DEFINE vFechaSol date;
DEFINE vFechaAut date;
DEFINE vLinCredAct decimal(18,2);
DEFINE vLinCredCal decimal(18,2);
DEFINE vOrigen char(1);
DEFINE vStatus char(2);
DEFINE vComentario char(80);
DEFINE vNombre char(120);
DEFINE vNumCte char(20);
DEFINE iIsamErr smallint;
DEFINE cErrorInfo char(80);
DEFINE vDias smallint;
DEFINE vReg char(5);
DEFINE vNumSol char(20);
DEFINE vDescStatus char(40);
DEFINE siContReg SMALLINT;
DEFINE vestatus_cred char(2);
DEFINE vFechaInsert date;
DEFINE cNumTarjeta char(20);
DEFINE cIncreAuto char(1);
DEFINE iCont SMALLINT;
DEFINE cMtoVen DECIMAL(18,2);

---INICIALIZACIONES
LET cod_ret = '00000';
LET vRespCte = '';
LET vCont = 0;
LET vIsCtePros = 'N';
LET sql_err = 0;
LET vMen = 'El proceso se ejecuto correctamente';
LET vFechaIni = date(1);
LET vFechaFin = date(1);
LET vRFC = '';
LET vFechaSol = date(1);
LET vFechaAut = date(1);
LET vLinCredAct  = 0;
LET vLinCredCal = 0;
LET vOrigen = '';
LET vStatus = '';
LET vComentario = '';
LET vNombre = '';
LET vNumCte = '';
LET iIsamErr = 0;
LET cErrorInfo = '';
LET vDias = 0;
LET vReg = '';
LET vNumSol = '';
LET vDescStatus = '';
LET siContReg = 0;
LET vestatus_cred = '';
LET vFechaInsert = date(1);
LET cNumTarjeta = '';
LET cIncreAuto= '';
LET iCont = 0 ;
LET cMtoVen = 0;

BEGIN


	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
		LET cod_ret = sql_err;
	 	LET vMen= cErrorInfo;
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/sp_consultarctesincrementolincred.out";
--TRACE ON ;

	IF (((NVL(pEmpresa,"") = "") OR	(NVL(pTipoConsulta,"") = "")) OR ((NVL(pNumCte,"") = "")  AND (NVL(pSucursal,"") = "") AND  (NVL(pRFC,"") = "") AND (NVL(pNumTarjeta,"") = ""))) THEN
		LET cod_ret = '452';
		LET vMen = 'Parametros insuficientes para llevar a cabo la consulta'; -- Faltan ingresar parametros
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
	END IF;
	
	IF (NVL(pRFC,"") <> "") THEN

		SELECT first 1 numcte 
		INTO pNumCte
		FROM bdinteg:si_cliente 
		WHERE rfc = pRFC; 
	
        IF (pNumCte IS NULL OR pNumCte = '') then
			LET cod_ret = '450';
			LET vMen = 'El Cliente especificado no existe'; -- no existe Cliente
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
		
	END IF;

	IF (NVL(pNumCte,"") <> "")  THEN

		SELECT COUNT(*) 
		INTO vReg
		FROM bdinteg:si_cliente 
		WHERE numcte = pNumCte; 
		
		IF vReg = 0 THEN
			LET cod_ret = '450';
			LET vMen = 'El Cliente especificado no existe'; -- no existe Cliente
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
		
	END IF;

    IF (NVL(pNumTarjeta,"") <> "") THEN
		IF (SELECT COUNT(num_tarjeta) FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa and num_tarjeta = pNumTarjeta) = 0 THEN
			LET cod_ret = '451';
			LET vMen = 'El Numero de Tarjeta no existe'; -- no existe No. Tarjeta
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;

		SELECT first 1 numcte 
		  INTO pNumCte
          FROM bdicred:sd_tarjeta 
         WHERE empresa = pEmpresa
           and num_tarjeta = pNumTarjeta 
           and tipo_tarjeta = 'T';

        IF (pNumCte IS NULL OR pNumCte = '') then
			LET cod_ret = '454';
			LET vMen = 'La tarjeta no es titular'; -- no existe No. Tarjeta
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
	END IF;

	
--se agrega validacion para consulta de cliente con incremento Automatico requerimiento 1229
	IF pMonitor = 0 THEN
			SELECT first 1 a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
				   a.rfc, NVL(b.ajuste_de_cuota,"N"),c.num_tarjeta,b.num_solicitud
			INTO vNumCte, vNombre, vRFC, cIncreAuto, cNumTarjeta,vNumSol
			FROM  bdinteg:"informix".si_cliente a 
			INNER JOIN bdisolic:"informix".ss_solicitudes b on b.empresa = a.empresa AND a.numcte = b.numcte
			INNER JOIN bdicred:"informix".sd_tarjeta c on c.empresa = a.empresa AND a.numcte = c.numcte AND c.tipo_tarjeta='T'
			WHERE a.empresa = pEmpresa
			  AND a.numcte = pNumCte
              AND b.status_solicitud = 'AP';   --FMV 2-JUN-11 Se adiciona estatus para q filtre exclusivamente la tarjeta aprobada
			
			LET iCont = dbinfo("sqlca.sqlerrd2");
			IF iCont = 0 THEN
				LET cod_ret = '453';
				LET vMen = 'No existe cliente con los parametros especificados';	
			END IF;
					
		    RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
	END IF;	
	
	SELECT fecha_hoy INTO vFechaFin FROM bdicred:sd_fechas WHERE empresa = pEmpresa;

	SELECT TRIM(valor) INTO vDias FROM bdicred:sd_param WHERE empresa = pEmpresa and cod_param = '011';

	LET vFechaIni = vFechaFin - vDias UNITS DAY;
    IF pMonitor = 1 THEN
       IF (NVL(pNumTarjeta,"") <> "" or NVL(pRFC,"") <> "" or NVL(pNumCte,"") <> "") THEN
                SELECT first 1 a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
                       a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, d.descripcion, b.fecha_insert
                INTO vNumCte, vNombre, vRFC, vFechaAut, vLinCredAct, vLinCredCal, vOrigen, vStatus, vNumSol, vDescStatus, vFechaInsert
                FROM  bdicred:sd_bitacora_aumlincred b
                INNER JOIN bdinteg:si_cliente a ON (a.empresa = b.empresa and a.numcte = b.numcte)
                INNER JOIN bdicred:sd_status_aumlincred d ON (d.empresa = b.empresa and d.status = b.status )
                WHERE b.empresa = pEmpresa
                  and b.numcte = pNumCte
				  and b.status in ('AT', 'IN')
                  and b.fecha_insert between vFechaIni and vFechaFin;

                IF (vNumCte IS NULL OR vNumCte = '') THEN
                    LET cod_ret = '453';
                    LET vMen = 'No existe cliente con los parametros especificados';
                    LET vIsCtePros = 'N';
                    LET vNumCte = '';
                    LET vNombre = '';
                    LET vRFC = '';
                    LET vFechaSol = date(1);
                    LET vFechaAut = date(1);
                    LET vLinCredAct  = 0;
                    LET vLinCredCal = 0;
                    LET vOrigen = '';
                    LET vStatus = '';
                    LET vDescStatus = '';
                    LET vComentario = '';
                    LET vNumSol = '';
				
				ELSE
					
					SELECT status_cred 
					INTO vestatus_cred
					FROM sd_maecred 
					WHERE empresa = pEmpresa
					AND num_credito = vNumSol;
					
					-- IFRS
					SELECt NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoVen FROM bdicred:sd_maesdos WHERE num_credito = vNumSol;

					IF (cMtoVen > 0) THEN 
				
						UPDATE bdicred:sd_bitacora_aumlincred SET status = 'RT', causa_status = 'REV', fecha_status = TODAY, hora_status = CURRENT
						WHERE empresa = pEmpresa AND num_solicitud = vNumSol AND status = vStatus AND fecha_insert between vFechaIni and vFechaFin;
						
						INSERT INTO sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
						VALUES (pEmpresa, vNumSol, 'RT', 'REV', 'INFORMIX', TODAY, vFechaInsert, 0);
						
						LET cod_ret = '453';
						LET vMen = 'No existe cliente con los parametros especificados';
						LET vIsCtePros = 'N';
						LET vNumCte = '';
						LET vNombre = '';
						LET vRFC = '';
						LET vFechaSol = date(1);
						LET vFechaAut = date(1);
						LET vLinCredAct  = 0;
						LET vLinCredCal = 0;
						LET vOrigen = '';
						LET vStatus = '';
						LET vDescStatus = '';
						LET vComentario = '';
						LET vNumSol = '';
						
					END IF;
				END IF;
                
                IF NVL(vOrigen,"") = "C" THEN
                    LET vFechaSol = "";
                END IF;


               RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
       ELSE
                LET cod_ret = '139';
                LET vMen = ' Esta consulta no esta disponible, por favor consulte por Cliente o por Tarjeta';
                LET vIsCtePros = 'N';
                LET vNumCte = '';
                LET vNombre = '';
                LET vRFC = '';
                LET vFechaSol = date(1);
                LET vFechaAut = date(1);
                LET vLinCredAct  = 0;
                LET vLinCredCal = 0;
                LET vOrigen = '';
                LET vStatus = '';
                LET vDescStatus = '';
                LET vComentario = '';
                LET vNumSol = '';
               
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
          
		/*FOREACH
                SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_sd_bitacora_aumlincred2), 
                        +INDEX(bdicred:sd_status_aumlincred idx_sd_status_aumlincred)} skip pRegistros limit 20
                        a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
                        a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, d.descripcion
                INTO vNumCte, vNombre, vRFC, vFechaAut, vLinCredAct, vLinCredCal, vOrigen, vStatus, vNumSol, vDescStatus
                FROM  bdicred:sd_bitacora_aumlincred b,
                      bdinteg:si_cliente a,
                      bdicred:sd_status_aumlincred d
                WHERE b.empresa  = pEmpresa
                  and a.numcte   = b.numcte
                  and b.fecha_insert between vFechaIni and vFechaFin
                  and b.status in ('AT', 'IN')
                  and b.empresa  = d.empresa 
                  and b.status   = d.status
                  and b.sucursal = pSucursal
                  order by nombre1, b.numcte

                IF NVL(vOrigen,"") = "C" THEN
                    LET vFechaSol = "";
                END IF;

--                LET siContReg = siContReg + 1;

--                IF siContReg <= pRegistros THEN
--                    CONTINUE FOREACH;
--                END IF;         

                RETURN cod_ret, vMen, vIsCtePros, vNumCte, vNombre, vRFC, vFechaSol, vFechaAut, vLinCredAct, vLinCredCal, vOrigen, vStatus, vDescStatus, vComentario, vNumSol WITH RESUME;
          END FOREACH;
*/
       END IF;
    ELSE
    
			SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)}
                     a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
				   a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, d.descripcion, b.fecha_insert
			INTO vNumCte, vNombre, vRFC, vFechaAut, vLinCredAct, vLinCredCal, vOrigen, vStatus, vNumSol, vDescStatus, vFechaInsert
			FROM  bdicred:sd_bitacora_aumlincred b
			INNER JOIN bdinteg:si_cliente a ON (a.empresa = b.empresa and a.numcte = b.numcte)
			INNER JOIN bdicred:sd_status_aumlincred d ON (d.empresa = b.empresa and d.status = b.status)
			WHERE b.empresa = pEmpresa
				and b.numcte = pNumCte
				and b.status = 'AT'
			    and b.fecha_insert between vFechaIni and vFechaFin;

			IF NVL(vOrigen,"") = "0" THEN
				LET vFechaSol = "";
			END IF;
			
            IF (vNumCte IS NULL OR vNumCte = '') THEN
            	LET cod_ret = '453';
                LET vMen = 'No existe cliente con los parametros especificados';
                LET vIsCtePros = 'N';
                LET vNumCte = '';
                LET vNombre = '';
                LET vRFC = '';
                LET vFechaSol = date(1);
                LET vFechaAut = date(1);
                LET vLinCredAct  = 0;
                LET vLinCredCal = 0;
                LET vOrigen = '';
                LET vStatus = '';
                LET vDescStatus = '';
                LET vComentario = '';
                LET vNumSol = '';
				
			ELSE
					
					SELECT status_cred 
					INTO vestatus_cred
					FROM sd_maecred 
					WHERE empresa = pEmpresa
					AND num_credito = vNumSol;
					
					-- IFRS
					SELECt NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoVen FROM bdicred:sd_maesdos WHERE num_credito = vNumSol;

					IF (cMtoVen > 0) THEN
						
						UPDATE bdicred:sd_bitacora_aumlincred SET status = 'RT', causa_status = 'REV', fecha_status = TODAY, hora_status = CURRENT
						WHERE empresa = pEmpresa AND num_solicitud = vNumSol AND status = vStatus AND fecha_insert between vFechaIni and vFechaFin;
						
						INSERT INTO sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
						VALUES (pEmpresa, vNumSol, 'RT', 'REV', 'INFORMIX', TODAY, vFechaInsert, 0);
						
						LET cod_ret = '453';
						LET vMen = 'No existe cliente con los parametros especificados';
						LET vIsCtePros = 'N';
						LET vNumCte = '';
						LET vNombre = '';
						LET vRFC = '';
						LET vFechaSol = date(1);
						LET vFechaAut = date(1);
						LET vLinCredAct  = 0;
						LET vLinCredCal = 0;
						LET vOrigen = '';
						LET vStatus = '';
						LET vDescStatus = '';
						LET vComentario = '';
						LET vNumSol = '';

					END IF;
			END IF;

            RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		

    END IF;
	
	IF siContReg = 0 THEN
		LET cod_ret = '453';
		LET vMen = 'No existe cliente con los parametros especificados';
		RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
	END IF;
	
END;

END PROCEDURE

DOCUMENT 
'Realiza la selecció® ¤e Clientes prospectos por diferentes filtros de bÃºsqueda',
'para ser mostrados en ventanilla (tipo de consulta 1) o por monitor (tipo de consulta 2)',
'AUTOR : Nubia Janeth Montoya Medina ',
'FECHA : 05/JULIO/2010',
'BD    : bdicred',
'Se modifica para que implemente otro tipo de consulta 0 para busqueda de incremento automaticos',
'para ser mostrados en el aplicativo de Cancelacion de incrementos de linea',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 15/MARZO/2011',
'BD    : bdicred',
'VERSION:20110315.1530';

CREATE PROCEDURE "informix".sp_consultarctes_aumlincred_auto_web( pEmpresa char(3),
																pNumCte char(20),
																pRFC char(13),
																pNumTarjeta char(20),
																pTipoConsulta char(2),
																pSucursal char(4),
																pRegistros integer,
                                                                pMonitor integer)
RETURNING 	char(5) as codigoRetorno,
			char(80) as mensaje,
			char(1) as vIsCtePros,
			char(20) as NumCte,
			char(120) as NomCte,
			char(13) as RFC,
			date as FechaSol,
			date as FechaAut,
			decimal(18,2) as LinCredAct,
			decimal(18,2) as LincredCal,
			char(1) as origen,
			char(2) as Status,
			char(40) as DescStatus,
			char(80) as Comentario,
			char(20) as NumSol,
			char(20) as NumTarjeta,
			char(1) as incrementoAutomatico	;

---DECLARACIONES
DEFINE cod_ret char(5);
DEFINE vRespCte char(2);
DEFINE vCont smallint;
DEFINE vIsCtePros char(1);
DEFINE sql_err integer;
DEFINE vMen char(80);
DEFINE vFechaIni date;
DEFINE vFechaFin date;
DEFINE vRFC char(13);
DEFINE vFechaSol date;
DEFINE vFechaAut date;
DEFINE vLinCredAct decimal(18,2);
DEFINE vLinCredCal decimal(18,2);
DEFINE vOrigen char(1);
DEFINE vStatus char(2);
DEFINE vComentario char(80);
DEFINE vNombre char(120);
DEFINE vNumCte char(20);
DEFINE iIsamErr smallint;
DEFINE cErrorInfo char(80);
DEFINE vDias smallint;
DEFINE vReg char(5);
DEFINE vNumSol char(20);
DEFINE vDescStatus char(40);
DEFINE siContReg SMALLINT;
DEFINE vestatus_cred char(2);
DEFINE vFechaInsert date;
DEFINE cNumTarjeta char(20);
DEFINE cIncreAuto char(1);
DEFINE iCont SMALLINT;
DEFINE cMtoVen DECIMAL(18,2);
---INICIALIZACIONES
LET cod_ret = '00000';
LET vRespCte = '';
LET vCont = 0;
LET vIsCtePros = 'N';
LET sql_err = 0;
LET vMen = 'El proceso se ejecuto correctamente';
LET vFechaIni = date(1);
LET vFechaFin = date(1);
LET vRFC = '';
LET vFechaSol = date(1);
LET vFechaAut = date(1);
LET vLinCredAct  = 0;
LET vLinCredCal = 0;
LET vOrigen = '';
LET vStatus = '';
LET vComentario = '';
LET vNombre = '';
LET vNumCte = '';
LET iIsamErr = 0;
LET cErrorInfo = '';
LET vDias = 0;
LET vReg = '';
LET vNumSol = '';
LET vDescStatus = '';
LET siContReg = 0;
LET vestatus_cred = '';
LET vFechaInsert = date(1);
LET cNumTarjeta = '';
LET cIncreAuto= '';
LET iCont = 0 ;
LET cMtoVen = 0;

BEGIN

	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
		LET cod_ret = sql_err;
	 	LET vMen= cErrorInfo;
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/sp_consultarctesincrementolincred.out";
--TRACE ON ;

	IF (((NVL(pEmpresa,"") = "") OR	(NVL(pTipoConsulta,"") = "")) OR ((NVL(pNumCte,"") = "")  AND (NVL(pSucursal,"") = "") AND  (NVL(pRFC,"") = "") AND (NVL(pNumTarjeta,"") = ""))) THEN
		LET cod_ret = '00452';
		LET vMen = 'Parametros insuficientes para llevar a cabo la consulta'; -- Faltan ingresar parametros
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
	END IF;
	
	IF (NVL(pRFC,"") <> "") THEN

		SELECT first 1 numcte 
		INTO pNumCte
		FROM bdinteg:si_cliente 
		WHERE rfc = pRFC; 
	
        IF (pNumCte IS NULL OR pNumCte = '') then
			LET cod_ret = '00450';
			LET vMen = 'El Cliente especificado no existe'; -- no existe Cliente
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
		
	END IF;

	IF (NVL(pNumCte,"") <> "")  THEN

		SELECT COUNT(1) 
		INTO vReg
		FROM bdinteg:si_cliente 
		WHERE numcte = pNumCte; 
		
		IF vReg = 0 THEN
			LET cod_ret = '00450';
			LET vMen = 'El Cliente especificado no existe'; -- no existe Cliente
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
		
	END IF;

    IF (NVL(pNumTarjeta,"") <> "") THEN
		IF (SELECT COUNT(num_tarjeta) FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa and num_tarjeta = pNumTarjeta) = 0 THEN
			LET cod_ret = '00451';
			LET vMen = 'El Numero de Tarjeta no existe'; -- no existe No. Tarjeta
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;

		SELECT first 1 numcte 
		  INTO pNumCte
          FROM bdicred:sd_tarjeta 
         WHERE empresa = pEmpresa
           and num_tarjeta = pNumTarjeta 
           and tipo_tarjeta = 'T';

        IF (pNumCte IS NULL OR pNumCte = '') then
			LET cod_ret = '00454';
			LET vMen = 'La tarjeta no es titular'; -- no existe No. Tarjeta
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
		END IF;
	END IF;

	
--se agrega validacion para consulta de cliente con incremento Automatico requerimiento 1229
	IF pMonitor = 0 THEN
			SELECT first 1 a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
				   a.rfc, NVL(b.ajuste_de_cuota,"N"),c.num_tarjeta,b.num_solicitud
			INTO vNumCte, vNombre, vRFC, cIncreAuto, cNumTarjeta,vNumSol
			FROM  bdinteg:"informix".si_cliente a 
			INNER JOIN bdisolic:"informix".ss_solicitudes b on b.empresa = a.empresa AND a.numcte = b.numcte
			INNER JOIN bdicred:"informix".sd_tarjeta c on c.empresa = a.empresa AND a.numcte = c.numcte AND c.tipo_tarjeta='T'
			WHERE a.empresa = pEmpresa
			  AND a.numcte = pNumCte
              AND b.status_solicitud = 'AP';   --FMV 2-JUN-11 Se adiciona estatus para q filtre exclusivamente la tarjeta aprobada
			
			LET iCont = dbinfo("sqlca.sqlerrd2");
			IF iCont = 0 THEN
				LET cod_ret = '00453';
				LET vMen = 'No existe cliente con los parametros especificados';	
			END IF;
					
		    RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
	END IF;	
	
	SELECT fecha_hoy INTO vFechaFin FROM bdicred:sd_fechas WHERE empresa = pEmpresa;

	SELECT TRIM(valor) INTO vDias FROM bdicred:sd_param WHERE empresa = pEmpresa and cod_param = '011';

	LET vFechaIni = vFechaFin - vDias UNITS DAY;
    IF pMonitor = 1 THEN
       IF (NVL(pNumTarjeta,"") <> "" or NVL(pRFC,"") <> "" or NVL(pNumCte,"") <> "") THEN
                SELECT first 1 a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
                       a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, d.descripcion, b.fecha_insert
                INTO vNumCte, vNombre, vRFC, vFechaAut, vLinCredAct, vLinCredCal, vOrigen, vStatus, vNumSol, vDescStatus, vFechaInsert
                FROM  bdicred:sd_bitacora_aumlincred b
                INNER JOIN bdinteg:si_cliente a ON (a.empresa = b.empresa and a.numcte = b.numcte)
                INNER JOIN bdicred:sd_status_aumlincred d ON (d.empresa = b.empresa and d.status = b.status )
                WHERE b.empresa = pEmpresa
                  and b.numcte = pNumCte
				  and b.status in ('AT', 'IN')
                  and b.fecha_insert between vFechaIni and vFechaFin;

                IF (vNumCte IS NULL OR vNumCte = '') THEN
                    LET cod_ret = '00453';
                    LET vMen = 'No existe cliente con los parametros especificados';
                    LET vIsCtePros = 'N';
                    LET vNumCte = '';
                    LET vNombre = '';
                    LET vRFC = '';
                    LET vFechaSol = date(1);
                    LET vFechaAut = date(1);
                    LET vLinCredAct  = 0;
                    LET vLinCredCal = 0;
                    LET vOrigen = '';
                    LET vStatus = '';
                    LET vDescStatus = '';
                    LET vComentario = '';
                    LET vNumSol = '';
				
				ELSE
					
					SELECT status_cred 
					INTO vestatus_cred
					FROM sd_maecred 
					WHERE empresa = pEmpresa
					AND num_credito = vNumSol;
					
					-- IFRS
					SELECt NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoVen FROM bdicred:sd_maesdos WHERE num_credito = vNumSol;

					IF (cMtoVen > 0) THEN 
				
						UPDATE bdicred:sd_bitacora_aumlincred SET status = 'RT', causa_status = 'REV', fecha_status = TODAY, hora_status = CURRENT
						WHERE empresa = pEmpresa AND num_solicitud = vNumSol AND status = vStatus AND fecha_insert between vFechaIni and vFechaFin;
						
						INSERT INTO sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
						VALUES (pEmpresa, vNumSol, 'RT', 'REV', 'INFORMIX', TODAY, vFechaInsert, 0);
						
						LET cod_ret = '00453';
						LET vMen = 'No existe cliente con los parametros especificados';
						LET vIsCtePros = 'N';
						LET vNumCte = '';
						LET vNombre = '';
						LET vRFC = '';
						LET vFechaSol = date(1);
						LET vFechaAut = date(1);
						LET vLinCredAct  = 0;
						LET vLinCredCal = 0;
						LET vOrigen = '';
						LET vStatus = '';
						LET vDescStatus = '';
						LET vComentario = '';
						LET vNumSol = '';
						
					END IF;
				END IF;
                
                IF NVL(vOrigen,"") = "C" THEN
                    LET vFechaSol = "";
                END IF;


               RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
       ELSE
                LET cod_ret = '00139';
                LET vMen = ' Esta consulta no esta disponible, por favor consulte por Cliente o por Tarjeta';
                LET vIsCtePros = 'N';
                LET vNumCte = '';
                LET vNombre = '';
                LET vRFC = '';
                LET vFechaSol = date(1);
                LET vFechaAut = date(1);
                LET vLinCredAct  = 0;
                LET vLinCredCal = 0;
                LET vOrigen = '';
                LET vStatus = '';
                LET vDescStatus = '';
                LET vComentario = '';
                LET vNumSol = '';
               
			RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
          
       END IF;
    ELSE
    
			SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)}
                     a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
				   a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, d.descripcion, b.fecha_insert
			INTO vNumCte, vNombre, vRFC, vFechaAut, vLinCredAct, vLinCredCal, vOrigen, vStatus, vNumSol, vDescStatus, vFechaInsert
			FROM  bdicred:sd_bitacora_aumlincred b
			INNER JOIN bdinteg:si_cliente a ON (a.empresa = b.empresa and a.numcte = b.numcte)
			INNER JOIN bdicred:sd_status_aumlincred d ON (d.empresa = b.empresa and d.status = b.status)
			WHERE b.empresa = pEmpresa
				and b.numcte = pNumCte
				and b.status = 'AT'
			    and b.fecha_insert between vFechaIni and vFechaFin;

			IF NVL(vOrigen,"") = "0" THEN
				LET vFechaSol = "";
			END IF;
			
            IF (vNumCte IS NULL OR vNumCte = '') THEN
            	LET cod_ret = '00453';
                LET vMen = 'No existe cliente con los parametros especificados';
                LET vIsCtePros = 'N';
                LET vNumCte = '';
                LET vNombre = '';
                LET vRFC = '';
                LET vFechaSol = date(1);
                LET vFechaAut = date(1);
                LET vLinCredAct  = 0;
                LET vLinCredCal = 0;
                LET vOrigen = '';
                LET vStatus = '';
                LET vDescStatus = '';
                LET vComentario = '';
                LET vNumSol = '';
				
			ELSE
					
					SELECT status_cred 
					INTO vestatus_cred
					FROM sd_maecred 
					WHERE empresa = pEmpresa
					AND num_credito = vNumSol;

					-- IFRS
					SELECt NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoVen FROM bdicred:sd_maesdos WHERE num_credito = vNumSol;

					IF (cMtoVen > 0) THEN
						
						UPDATE bdicred:sd_bitacora_aumlincred SET status = 'RT', causa_status = 'REV', fecha_status = TODAY, hora_status = CURRENT
						WHERE empresa = pEmpresa AND num_solicitud = vNumSol AND status = vStatus AND fecha_insert between vFechaIni and vFechaFin;
						
						INSERT INTO sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
						VALUES (pEmpresa, vNumSol, 'RT', 'REV', 'INFORMIX', TODAY, vFechaInsert, 0);
						
						LET cod_ret = '00453';
						LET vMen = 'No existe cliente con los parametros especificados';
						LET vIsCtePros = 'N';
						LET vNumCte = '';
						LET vNombre = '';
						LET vRFC = '';
						LET vFechaSol = date(1);
						LET vFechaAut = date(1);
						LET vLinCredAct  = 0;
						LET vLinCredCal = 0;
						LET vOrigen = '';
						LET vStatus = '';
						LET vDescStatus = '';
						LET vComentario = '';
						LET vNumSol = '';

					END IF;
			END IF;

            RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		

    END IF;
	
	IF siContReg = 0 THEN
		LET cod_ret = '00453';
		LET vMen = 'No existe cliente con los parametros especificados';
		RETURN cod_ret, vMen, NVL(vIsCtePros,""), NVL(vNumCte,""), NVL(vNombre,""), NVL(vRFC,""), NVL(vFechaSol,""), NVL(vFechaAut,""), NVL(vLinCredAct,0), NVL(vLinCredCal,0), 
			NVL(vOrigen,""), NVL(vStatus,""), NVL(vDescStatus,""), NVL(vComentario,""), NVL(vNumSol,""), NVL(cNumTarjeta,""),NVL(cIncreAuto,"");		
	END IF;
	
END;

END PROCEDURE

DOCUMENT 
'Realiza la seleccion de Clientes prospectos por diferentes filtros de busqueda',
'para ser mostrados en ventanilla (tipo de consulta 1) o por monitor (tipo de consulta 2)',
'AUTOR : Nubia Janeth Montoya Medina ',
'FECHA : 05/JULIO/2010',
'BD    : bdicred',
'Se modifica para que implemente otro tipo de consulta 0 para busqueda de incremento automaticos',
'para ser mostrados en el aplicativo de Cancelacion de incrementos de linea',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 15/MARZO/2011',
'BD    : bdicred',
'VERSION:20110315.1530';

CREATE PROCEDURE "informix".sp_identcte_ppv(p_empresa char(3))
    RETURNING   CHAR(5);
       
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE v_numcte         CHAR(20);
	DEFINE v_num_producto   CHAR(4);
	DEFINE v_c_vcomienza    SMALLINT;
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_c_vcontador    INTEGER;
	DEFINE v_val_tbl_cte    INTEGER;
   		
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vcodret             = "00000";
	LET v_numcte            = "";
	LET v_num_producto      = "";
	LET v_c_vcomienza       = -1;
	LET ven_transacc        = 0;
	LET v_c_vcontador       = 0;
	

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_identcte_ppv.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
	        IF ven_transacc = 1 THEN
               ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/sp_identcte_ppv.txt';
	--SET   DEBUG FILE TO '/informix/rsv/oxxo/sp_identcte_ppv.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

    SELECT COUNT(*) 
	INTO   v_val_tbl_cte
	FROM   sysmaster:systabnames 
    WHERE  partnum > 0 
	AND    tabname = 'sd_ppvigente';
	   
	--INICIALIZA LA TABLA 	   
	IF v_val_tbl_cte > 0 THEN 
	   TRUNCATE TABLE sd_ppvigente;
	END IF; 		
	
    FOREACH WITH HOLD
	        SELECT {+INDEX(sd_maecredcrd idx_sd_maecredcrd2)}
	               c.numcte,   c.num_producto  
			INTO   v_numcte, v_num_producto 
			FROM   bdicred:sd_maecredcrd c 
			JOIN   bdicred:sd_maesdoscrd d ON ( c.num_credito = d.num_credito)
			WHERE  c.num_producto IN('6300','7600','7700','7800','6400','6800')
			  AND  c.status_cred IN ('AA','E1')
			  AND  (d.monto_vencido + d.mto_venc_trasp) = 0
			
			-- Abre la transaccion 
		    IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
			
			INSERT INTO "informix".sd_ppvigente VALUES (v_numcte,v_num_producto);
						
			LET v_c_vcontador = v_c_vcontador + 1;
			--Realiza commit cada 5000 registros 
			IF (v_c_vcontador >= 5000) THEN
               LET v_c_vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF; 
			
    END FOREACH;
	
	--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;		
	
RETURN  vcodret;
END; 
END PROCEDURE;