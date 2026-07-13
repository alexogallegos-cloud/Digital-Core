create procedure "informix".sp_dia_primero_ultimo_mes_anio (pMes char(2), pAnio char(4))

returning char(6) , date, date

Define sAuxFecha   Char(10);
Define sAuxMes     Char(2);
Define sAuxAnio    Char(4);
Define dDiaprimero date;
Define dDiaUltimo  date;
Define vcCodRet    char(6);
define vsqlerr     integer;

    Begin
        ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                LET  vcCodRet  = vsqlerr;
                RETURN vcCodRet, date(1), date(1);
            END IF;
        END  EXCEPTION
		
		--set debug file to "/tmp/sp_dia_primero_ultimo_mes_anio.out";
        --trace on;

        Let vcCodRet = '000000';
        Let sAuxFecha   = lpad(trim(pMes), 2, '0') || '-01-' || pAnio ;
        Let dDiaprimero = sAuxFecha::Date;

        If pMes = '12' then
            Let sAuxMes = '01';
            Let sAuxAnio = pAnio + 1 ;
        Else
            Let sAuxMes = pMes + 1;
            Let sAuxMes = lpad(trim(sAuxMes), 2, '0');
            Let sAuxAnio = pAnio;
        End If;

        Let sAuxFecha  = sAuxMes || '-01-' || sAuxAnio ;
        Let dDiaUltimo = sAuxFecha::date - 1;
    End;

    Return vcCodRet , dDiaprimero, dDiaUltimo;
End procedure
DOCUMENT
'DESCRIPCION: Sp para devolver el dÃ­primero y ultimo de un mes-aÃ±-Para compilarse en la base de datos integral',
'FECHA      : 20190611',
'BD         : BDICRED';

CREATE PROCEDURE "informix".sp_carga_repositorio() 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCod_Ret CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cDatosProsp CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE vnum_cred CHAR (20);
DEFINE vnum_cte CHAR (20);
DEFINE vnum_promo INTEGER;
DEFINE vtipo_tar CHAR (3);
DEFINE vnombre CHAR (106);
DEFINE vnombre_emb CHAR (21);
DEFINE vnum_prod CHAR (4);
DEFINE cmiembro CHAR (2);
DEFINE dtCampAct DATETIME YEAR TO SECOND;
DEFINE dtCampIni DATETIME YEAR TO SECOND;
DEFINE dtCampFin DATETIME YEAR TO SECOND;
DEFINE dFechaIniCred DATETIME YEAR TO SECOND;

DEFINE wBegin                CHAR(1);
DEFINE cArchivo_dbld      CHAR(50);
DEFINE cArchivo_log       CHAR(50);

LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCod_Ret = '000000';
LET cCadena = '';
LET cRuta = '';
LET cDatosProsp = '';
LET cBitCamp = '';
LET vnum_cred = '';
LET vnum_cte = '';
LET vnum_promo = 0;
LET vtipo_tar = '';
LET vnombre = '';
LET vnombre_emb = '';
LET vnum_prod = '';
LET cmiembro = '';
LET wBegin = '';
LET dtCampAct = CURRENT;
LET cArchivo_dbld    = "f_datosrepos.com";
LET cArchivo_log     = "f_datosrepos.log";


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

  --SET DEBUG FILE TO '/ifxsif01/bdicred/archivosriesgos/sp_carga_datos_camp.out';
  --TRACE ON;

    LET cDatosProsp="repositorio_alta_ctes";
    LET cBitCamp="bitrepositorio";
    LET cRuta="/resplogifx/archivosriesgos/";                                                    
    --LET cRuta="/informix/resplogifx/archivoscredito/";                                              
 
	
	IF NVL(cRuta,'') <> '' THEN
			IF NVL(cDatosProsp,'') <> '' THEN

				LET dtCampAct = CURRENT;
			    LET cDatosProsp = TRIM(cDatosProsp)||'.unl';                
                LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.txt'; 

				               
               system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosProsp) ||' DELIMITER '|| "'" || ';' || "'" || ' 25;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
               system ' echo "INSERT INTO sd_repositorio_alta_cte;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
               system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

               system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datosrepos.sh';
               system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_datosrepos.sh'; 
               system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datosrepos.sh';
               system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datosrepos.sh';             
               system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datosrepos.sh';          
               system ' echo "update statistics medium for table sd_repositorio_alta_cte; ' || '">>' || TRIM(cRuta)|| 'dbload_datosrepos.sh';           
               system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datosrepos.sh';           
               system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datosrepos.sh';
               system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datosrepos.sh';

				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002';
			END IF;
            
            IF cCodRet = '000000' THEN 
                LET cCadena = '';
				LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter ''|'' SELECT count(num_credito) FROM bdicred:"informix".sd_repositorio_alta_cte" >'||TRIM(cRuta)||'bit_repo.sql';
				SYSTEM cCadena;				
				LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_repo.sql';
				System cCadena;				
				let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_repo.sql';
				System cCadena;				
				LET cCadena = '' ;
				LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_repo.sql';
				SYSTEM cCadena;

            END IF; 
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 19/JUN/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_supervision_mc_totales
(pEmpresa      CHAR(3),
pNumSolicitud  VARCHAR(20,1),
pNumCte        VARCHAR(20,1),
pFechaIni      DATE,
pFechaFin      DATE,
pStatus        CHAR(2),
pProducto      CHAR(4))
RETURNING
	CHAR(6) 	    AS CodRet,
	INTEGER AS num_registros;	
	
