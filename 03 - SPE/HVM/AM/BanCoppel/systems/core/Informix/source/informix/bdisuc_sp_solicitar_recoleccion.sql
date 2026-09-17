CREATE PROCEDURE "informix".sp_solicitar_recoleccion
(
pempresa CHAR(3),
psucursal CHAR(4),
pcajeroprincipal CHAR(8),
cfolio_suc	CHAR(16)

)


RETURNING CHAR(5),CHAR(8),CHAR(25),CHAR(293);


--DECLARACION DE VARIABLES

DEFINE vcodret 					CHAR(5);
DEFINE vsqlerr,visamerr 		INTEGER;
DEFINE cId_banco				VARCHAR(5);
DEFINE cId_solicitud			VARCHAR(25);
DEFINE cId_solicitud2			VARCHAR(25);
DEFINE cSucursal_banco			VARCHAR(8);
DEFINE cSucursal_panamericano	VARCHAR(3);
DEFINE cId_servicio				VARCHAR(28);
DEFINE cMisc1					VARCHAR(40);
DEFINE cMisc2					VARCHAR(40);
DEFINE cMisc3					VARCHAR(40);
DEFINE cMisc4					VARCHAR(40);
DEFINE cMisc5					VARCHAR(40);
DEFINE cTrama					CHAR(288);
DEFINE cHoraActual				CHAR(5);
DEFINE cHoraAParam				CHAR(5);
DEFINE cFecha_hoy				DATE;
DEFINE cFecha_formato			CHAR(8);
DEFINE cFecha_formato_trama			CHAR(16);
DEFINE ctransaccion				CHAR(4);	
DEFINE cproveedor				CHAR(4);
DEFINE cfolio_oper				CHAR(8);
DEFINE csol_nopipes				VARCHAR(25);
DEFINE ctransaccion2			CHAR(4);
DEFINE cSucursal_panamericano2	VARCHAR(3);
DEFINE cfecha_cadena			CHAR(25);
DEFINE cnum						INTEGER;
DEFINE cmonto                   MONEY(14,2);
DEFINE cFecha_formato2			CHAR(19);
DEFINE ccentrocostos_sucursal	CHAR (4);

		

	


LET vcodret = "000";
LET cId_banco	= '67   ';			
LET cId_solicitud = '';	
LET cId_solicitud2 = '';
LET cSucursal_banco = '';			
LET cSucursal_panamericano = '';
LET cId_servicio = '0                           ';	
LET cMisc1 = '0                                       ';	
LET cMisc2 = '0                                       ';			
LET cMisc3 = '0                                       ';					
LET cMisc4 = '0                                       ';					
LET cMisc5 = '0                                       ';
LET ctrama = '';
LET cHoraActual = '';
LET cHoraAParam = '';
LET cFecha_hoy = '';
LET cFecha_formato = '';
LET Ctransaccion = '';
LET cproveedor = '';
LET cfolio_oper = '';
LET csol_nopipes = '';
LET ctransaccion2 = '';
LET cSucursal_panamericano2 = '';
LET cFecha_formato_trama	= '';
LET cfecha_cadena = '';
LET cnum = '0';
LET cmonto = '0';
LET cFecha_formato2 = '';
LET ccentrocostos_sucursal = '';



BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,cfolio_oper,cId_solicitud,cTrama;
   END IF;
END EXCEPTION;

