CREATE PROCEDURE "informix".sp_rep_ctescop_meshist_error (pEmpresa CHAR(3),pFecha DATE )
--Reporte Validacion Ctes Coppel Vs Edad del Cte clts_meseshist_error_
RETURNING CHAR(5), -- Codigo de Retorno
CHAR(80);   -- Mensaje de retorno;   

		  
	---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);
DEFINE iContador		INTEGER;
DEFINE iContador2		INTEGER;


DEFINE	cNumProd	CHAR(4);  
DEFINE	dtFechaSol	DATE;  
DEFINE	cNumCred	CHAR(20);  
DEFINE	cStatusSol	CHAR(2);
DEFINE	dEdadCte	DECIMAL(18,2);  
DEFINE	iMesesHist	SMALLINT;  
DEFINE	cEficiencia	DECIMAL(5,2);   
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(500);
DEFINE cRuta 			CHAR(80);

	--SET DEBUG FILE TO "/informix/jesus/rqm10465dos/sp_rep_ctescop_meshist_error.out";
	--TRACE ON;
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET iContador			=  0;
LET iContador2			=  0;

LET 	cNumProd	= '';
LET 	dtFechaSol	=DATE(1);  
LET 	cNumCred	= '';
LET 	cStatusSol	= '';
LET 	dEdadCte	= 0;
LET 	iMesesHist	= 0;
LET 	cEficiencia= 0;
LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet;
	
       END IF;
    END EXCEPTION;


			
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETROS DE ENTRADA INVALIDOS';
		RETURN cCodRet,cMensajeRet;	
	END IF;
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	-- OBTIENE LA FECHA DEL DIA
	

	
	
	
	--obtener fecha de fin de mes  del periodo solicitado
	LET dtFechaFinMes = mdy(month(pFecha),01,YEAR(pFecha)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(pFecha),01,YEAR(pFecha)), - 1);
	
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('clts_meseshist_error_')||TO_CHAR(pFecha,'%d%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('clts_meseshist_error_aux')||TO_CHAR(pFecha,'%d%m%y')|| '.txt';
	
	FOREACH WITH HOLD	
		SELECT  a.num_producto, a.fecha_insert,a.num_solicitud, a.status_solicitud,
		round(((a.fecha_insert-b.fecha_nac)/ 365),2),c.meses_historia,c.situacion_pago
		INTO cNumProd,dtFechaSol,cNumCred,cStatusSol,dEdadCte,iMesesHist,cEficiencia
		
		FROM "informix".ss_cambio_grupo d
		INNER JOIN "informix".ss_solicitudes a ON (d.num_solicitud = a.num_solicitud)
		INNER JOIN bdinteg:"informix".si_ctepf  b ON (a.numcte = b.numcte)
		INNER JOIN "informix".ss_resum_scor_fin c ON (a.num_solicitud = c.num_solicitud)
		WHERE d.fecha_insert between dTFechaSD	and  dtFechaFinMes
		AND secuencia = (select MAX(secuencia) from ss_cambio_grupo e where e.num_solicitud = a.num_solicitud)


		LET cConsulta = TRIM(NVL(cNumProd,''))||'|'|| TRIM(NVL(dtFechaSol,''))||'|'||cNumCred||'|'|| TRIM(NVL(cStatusSol,''))||'|'|| 	 NVL(dEdadCte,0)||'|'||  NVL(iMesesHist,0)||'|'||NVL(cEficiencia,0);
		
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;						
	
		LET iContador2	=  1; 
    END FOREACH;
     
   IF iContador2  > 0 THEN 	
    
	---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Producto'||'|'||'Fecha de solicitud'||'|'||'Número de solicitud'||'|'||'Estatus de la solicitud'||'|'||'Edad'||'|'||'Meses de Historia'||'|'||'Eficiencia de Pago'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;

	
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   	
	     
   RETURN cCodRet,cMensajeRet;
   
   ELSE
    LET cCodRet			= '00000';
	LET cMensajeRet			= 'No se encontro información';
	RETURN cCodRet,cMensajeRet;
   END IF;
   
END;
END PROCEDURE
