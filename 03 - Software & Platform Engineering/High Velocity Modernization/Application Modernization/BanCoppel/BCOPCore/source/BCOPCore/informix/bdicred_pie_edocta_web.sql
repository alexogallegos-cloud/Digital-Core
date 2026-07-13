CREATE PROCEDURE "informix".pie_edocta_web(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaEmision DATE)
RETURNING CHAR(5), DATE , CHAR(20), CHAR(8), CHAR(8), CHAR(8), CHAR(20), CHAR(3), DECIMAL(14,2), DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);
DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);
DEFINE v_tasa_mensual 		CHAR(8);
DEFINE v_tasa_anual 		CHAR(8);
DEFINE v_cat 				CHAR(8);
DEFINE v_saldo_promedio 	CHAR(20);
DEFINE v_dias_periodo 		CHAR(3);
DEFINE v_tasa_mora 			DECIMAL(14,2);
DEFINE v_tasa_mensual_mora 	DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   =               0;
LET sCodRet   =         '00000';
                       
LET v_fecha_emision =        "";
LET v_num_credito =          "";
                       
LET v_tasa_mensual =         "";
LET v_tasa_anual =           "";
LET v_cat =                  "";
LET v_saldo_promedio =       "";
LET v_dias_periodo =         "";
LET v_tasa_mora =             0;
LET v_tasa_mensual_mora =     0;