--SET debug file to "/informix/calizarraga/sp_recoleccion.out";
--trace on;

 set isolation to dirty read; 
   SET LOCK MODE TO WAIT 3;

	--- Verifica recepcion correcta de datos
	IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or pcajeroprincipal = '0' or pcajeroprincipal = ''  THEN 
		LET vcodret = "110";
		LET cId_solicitud = '';
		LET cTrama = '';
		
	ELSE 
		SELECT p.cod_proveedor
		INTO cproveedor
		FROM bdisuc:ss_proveedores p, bdinteg:si_sucursales s
		WHERE p.plaza = s.plaza_cajagen
		AND s.empresa = pempresa
		AND s.sucursal = psucursal;
		
		
		SELECT codigo
		INTO ctransaccion
		FROM bdisuc:ss_param_cajagen
		WHERE empresa = '001'
		AND codigo = '0026';	
		
		SELECT today 
		INTO cFecha_hoy
		FROM bdinteg:si_fechas
		WHERE empresa = '001';
		
		LET cFecha_formato = LPAD(DAY(cFecha_hoy),2,0) || LPAD(MONTH(cFecha_hoy),2,0) || YEAR(cFecha_hoy);

		
		LET cId_solicitud2 = "CON|" || psucursal::int || '|' ||  cFecha_formato || '|001     ';
		LET cId_solicitud = "CON|" || psucursal || '|' ||  cFecha_formato || '|001     ';
		LET csol_nopipes = "CON" || psucursal::int  ||    cFecha_formato || '001';
		LET cSucursal_banco = psucursal::int || '    ';
		
		IF LENGTH ((psucursal::int)::varchar(4)) = 1 THEN
			LET cSucursal_banco = psucursal::int || '       ';
		ELIF LENGTH ((psucursal::int)::varchar(4)) = 2 THEN
			LET cSucursal_banco = psucursal::int || '      ';
		ELIF LENGTH ((psucursal::int)::varchar(4)) = 3 THEN
			LET cSucursal_banco = psucursal::int || '     ';
		ELIF LENGTH ((psucursal::int)::varchar(4)) = 4 THEN
			LET cSucursal_banco = psucursal::int || '    ';
		
		END IF;
		
		
		
		SELECT sucursal 
		INTO cSucursal_panamericano
		FROM bdisuc:ss_sucursales_panamericano
		WHERE centro_costos = cproveedor;
		
		
		
		SELECT CURRENT 
		INTO cfecha_cadena
		FROM bdinteg:si_fechas;
		
		LET cFecha_formato2 = SUBSTR(cfecha_cadena,9,2) ||'/'|| SUBSTR (cfecha_cadena,6,2) ||'/'|| SUBSTR(cfecha_cadena,1,4) || SUBSTR (cfecha_cadena,11,9);	
		
		

		
		
		SELECT op.cod_trans
		INTO ctransaccion2
		FROM ss_operaciones op, ss_mae_entradasalida es
		WHERE op.cod_trans = ctransaccion
		AND op.sucursal = psucursal
		AND op.sucursal = es.sucursal
		AND op.id_solicitud = es.id_solicitud
		AND es.status IN ('16')
		AND op.reversado = '0';		
		
		IF  DBINFO("sqlca.sqlerrd2")  > 0 THEN
			LET vcodret = '1050';			LET cId_solicitud = '';
			LET cTrama = '';
		
		
		ELSE
			
			SELECT (CURRENT HOUR TO MINUTE), NVL(valor,'')
			INTO cHoraActual, cHoraAParam
			FROM bdisuc:ss_param_cajagen
			WHERE codigo = '0048';
	  
			IF cHoraActual = "" OR cHoraActual IS NULL OR cHoraAParam = "" OR cHoraAParam IS NULL THEN
				LET vcodret = "00001";
				LET cId_solicitud = '';
				LET cTrama = '';
			ELSE
				IF CAST(SUBSTR(cHoraActual,1,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN
					LET vcodret = "1051";  --ESTA FUERA DE HORARIO
					LET cId_solicitud = '';
					LET cTrama = '';
				ELSE
					IF CAST(SUBSTR(cHoraActual,1,2)  AS INTEGER) = CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN	
						IF CAST(SUBSTR(cHoraActual,4,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,4,2) AS INTEGER) THEN
								LET vcodret = "1051";  --ESTA FUERA DE HORARIO
								LET cId_solicitud = '';
								LET cTrama = '';	
						END IF
					END IF
				END IF
			END IF;
		END IF;	
	END IF;   
	let cMisc1  =  cSucursal_banco  ;
	IF  vcodret = "000" THEN
		select valor into cnum
		from   ss_param_cajagen
		where  codigo = '0005';

		update ss_param_cajagen
		set    valor = valor + 1
		where  codigo = '0005';

		LET cfolio_oper = lpad(cnum,8,"0");


		--PROCESO EXITOSO
		INSERT INTO ss_operaciones
			(empresa,cod_trans,folio_oper,fecha_operacion,divisa,monto,sucursal,folio_sucursal,id_solicitud,reversado,usuario)         
				 
		VALUES
			(pempresa,ctransaccion,cfolio_oper,cFecha_hoy,'01','0',psucursal,cfolio_suc,cId_solicitud,'0',pcajeroprincipal);
			
			
			
		INSERT INTO ss_mae_entradasalida
			(empresa,cod_proveedor,folio_oper,id_solicitud,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
			status,monto)
		VALUES
			(pempresa,cproveedor,cfolio_oper,cId_solicitud,psucursal,cfolio_suc,cFecha_hoy,cHoraActual,pcajeroprincipal,'16','0');
			--let cFecha_formato = cFecha_formato || "     ";
			--LET cTrama = cId_banco || cId_solicitud || rpad(cFecha_formato2, 19, " ") || cSucursal_banco || cSucursal_panamericano || cId_servicio ||  rpad(cMisc1, 40, " ")|| cMisc2 || cMisc3 || cMisc4 || cMisc5;
			
			LET cTrama =  rpad(cFecha_formato2, 19, " ") || rpad(cId_banco, 5," ") || rpad(cId_servicio, 28," ") || rpad(cId_solicitud2, 25, " ") ||  rpad(cMisc1, 40, " ")|| rpad(cMisc2, 40, " ") || rpad(cMisc3, 40, " ") || rpad(cMisc4, 40, " ") || rpad(cMisc5, 40, " ")|| rpad(cSucursal_banco, 8, " ") || cSucursal_panamericano;
			
			
			 
	END IF
	LET cId_solicitud = "CON|" || psucursal  || '|' ||  cFecha_formato || '|001    ';
	RETURN vcodret,cfolio_oper,cId_solicitud,cTrama;
END;
END PROCEDURE;