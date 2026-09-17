CREATE PROCEDURE "informix".sp_repcrednorev (pEmpresa CHAR(3), pFecha DATE )

RETURNING CHAR(5);  -- Codigo de Retorno
		  
		  
	---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE	cNumCte	CHAR(20);  
DEFINE	cNombreCte	CHAR(150);
DEFINE	cNumCred	CHAR(20);  
DEFINE	cSitCont	INTEGER; 
DEFINE	tpCred	CHAR(1);	  
DEFINE	dSaldoTotal	DECIMAL(18,2);
DEFINE	cMoneda	CHAR(1);
DEFINE	dCapVig	DECIMAL(18,2);
DEFINE	dCapVig28	DECIMAL(18,2);
DEFINE	dCapVig29	DECIMAL(18,2);
DEFINE	dCapVig30	DECIMAL(18,2);
DEFINE	dCapVig31	DECIMAL(18,2);
DEFINE	dCapVenc	DECIMAL(18,2);
DEFINE	dCapVenc28	DECIMAL(18,2);
DEFINE	dCapVenc29	DECIMAL(18,2);
DEFINE	dCapVenc30	DECIMAL(18,2);
DEFINE	dCapVenc31	DECIMAL(18,2);
DEFINE	dIntVenc	DECIMAL(18,2);
DEFINE	dIntVenc28	DECIMAL(18,2);
DEFINE	dIntVenc29	DECIMAL(18,2);
DEFINE	dIntVenc30	DECIMAL(18,2);
DEFINE	dIntVenc31	DECIMAL(18,2);
DEFINE	dIntMor	DECIMAL(18,2);
DEFINE	dIntMor28	DECIMAL(18,2);
DEFINE	dIntMor29	DECIMAL(18,2);
DEFINE	dIntMor30	DECIMAL(18,2);
DEFINE	dIntMor31	DECIMAL(18,2);
DEFINE	dComPend	DECIMAL(18,2);
DEFINE	dSeguros	DECIMAL(18,2);
DEFINE	dOtrosAdeudos	DECIMAL(18,2);
DEFINE	iFlagCob	INTEGER;
DEFINE	iDiasAtraso		INTEGER;
DEFINE	iTipoTasa	  INTEGER;
DEFINE	iTipoGar	  INTEGER;
DEFINE	iRestriccion	  INTEGER;
DEFINE	dtFechaApertura	  DATE;
DEFINE	dtFechaVenci	  DATE;
DEFINE	dMontoExigible	  DECIMAL(18,2);
DEFINE	dPagoReal	  DECIMAL(18,2);
DEFINE	cProducto	 CHAR(4);

DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;	
  
DEFINE	iContador	INTEGER;	

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(500);
DEFINE cRuta 			CHAR(80);
define dtFechaHoy DATE;

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';

LET	cNumCte	= '';
LET	cNombreCte	= '';
LET	cNumCred	= '';
LET	cSitCont	= 0;
LET	tpCred	= '50';  
LET	cMoneda	= '';  
LET	dSaldoTotal	= 0;

LET	dCapVig	= 0;
LET	dCapVig28	= 0;
LET	dCapVig29	= 0;
LET	dCapVig30	= 0;
LET	dCapVig31	= 0;
LET	dCapVenc	= 0;
LET	dCapVenc28	= 0;
LET	dCapVenc29	= 0;
LET	dCapVenc30	= 0;
LET	dCapVenc31	= 0;
LET	dIntVenc	= 0;
LET	dIntVenc28	= 0;
LET	dIntVenc29	= 0;
LET	dIntVenc30	= 0;
LET	dIntVenc31	= 0;
LET	dIntMor	= 0;
LET	dIntMor28	= 0;
LET	dIntMor29	= 0;
LET	dIntMor30	= 0;
LET	dIntMor31	= 0;
LET	dComPend	= 0;
LET	dSeguros	= 0;
LET	dOtrosAdeudos	= 0;
LET	iFlagCob	= 0;
LET	iDiasAtraso	= 0;
LET	iTipoTasa	= 1;
LET	iTipoGar	= 10;
LET	iRestriccion	= 0;
LET	dtFechaApertura	= DATE(1);
LET	dtFechaVenci	= DATE(1);
LET	dMontoExigible	= 0;
LET	dPagoReal	= 0;
LET	cProducto	= "";

LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET  iContador  = 0;

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET dtFechaHoy		    = DATE(1);
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;          
          RETURN cCodRet;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jesus/correo/sp_repcrednorev.out";
	--TRACE ON;	
	
		
	IF NVL(pEmpresa,'') = ''  OR pFecha  = '' THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETROS DE ENTRADA INVALIDOS';
		RETURN cCodRet;
	END IF;
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet;
	END IF;	 
	
	-- OBTIENE LA FECHA DEL DIA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = '001';
	
	--obtener fecha de fin de mes  del periodo solicitado
	
	LET dTFechaSD = MONTHADD(mdy(month(pFecha),01,YEAR(pFecha)), - 1);
	LET dtFechaFinMes = mdy(month(pFecha),01,YEAR(pFecha)) - 1 units day;
			--GENERA EL NOMBRE DEL ARCHIVO
		LET cNombreArchivo = TRIM('Infpattitcrdnorev')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
		LET cNombreArchivo1 = TRIM('Infpattitcrdnorev_aux')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
		
	FOREACH WITH HOLD		
		SELECT a.numcte,TRIM(NVL(cte.nombre1,' ')) || ' ' || TRIM(NVL(cte.nombre2,' ')) || ' ' || TRIM(NVL(cte.apell_paterno,' ')) || ' ' || TRIM(NVL(cte.apell_materno,' ')),
			TODAY,a.num_credito, DECODE(a.status_cred,"AA",1,2), "50", a.divisa,
			c.saldo_cierre,b.sdo_cap_insoluto,b.monto_vencido,(b.int_tra_no_exig+b.sdo_no_exig),(b.sdo_moratorio+b.sdo_contab_mora),
			(SELECT NVL(SUM(NVL(dc.monto_com,0) - NVL(dc.monto_pag,0)),0)
			 FROM "informix".sd_detcomi dc , "informix".sd_tpcomis tc
			WHERE dc.empresa     = a.empresa
			AND dc.num_credito = a.num_credito AND dc.estado_com  = 'A'	
			AND dc.empresa     = tc.empresa
			AND dc.cod_comis   = tc.cod_comis
			AND tc.comi_o_seg ='1'	
			AND dc.fecha_alta <= dtFechaFinMes), 0,0,
			 (SELECT  dtFechaFinMes -  NVL(MIN(fecha_cuota),dtFechaFinMes) 		   
				   FROM "informix".sd_amortiza_creditocrd    
				   WHERE  empresa =a.empresa
				   AND num_credito = a.num_credito
				   AND capital_status IN ('2','7')), 
		catprod.tipo_cobra, catprod.tipo_tasa,catprod.tipo_gar,catprod.restriccion,
		a.fecha_apertura,a.fecha_vencim, b.monto_financiado,c.pagos_realizados	
		INTO cNumCte, cNombreCte,pFecha,cNumCred,  cSitCont,  tpCred,cMoneda, dSaldoTotal, dCapVig, dCapVenc, dIntVenc, dIntMor, dComPend, dSeguros, dOtrosAdeudos,	iDiasAtraso, iFlagCob, iTipoTasa, iTipoGar, iRestriccion, dtFechaApertura,dtFechaVenci,dMontoExigible, dPagoReal
		FROM "informix".sd_maecredcontcrd a
		LEFT JOIN "informix".sd_hist_reserva_crd c ON( c.empresa = a.empresa	AND c.num_credito = a.num_credito		AND c.fecha_cierre = mdy(6,30,2015)),
		 sd_maesdoscontcrd b , 	bdinteg:"informix".si_cliente  cte, "informix".sd_catalogo_prod  catprod
			WHERE a.fecha = dtFechaFinMes
			AND a.empresa = b.empresa
			AND b.num_credito = a.num_credito		 	
			AND a.status_cred IN ("AA","BA","BT")
			AND b.fecha = dtFechaFinMes			
			AND cte.empresa = a.empresa
			AND cte.numcte = a.numcte
			AND catprod.empresa =a.empresa 
			AND catprod.num_producto = a.num_producto	
			
		
		
			LET cConsulta = TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cNombreCte,''))||'|'||pFecha||'|'|| TRIM(NVL(cNumCred,''))||'|'||  TRIM(NVL(cSitCont,''))||'|'||  TRIM(NVL(tpCred,''))||'|'||
			NVL(cMoneda,'')||'|'|| NVL(dSaldoTotal,0)||'|'|| NVL(dCapVig,0)||'|'|| NVL(dCapVenc,0)||'|'|| NVL(dIntVenc,0)||'|'|| NVL(dIntMor,0)||'|'|| NVL(dComPend,0)||'|'|| NVL(dSeguros,0)||'|'|| NVL(dOtrosAdeudos,0)||'|'||
			NVL(iDiasAtraso,0)||'|'|| NVL(iFlagCob,0)||'|'|| NVL(iTipoTasa,0)||'|'|| NVL(iTipoGar,0)||'|'|| NVL(iRestriccion,0)||'|'|| NVL(dtFechaApertura,DATE(1))||'|'|| NVL(dtFechaVenci,DATE(1))||'|'|| NVL(dMontoExigible,0)||'|'|| NVL(dPagoReal,0);
		
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;
		
		
	   LET  iContador  = 1;
    END FOREACH;
   
   
   
   --SET DEBUG FILE TO "/informix/jesus/correo/sp_repcrednorev.out";
	--TRACE ON;
   IF iContador > 0 THEN 	

	
	---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Identificar del cliente'||'|'||'Nombre del acreditado'||'|'||'Periodo'||'|'||'Identificador de Crédito'||'|'||'Situación Contable'||'|'||'Tipo de Crédito'||'|'||'Moneda'||'|'||'Saldo Total'||'|'||'Capital Vigente'||'|'||'Capital Vencido'||'|'||'Interes Ordinario'||'|'||'Interes Moratorio'||'|'||'Comisiones'||'|'||'Seguros'||'|'||'Otros Adeudos'||'|'||'Dias de Atraso'||'|'||'Cobranza'||'|'||'Tipo de tasa'||'|'||'Tasa  de Garantia'||'|'||'Restricciones'||'|'||'Fecha de Inicio'||'|'||'Fecha de Vencimiento'||'|'||'Monto Exigible'||'|'||'Pago Realizado'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;
		
		--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
				
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   
   
   
	RETURN cCodRet;
   
   ELSE
    LET cCodRet			= '00003';
	LET cMensajeRet			= 'No se encontro información';
	RETURN cCodRet;
   END IF;
   