--SET DEBUG FILE TO "/informix/pie_edocta.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, NVL(v_fecha_emision,'01/01/1990'), NVL(v_num_credito,''), NVL(v_tasa_mensual,''), NVL(v_tasa_anual,''),	NVL(v_cat,''), NVL(v_saldo_promedio,''), NVL(v_dias_periodo,''), NVL(v_tasa_mora,0), NVL(v_tasa_mensual_mora,0);
     END EXCEPTION ;

	 SET ISOLATION DIRTY READ;
	 SET LOCK MODE TO WAIT 3;
  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
   SELECT 	fecha_emision, num_credito, tasa_mensual,
			tasa_anual, cat, saldo_promedio,
			dias_periodo, tasa_mora, tasa_mensual_mora
   INTO 	v_fecha_emision, v_num_credito, v_tasa_mensual,
			v_tasa_anual, v_cat, v_saldo_promedio,
			v_dias_periodo, v_tasa_mora, v_tasa_mensual_mora
	 FROM sd_pie_edocta
	 WHERE fecha_emision = pFechaEmision 
	 AND num_credito = pNumCredito;

	IF v_num_credito IS NULL THEN
		LET sCodRet = "00185";
		RETURN sCodRet, NVL(v_fecha_emision,'01/01/1990'), NVL(v_num_credito,''), NVL(v_tasa_mensual,''), NVL(v_tasa_anual,''),	NVL(v_cat,''), NVL(v_saldo_promedio,''), NVL(v_dias_periodo,''), NVL(v_tasa_mora,0), NVL(v_tasa_mensual_mora,0);
	END IF

  RETURN sCodRet, NVL(v_fecha_emision,'01/01/1990'), NVL(v_num_credito,''), NVL(v_tasa_mensual,''), NVL(v_tasa_anual,''),	NVL(v_cat,''), NVL(v_saldo_promedio,''), NVL(v_dias_periodo,''), NVL(v_tasa_mora,0), NVL(v_tasa_mensual_mora,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_calcularvencidodiarioestadocuenta_web(pempresa CHAR(3), pfechainicial DATE, pfechafinal DATE, pnumcredito CHAR(12),pUsuario CHAR(8))
RETURNING CHAR (5), DATE, MONEY (16,2);


--VARIABLES
DEFINE vcodret             CHAR(5);
DEFINE v_dFecha            DATE;
DEFINE v_mCapitalVencido   MONEY (16,2);
DEFINE vsqlerr             INTEGER;
DEFINE v_mAbono            MONEY (16,2);
DEFINE v_mCargo            MONEY (16,2);
DEFINE v_cNumCredito       CHAR(12);
-- VARIABLE DE CONTROL PARA NUMERO DE REGISTROS
DEFINE v_conta             SMALLINT;

-- INICIALIZO LA VARIABLE DE CONTROL DE NUMERO DE REGISTROS
LET v_conta             = 0;

--SET DEBUG FILE TO '/informix/sp_CalcularVencidoDiarioEstadoCuenta.out';
--TRACE ON;

--VALIDA PARÃMETROS
IF  pEmpresa = '' OR  pEmpresa IS NULL OR pFechaInicial = '' OR pFechaInicial IS NULL OR pFechaFinal = '' OR pFechaFinal IS NULL OR pNumCredito = '' OR pNumCredito IS NULL THEN
      LET vcodret = '00001';   --ParÃ metros invÃ¡lidos
      RETURN vcodret, v_dFecha, v_mCapitalVencido;
END IF;

BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, v_dFecha, v_mCapitalVencido;

        END IF;
    END EXCEPTION;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    -- Inicializa Variables
    LET vcodret = '00000';
    LET v_mCapitalVencido = 0;
    lET v_mAbono = 0;
    lET v_cNumCredito = '';
    LET v_dFecha = pFechaInicial -1 UNITS DAY ;
    LET  v_mCargo = 0;
	
	
	DELETE FROM bdicred:tmpsd_movhiscredito WHERE usuario = pUsuario;		
		
		INSERT INTO tmpsd_movhiscredito (fecha_mov, monto, naturaleza, num_credito, usuario)
		SELECT a.fecha_mov, a.monto, b.naturaleza, a.num_credito, pUsuario
	    FROM sd_movhis a , sd_afectavencidosimulador b
	    WHERE a.empresa = pEmpresa
	    AND a.num_credito = pNumCredito
	    AND a.codigo_fun IN (SELECT b.codigo_fun FROM sd_afectavencidosimulador)
	    AND a.codigo_ref IN (SELECT b.codigo_ref FROM sd_afectavencidosimulador)
	    AND a.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
	    AND a.reversado <> 'S';

    FOREACH

        SELECT  num_credito
        INTO  v_cNumCredito
        FROM  bdicred@pld_tcp:sd_detalle_edocta
        WHERE num_credito = pNumCredito
        AND fecha_emision  =  pFechaFinal

        WHILE v_dFecha <= pFechaFinal

            IF  v_dFecha = pFechaInicial -1 UNITS DAY  THEN   --Para obtener el capital vencido del mes inmediato anterior

                    SELECT  NVL(capital_ven_tc,0)
                    INTO  v_mCapitalVencido
                    FROM  bdicred@pld_tcp:sd_encabezado2_edocta
                    WHERE num_credito = pNumCredito
                    AND fecha_emision  =  pFechaInicial - 1 UNITS DAY;

                    IF v_mCapitalVencido = "" OR v_mCapitalVencido IS NULL THEN
                        LET v_mCapitalVencido = 0.00;
                    END IF


            ELSE      --Para obtener el capital vencido de los dias del periodo

                SELECT NVL(SUM(abono), 0), NVL(SUM(cargo),0)
                INTO v_mAbono, v_mCargo
                FROM TABLE(MULTISET(
                    SELECT
                    CASE WHEN naturaleza = 'C' THEN monto END AS cargo,
                    CASE WHEN naturaleza = 'A' THEN monto END AS abono
                    FROM bdicred:tmpsd_movhiscredito
                    WHERE fecha_mov = v_dFecha
					AND usuario= pUsuario));

            END IF;

            LET v_mCapitalVencido = v_mCapitalVencido - v_mAbono  + v_mCargo ;
            RETURN NVL(vcodret,'00001'), NVL(v_dFecha,'01/01/1900'), NVL(v_mCapitalVencido,0.0)

            WITH RESUME;

            LET v_dFecha =  v_dFecha + 1 UNITS DAY;

        END WHILE;
		let v_conta = v_conta + 1;
    END FOREACH;
	
	IF v_conta = 0 THEN
		let vcodret = '00001';
		let v_dFecha = '01/01/1900';
		let v_mCapitalVencido = 0.0;
		RETURN vcodret, v_dFecha, v_mCapitalVencido;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce RamÃ­rez.',
'DESCRIPCION: Se encarga de obtener el capital vencido en un periodo determinado para un nÃºmero de crÃ©dito',
'EJECUTADO O LLAMADO POR:',
'simtdc.exe',
'FECHA : Septiembre de 2009',
'VERSION: 20090910',
'BD    : bdicred',
'FECHA MODIFICACIÃN: 25/03/2010',
'MODIFICACIÃN: Se modifica, para cuando el cliente no tenga registro en el mes inmediato anterior, el',
'              capital vencido tome valor de 0.00, y continue el proceso. Ya que anteriormente terminaba ',
'AUTOR MODIFICACIÃN: Cristian Valentina Aguilar',
'FECHA MODIFICACION: 12/04/2010',
'MODIFICACION: Se le comenta la variable inicializada  v_dFecha devido a que marcaba un error',
'AUTOR MODIFICACION: Jose Angel Rodriguez Rodriguez',
'FECHA MODIFICACION: 20/04/2010',
'MODIFICACION: Se le agrego parametro al sp y se comenta la variable donde preguntaba si existia la tabla temporal y se le quita donde crea esta misma,',
'              tambien se le agrega un delete para borrar los registros del cliente que esten en dada sucursal y se borran por medio',
'              de la consulta donde se le agrega el usuario de la sucurusal',
'AUTOR MODIFICACION: Jose Angel Rodriguez Rodriguez';

CREATE PROCEDURE "informix".sp_obtienecodtarjeta_web(pEmpresa CHAR(3),pnumbin CHAR(6),ptipotar CHAR(1))
RETURNING CHAR(5)         AS codigo_retorno,
		  CHAR(28)		  AS cproducto,
		  CHAR(3) 		  AS ccodTarjeta;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);