---DECLARACIONES
DEFINE cCodRet        CHAR(6); 
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE iNumReg        INTEGER;

DEFINE cEmpresa             CHAR(3);
DEFINE cNumSolic            VARCHAR(20,1);
DEFINE cNumCte              VARCHAR(20,1);
DEFINE cNomCte              VARCHAR(130,1);
DEFINE dtFechaSolic         DATE;
DEFINE dtFechaCambioSolic   DATE;
DEFINE cStatusSolic         CHAR(2);
DEFINE cSityCausa           VARCHAR(8,1);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cCodRet             = "000000";
LET iNumReg             = 0;

LET cEmpresa            = '';
LET cNumSolic           = '';
LET cNumCte             = '';
LET cNomCte             = '';
LET dtFechaSolic        = DATE(1);
LET dtFechaCambioSolic  = DATE(1);
LET cStatusSolic        = '';
LET cSityCausa          = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet,iNumReg;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consulta_supervision_mc.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa     
  FROM bdinteg:si_empresas 
 WHERE empresa= pEmpresa;
  
IF cEmpresa IS NULL THEN
  LET cCodRet = '000001';
  RETURN cCodRet,iNumReg;
END IF;
/*
IF NVL(pNumSolicitud,'') = '' THEN
	LET pNumSolicitud = NULL;
END IF;    

IF NVL(pNumCte,'') = '' THEN
	LET pNumCte = NULL;
END IF;    

IF NVL(pFechaIni,'') = '' THEN
	LET pFechaIni = DATE(1);
END IF;

IF NVL(pFechaFin,'') = '' THEN
	LET pFechaFin = CURRENT;
END IF;

IF NVL(pStatus,'') = '' THEN
	LET pStatus = NULL;
END IF;

IF NVL(pProducto,'') = '' THEN
	LET pProducto = NULL;
END IF;*/

IF  pNumSolicitud  <> '' THEN --numero de solicitud

			SELECT 	COUNT(*)		 
			INTO  iNumReg
			FROM bdisolic:"informix".ss_solicitudes sol
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
																	  AND aut.empresa= sol.empresa 
																	  AND aut.status_solicitud= sol.status_solicitud
																	  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																							   FROM bdisolic:ss_autorizacion aut_aux
																							   WHERE aut_aux.empresa= sol.empresa 
																							   AND aut_aux.num_solicitud= sol.num_solicitud 
																							   AND aut_aux.status_solicitud= sol.status_solicitud))
			INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
			INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
			WHERE sol.empresa = pEmpresa
				AND sol.num_solicitud =  pNumSolicitud 
				AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso where numcte = cli.numcte);

			IF iNumReg = 0 THEN
				LET cCodRet = "000002";
			END IF;

			RETURN cCodRet,iNumReg;
	
	ELIF  pNumCte  <> '' THEN --numero de cliente
	
			SELECT 	COUNT(*)		 
			INTO  iNumReg
			FROM bdisolic:"informix".ss_solicitudes sol
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
																	  AND aut.empresa= sol.empresa 
																	  AND aut.status_solicitud= sol.status_solicitud
																	  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																							   FROM bdisolic:ss_autorizacion aut_aux
																							   WHERE aut_aux.empresa= sol.empresa 
																							   AND aut_aux.num_solicitud= sol.num_solicitud 
																							   AND aut_aux.status_solicitud= sol.status_solicitud))
			INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
			INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
			WHERE sol.empresa = pEmpresa 
				AND sol.numcte = pNumCte
				AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso where numcte = cli.numcte);

			IF iNumReg = 0 THEN
				LET cCodRet = "000002";
			END IF;

			RETURN cCodRet,iNumReg;
	
	ELSE --otros criterios
	
			SELECT 	COUNT(*)		 
			INTO  iNumReg
			FROM bdisolic:"informix".ss_solicitudes sol
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
																	  AND aut.empresa= sol.empresa 
																	  AND aut.status_solicitud= sol.status_solicitud
																	  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																							   FROM bdisolic:ss_autorizacion aut_aux
																							   WHERE aut_aux.empresa= sol.empresa 
																							   AND aut_aux.num_solicitud= sol.num_solicitud 
																							   AND aut_aux.status_solicitud= sol.status_solicitud))
			INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
			INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
			WHERE sol.empresa = pEmpresa
				AND sol.fecha_insert >= pFechaIni
				AND  sol.fecha_insert <= pFechaFin
				AND sol.status_solicitud = pStatus
				AND sol.num_producto = pProducto
				AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso where numcte = cli.numcte);

			IF iNumReg = 0 THEN
				LET cCodRet = "000002";
			END IF;

			RETURN cCodRet,iNumReg;
	
	END IF;
END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 05/05/2016',
'DESCRIPCION: Se realiza procedimiento para la obtencion del número total de registros del Monitor de Supervisión.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_new()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE vrowid       INTEGER;
DEFINE VlNumCredito	CHAR(20);
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_movhis_new_trace.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select trim(valor) into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT1';

	select date((pri_dia_mes - 2 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar;

	if iCont > 0 and cValor = '1' then

		update "informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT1';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos_depurar

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_movhis_new 
			WHERE empresa = '001' and  num_credito = VlNumCredito and fecha_mov <= dFecha;
			delete from "informix".temp_creditos_depurar where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update "informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT1';

	RETURN cCod_ret;

	END;

END PROCEDURE;