END;
END PROCEDURE
DOCUMENT    
'DESCRIPCION: Procedimiento para  la créditos vencidos de los titulares, RQM 06 419', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 01 Junio 2015',
'VERSION: 20150601.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_obtienecred_proyecciones(pProducto CHAR(4))
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(4)  AS NumeroProd,
			CHAR(40) AS DescripcionProd,
			DECIMAL(18,2) AS MontoMin,
			DECIMAL(18,2) AS MontoMax,
			INTEGER AS PlazoMin,
			INTEGER AS PlazoMax,
			DECIMAL(18,2) AS Tasa,
			CHAR(6) AS Comision;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5);
DEFINE iSqlErr      	INTEGER;
DEFINE cNumProducto		CHAR(7);
DEFINE cDescProducto	CHAR(40);
DEFINE dMontoMin	DECIMAL(18,2);
DEFINE dMontoMax	DECIMAL(18,2);
DEFINE dTasa		DECIMAL(18,2);
DEFINE iPlazoMin	INTEGER;
DEFINE iPlazoMax	INTEGER;
DEFINE dComision		DECIMAL(5,2);
DEFINE cCodComDispEfectivo	CHAR(4);
---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cNumProducto			= '';
LET cDescProducto			= '';
LET dMontoMin	= 0;
LET dTasa	= 0;
LET dMontoMax	= 0;
LET iPlazoMin	= 0;
LET iPlazoMax	= 0;
LET dComision	= 0;
LET cCodComDispEfectivo	='';



BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/sp_obtienetpoproducto.out';
--TRACE ON;

	FOREACH


	SELECT a.abrevia_prod, a.descrip_prod,b.monto_min_cred,b.monto_max_cred,b.plazo_min_cred,b.plazo_max_cred,c.valor
		INTO cNumProducto, cDescProducto, dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa
		FROM bdicred:"informix".sd_tipprod a , bdicred:"informix".sd_definicion b,
			 bdinteg:"informix".si_fechavalor c
		WHERE a.cod_prod IN('P','R')
		AND a.abrevia_prod= b.num_producto
		AND b.num_producto = CASE WHEN  NVL(pProducto,'') = '' THEN b.num_producto ELSE pProducto END
		AND c.tasa = b.cod_tasa_base
		AND c.fecha = (SELECT MAX(r.fecha)
					FROM bdinteg:"informix".si_fechavalor r
					WHERE r.tasa = b.cod_tasa_base
					AND r.fecha = r.fecha
					AND r.empresa = b.empresa)
		AND c.empresa = b.empresa
		--RQM 10 550 AAME 20150911 Se modifica para quitar la omisión de los productos de prestamo (7600,7700)
		--AND num_producto NOT IN ('7600','7700')
		--AND num_producto <> '6900'  --RQM 10 452 09-09-2013 AAME Se comenta la validación de diferente del producto "6900" para lo despliegue en el listado.
		ORDER BY abrevia_prod

		IF 	cNumProducto = "6400" THEN
			SELECT valor INTO dComision
			FROM   "informix".sd_param
			WHERE  cod_param = '040';
		END IF;
		--RQM 10 452 09-09-2013 AAME Se agrega validación para que cuando sea el producto "6900" tome el plazo minimo y maximo de la tabla sd_tasa_plazo.
		IF cNumProducto = "6900" THEN
			SELECT Min(plazo),Max(plazo)
			INTO iPlazoMin,iPlazoMax
			FROM bdicred:"informix".sd_tasa_plazo;
			
			LET dMontoMin=1000;
			
			--INC 09-02-2015 SE AGREGA FACTOR PARA OBTENER LA COMISION CORRECTA PARA CREDISOLUCION
			SELECT TRIM(valor)::CHAR(4)
			INTO cCodComDispEfectivo
			FROM bdicred:"informix".sd_param
			WHERE cod_param  = '334';
			-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
				SELECT apli_factor
				INTO dComision
				FROM bdicred:"informix".sd_tpcomis
				WHERE cod_comis = cCodComDispEfectivo;
			
		END IF;

		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision WITH RESUME;

	END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision;
    END IF;

END
END PROCEDURE

DOCUMENT
'DESCRIPCION: Obtiene los productos de crédito que se usan para proyecciones ',
'AUTOR : Jesus Manuel Aguilar Heredia ',
'FECHA : 29/Enero/2013',
'BD    : BDICRED',
'Version: 20130129.1614';

CREATE PROCEDURE "informix".corta_linea(plinea char(1000), pcaracteres integer)
RETURNING 	NVARCHAR(255),INTEGER;


DEFINE v_caracter 	CHAR(1);
DEFINE v_pos_actual INTEGER;
DEFINE v_pos$ INTEGER;
DEFINE v_pos_blanco INTEGER;
DEFINE iBandera$ INTEGER;
DEFINE iBanderaEsp INTEGER;
DEFINE v_renglon	VARCHAR(255);
DEFINE v_palabra	VARCHAR(255);
DEFINE v_palabra2	VARCHAR(255);
LET v_caracter 		= "";
LET v_pos_actual 	= 1;
LET v_pos$ 	= 0;
LET v_pos_blanco 	= 1;
LET v_renglon		= "";
LET v_palabra	= "";
LET v_palabra2	= "";LET iBandera$	= 0;
LET iBanderaEsp	= 0;

--SET DEBUG FILE TO "/informix/jesus/corta_linea.out";
--TRACE ON;

---set pdqpriority 11;
 
BEGIN

	
	LET plinea = TRIM(plinea); 
	
	IF LENGTH(NVL(plinea,'')) = 0 THEN
		RETURN v_renglon,0 ;
	END IF
	IF SUBSTR(plinea,1,26) ='CARGO POR CREDISOLUCIONES' THEN 
		LET iBandera$ = 1;
	END IF;
	
	IF SUBSTR(plinea,len(plinea)-29,19) ='Folio de aclaración' THEN 	--RQI 22 268 JMAH	
		LET v_palabra2 = SUBSTR(plinea,len(plinea)-29,LEN(plinea));	
		LET plinea =SUBSTR(plinea,1,len(plinea)-30);
	END IF
	WHILE  v_pos_actual <= LENGTH(plinea)  
		
		
		----------OBTENGO EL CARACTER ACTUAL
		LET v_caracter = SUBSTR(plinea,v_pos_actual,1);
		
		IF v_caracter ='$' AND iBandera$ = 1 THEN
			LET  v_pos$ = v_pos$+1;
		END IF;
		IF v_caracter ='/ ' AND iBandera$ = 1 THEN
			LET  v_pos$ = v_pos$+1;
		END IF;

		IF (((v_caracter = "I" and  v_pos$ > 0 ) OR (iBanderaEsp =9) ) AND iBandera$ = 1)  THEN
			RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
			LET v_renglon		= "";
			LET v_palabra	= "";
			LET iBanderaEsp =0;
		END IF;
		
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
				LET iBanderaEsp = iBanderaEsp+1;
			END IF
			LET v_palabra = "";
		END IF;
		
		LET v_pos_actual = v_pos_actual + 1;

	END WHILE
	
	IF NVL(v_palabra2,'') <> '' THEN --RQI 22 268 JMAH
		 RETURN v_palabra2,LENGTH(v_palabra2) WITH RESUME; 
	END IF;
	