DEFINE cnomproducto	 CHAR(28);
DEFINE ccodproductotar	 CHAR(3);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '00000';
LET cnomproducto	  = '';
LET ccodproductotar  = '';


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
	RETURN cCodRet, NVL(cnomproducto,''), NVL(ccodproductotar,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/Malena/sp_obtienecodtarjeta.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SELECT limit 1 codproductotarjeta, descripcion
	INTO ccodproductotar,cnomproducto
	FROM intercard:tipotarjeta
	WHERE tipo=ptipotar 
	AND bin = pnumbin;

	IF NVL(ccodproductotar,'') = ''  THEN
	   LET cCodRet= '00001';
	   LET cnomproducto='No hay datos con la informaciÃ³n indicada';
	END IF;

	RETURN cCodRet, NVL(cnomproducto,''), NVL(ccodproductotar,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para consultar el codigo de producto de la tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 13/10/2016',
'BD    : BDICRED',
--------------REINGENIERIA-----------
'Descripcion: Se genera un clon del sp "sp_obtienecodtarjeta" para que este tenga un cod ret de 5 caracteres',
'AUTOR : Efrain MIranda Miranda',
'FECHA : 15/08/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtienecomisionrepo_web(pEmpresa CHAR(3), 
													pProducto CHAR(4),
													pMotivo CHAR(2))					
	--DATOS A REGRESAR
	RETURNING 
	CHAR (5) AS cCodRet,
	DECIMAL(18,2) AS dMontoRepo;
	
--============= DEFINIR VARIABLES =============	
	DEFINE isqlErr SMALLINT;
	DEFINE isamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(5);
	DEFINE dMontoRepo DECIMAL(18,2);
--============= INICIALIZAR VARIABLES ===========	
	LET isqlErr = 0;
	LET isamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '00000';
	LET dMontoRepo = 0.00;
--============= INICIALIZAR VARIABLES ===========
BEGIN
	ON EXCEPTION SET isqlErr, isamErr, cErrorInfo
		LET cCodRet = isqlErr;
		RETURN cCodRet,dMontoRepo;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	-- SET DEBUG FILE TO "/respaldosbd/Alexis/sp_obtienecomisionrepo.out";
	-- TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pProducto,'') = '' OR NVL(pMotivo,'') = '' THEN
		LET cCodRet = '00001';
	ELSE
		--Consultar el monto de reposiciÃ³n
		IF pMotivo = '01' Then				
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_rob AND a.empresa = b.empresa AND  num_producto = pProducto 
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '02' Then
			SELECT 	a.monto 
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_ext AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '03' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_danmal AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '04' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_acl AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '05' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_ven AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '06' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_pet AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		END IF;
	
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			-- No Hubo registros
			LET cCodRet = '00001';
		ELSE
			IF dMontoRepo = 0 THEN
				-- Monto 0
				LET cCodRet = '00002';
			END IF
		END IF;
	END IF;
	
	RETURN cCodRet,dMontoRepo;