END
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".calc_iva_grav_pp(p_cEmpresa CHAR(3), p_cNumCredito CHAR(20), p_dTasaInt DECIMAL(9,6),
                                             p_dIvaSuc DECIMAL(5,3), p_dtFechaHoy DATE,p_dtIvaFechaPag DATE,
                                             p_dtFechaApert DATE,p_dtFechaCuota DATE,p_dIntNorm DECIMAL(18,2))

RETURNING
   CHAR(6)        AS Cod_Ret,
   DECIMAL(18,2)  AS IvaIntReal,
   CHAR(80)       AS Mens_Ret;

    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensajeRet      CHAR(125);
    DEFINE l_diascalc       INTEGER;
    DEFINE l_dtFechaComp    DATE;
    DEFINE l_iDias          INTEGER;
    DEFINE l_dFactor1       DECIMAL(14,9);
    DEFINE l_dFactor2       DECIMAL(14,9);
    DEFINE l_dTasaReal      DECIMAL(14,9);
    DEFINE l_dFactorIntReal DECIMAL(14,9);
    DEFINE l_dIvaIntReal    DECIMAL(18,2);

    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = "";
    LET cCodRet               = "000000";
    LET cMensajeRet           = "Proceso Exitoso";

    LET l_diascalc            = 0;
    LET l_dtFechaComp         = DATE(1);
    LET l_iDias               = 0;
    LET l_dFactor1            = 0;
    LET l_dFactor2            = 0;
    LET l_dTasaReal           = 0;
    LET l_dFactorIntReal      = 0;
    LET l_dIvaIntReal         = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,l_dIvaIntReal,cMensajeRet;
       END IF;
    END EXCEPTION;

   -- SET DEBUG FILE TO "/pisa/cas/calc_iva_grav_pp.out";
   -- TRACE ON;

--    SET LOCK MODE TO WAIT 3;

    select valor
    into l_diascalc
    from bdicred:sd_param
    where cod_param='24'
    and empresa= p_cEmpresa;

    IF p_dtIvaFechaPag IS NULL THEN
        CALL bdicred:monthadd(p_dtFechaCuota,-1) RETURNING l_dtFechaComp;

          SELECT fecha_cuota
            INTO l_dtFechaComp
            FROM "informix".sd_amortiza_creditocrd
           WHERE empresa     = p_cEmpresa
             AND num_credito = p_cNumCredito
             AND fecha_cuota = l_dtFechaComp;

             IF l_dtFechaComp IS NULL THEN
                 LET l_dtFechaComp = p_dtFechaApert;
             END IF;
    ELSE
          LET l_dtFechaComp = p_dtIvaFechaPag;
    END IF;

    LET l_iDias    = p_dtFechaHoy - l_dtFechaComp;

    IF l_iDias > 0 THEN
        LET l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias;
        IF NVL(l_dFactor1,0) < 0 THEN
             LET cCodRet      = "000001";
             LET cMensajeRet  = "No es posible realizar los calculos con el valor obtenido para el factor 1";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        CALL bdicred:determina_udi_rango(p_cEmpresa,date(l_dtFechaComp-1),date(p_dtFechaHoy-1)) RETURNING cCodRet,l_dFactor2;

        IF NVL(l_dFactor2,0) < 0 THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "No es posible realizar los calculos con el valor obtenido para el factor 2";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        LET l_dTasaReal       = l_dFactor1 - l_dFactor2;
        IF l_dTasaReal< 0 THEN LET l_dTasaReal=0; END IF;
        IF l_dTasaReal = 0 THEN
		 LET l_dFactorIntReal = 0;
		ELSE
			LET l_dFactorIntReal  = (l_dTasaReal * p_dIvaSuc)/l_dFactor1;
		END IF;
--        LET p_dIntNorm        = g_dSdoInt;
        LET l_dIvaIntReal     = round(l_dFactorIntReal * p_dIntNorm,2);
    END IF;

    IF cCodRet <> "000000" THEN
      LET cCodRet = "000000";
    END IF;

        RETURN cCodRet,l_dIvaIntReal,cMensajeRet;

    END
END PROCEDURE;