END
END PROCEDURE

DOCUMENT
'Folio: 226 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de CrÃÂ©dito.',
'Autor: 97247642 - Alexis Ibarra',
'BD: bdicred',
'Solicita:	Abraham Narvaez',
'Fecha: 15/11/2017',
'Descripcion: Se crea un procedimiento almacenado que consulte el monto por reposiciÃ³n segÃºn la empresa, el producto y el motivo.';

CREATE PROCEDURE "informix".sp_genera_boleto(vnum_cliente CHAR(9),vnumcuentaq CHAR(20),vimp_importe decimal(14,2),vnum_folio CHAR(16),vnum_tienda char(5) )
       RETURNING char(6);

--declaracion de variables
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
--tabla
DEFINE vnum_estado					INTEGER; 
DEFINE vdes_ciudad					varchar(20);
DEFINE vcalle						varchar(20);
DEFINE vnumeroextcalle				varchar(5);
DEFINE vnombrezona					varchar(20);
DEFINE vcod_postal					varchar(5);
--DEFINE vnum_tienda					char(5); 
DEFINE vclv_area					varchar(1); 
DEFINE vnum_caja					integer; 
DEFINE vmetodocaptura				varchar(2);
DEFINE vclv_tipomovimiento			varchar(1);
DEFINE vnum_telefono				varchar(10);
DEFINE vnum_telefonocelular			varchar(10);
DEFINE vnom_nombre					varchar(50);
DEFINE	vnombre1				varchar(50);
	DEFINE vnombre2				varchar(50); 
	DEFINE vapell_paterno		varchar(50);
	DEFINE vapell_materno		varchar(50);
DEFINE vdes_domicilio				varchar(70); 
DEFINE vfec_fecha					DATETIME YEAR TO SECOND;
DEFINE vclv_origen					varchar(07);
DEFINE vnum_secuencia				integer; 
DEFINE vestado						varchar(25);
DEFINE vnum_folio2 varchar(16);
--

    --SET DEBUG FILE TO "/bitacoras/Janeth/sorteo_tarjeta/sp_genera_boleto.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	LET vnum_estado					=0; 
	LET vdes_ciudad					="";
	LET vcalle						="";
	LET vnumeroextcalle				="";
	LET vnombrezona					="";
	LET vcod_postal					="";
	--LET vnum_tienda					=""; 
	LET vclv_area					="B"; 
	LET vnum_caja					=1; 
	LET vclv_tipomovimiento			="";
		LET vmetodocaptura			="";
	LET vnum_telefono				="";
	LET vnum_telefonocelular		="";
	--nombre del cliente
	LET vnom_nombre					="";
	LET	vnombre1				="";
	LET vnombre2				=""; 
	LET vapell_paterno			="";
	LET vapell_materno			="";
	LET vdes_domicilio				=""; 
	LET vfec_fecha					= DATE(1);
	LET vclv_origen					="";
	LET vnum_secuencia				= 0;  
	LET vestado						="";
	LET vnum_folio2                 = "";
	--
	
	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
            
			/*select current
			into vfec_fecha
			from bdicred:sd_fechas
			where empresa = '001';*/
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION
				INTO vfec_fecha 
			FROM sysmaster:sysshmvals;
			
			/*select numcte,sucursal
				into vnum_cliente,vnum_tienda
				from bdicred:sd_maecred
				where empresa = '001'
				  and num_credito = vnumcuentaq;*/
							
			--obtener direccion
			SELECT calle.nombrecalle,dir.numeroextcalle,col.nombrezona Colonia,dir.cod_postal,
			(select nombre from bdinteg:si_estados where estado=dir.estado) ESTADO,
			(select nombreciudad from bdinteg:si_catciudades where numerociudad=dir.numerociudad) CIUDAD
			into vcalle,vnumeroextcalle,vnombrezona,vcod_postal,vestado,vdes_ciudad
				FROM bdinteg:si_direcciones_actual dir 
				left outer join bdinteg:si_catzonas col on (col.numerociudad=dir.numerociudad and col.numerocolonia=dir.numerocolonia)
				left outer join bdinteg:si_catcalles calle on (calle.numerocalle=dir.numerocalle)
				WHERE dir.tipo_dir='1'
				and numcte = vnum_cliente;
				
			let vcalle = nvl(vcalle,'');
			let vnumeroextcalle = nvl(vnumeroextcalle,'');
			let vnombrezona = nvl(vnombrezona,'');
			let vcod_postal = nvl(vcod_postal,'');
			
			let vdes_domicilio = trim(vcalle)||' '||trim(vnumeroextcalle)||' '||trim(vnombrezona)||' '||trim(vcod_postal);
			--let vdes_domicilio = trim(vdes_domicilio);
			let vestado = nvl(trim(vestado),'Desconocido');
			let vdes_ciudad	= nvl(trim(vdes_ciudad),'Desconocido');
			
					
			IF nvl(vdes_domicilio,'') = '' then
				
				let vdes_domicilio = 'Desconocido';
				
			end if;
				  
			--obtener telefonos
			SELECT nombre1,nombre2, apell_paterno, apell_materno,
					nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 1),0),
					  nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 2),0)
					  into vnombre1,vnombre2, vapell_paterno,vapell_materno,vnum_telefono,vnum_telefonocelular
				FROM bdinteg:"informix".si_cliente a
				WHERE numcte = vnum_cliente;
				
			let vnom_nombre = trim(vnombre1)||' '||trim(vnombre2)||' '||trim(vapell_paterno)||' '||trim(vapell_materno);
			---let vnom_nombre = trim(vnom_nombre);
			
			/*select count(*)
				into vnum_secuencia
				from sd_sorteotec_reporte
				where num_cliente = vnum_cliente;*/
			select MAX(num_secuencia)
				into vnum_secuencia
				from sd_sorteotec_reporte
				where num_cliente = vnum_cliente;				
				
			if nvl(vnum_secuencia,0) = 0 then
				let vnum_secuencia = 1;
				
			else 
				let vnum_secuencia = vnum_secuencia + 1;
			end if;
			LET vnum_folio2 =  substr(vnum_folio,2,15);
			--obtener tipo de movimiento Tarjeta presente y no presente
			select metodocaptura
				into vmetodocaptura
			from intercard:movimiento
			where secuenciaextendida = vnum_folio2;
			
			if vmetodocaptura in ('02','05','07','08','79','80','90') then
				let vclv_tipomovimiento = '1'; --'TSP';
			else
				let vclv_tipomovimiento = '0'; --'TNP';
			end if;
			
			let vnum_estado = 2;
			let vnum_caja = 1;
			LET vclv_origen = '0000000';
				
			--FOREACH WITH HOLD
				
				BEGIN WORK;
				--inserta los datos en la tabla
				insert into bdicred:sd_sorteotec_reporte (num_credito, num_estado, des_ciudad,  num_tienda, clv_area, num_caja, clv_tipomovimiento, num_folio,
												  num_cliente, imp_importe, num_telefono, num_telefonocelular, nom_nombre, des_domicilio, fec_fecha, clv_origen, num_secuencia, estado)
				values (vnumcuentaq, vnum_estado, vdes_ciudad,  vnum_tienda, vclv_area, vnum_caja, vclv_tipomovimiento, vnum_folio,
												  vnum_cliente, vimp_importe, vnum_telefono, vnum_telefonocelular, vnom_nombre, vdes_domicilio, vfec_fecha, vclv_origen, vnum_secuencia, vestado);
			   
			   
			 --END FOREACH;
				COMMIT WORK;  
				

     RETURN cCod_ret;
	END;
	
END PROCEDURE;