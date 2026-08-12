CREATE PROCEDURE "informix".sp_reportenegocio()

RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;

    DEFINE  CODIGO_RETORNO					CHAR(5);
	DEFINE  MENSAJE_RETORNO					CHAR(50);
	DEFINE	vaniomes						char(8);
	DEFINE	CONTADOR_TRANSACCIONES_DBLOAD 	SMALLINT;
	DEFINE	CONTADOR_TRANSACCIONES			SMALLINT;
	DEFINE	TIPO_PLANTILLA					varchar(20);
    DEFINE 	TIPO_PLANTILLA2					varchar(30);
    DEFINE	RUTA_DESTINO					varchar(80);
	DEFINE	vcodgironeg2					varchar(4);
    DEFINE	vdescgironeg2					varchar(80);
    DEFINE	vdescripcion2					varchar(30);
    DEFINE	vtransacciones2					integer;
	DEFINE	vidreceptor						VARCHAR(4);
	DEFINE	vinfreceptor					VARCHAR(40);
    DEFINE	vmonto2							decimal(19,4);
    DEFINE	vpromedio2						decimal(19,4);
    DEFINE	vproducto2						varchar(3);
    DEFINE	vperiodo2						char(6);
    DEFINE	vidreceptor2					varchar(4);
    DEFINE	vinfreceptor2					varchar(40);
    DEFINE	vmetodocaptura2					varchar(2);
    DEFINE	vesnacional2					varchar(1);
    DEFINE	vproductotarjeta				varchar(3);
    DEFINE	vproductotarjeta2				varchar(3);
    DEFINE	v_ranking1						integer;
	DEFINE	v_ranking						integer;
    DEFINE	vExecuteSQL						LVARCHAR(9000);
    DEFINE	NOMBRE_ARCHIVO					VARCHAR(100);
    DEFINE	SCRIPT_EJECUCION				VARCHAR(100);
    DEFINE	iCont							INTEGER;
	DEFINE	SQLERR							INTEGER;
	DEFINE	ISAM_ERR						INTEGER;
	DEFINE	ERROR_INFO						VARCHAR(80);
	DEFINE	vfecha_inicio					DATETIME YEAR to FRACTION(5);
	DEFINE	vfecha_fin						DATETIME YEAR to FRACTION(5);
	DEFINE	vconteo_select					INTEGER;
				
	--CONTROL DE TRANSACCIONALIDAD
    DEFINE vsFlagEnTransaccion				VARCHAR (1);
    DEFINE viContadorRegistros				INTEGER;
	DEFINE fecha_nomenclatura				VARCHAR(6);
-----------------------------------------------

    LET vcodgironeg2					= '';
    LET vdescgironeg2					= '';
    LET vdescripcion2					= '';
    LET vtransacciones2					= 0;
    LET vmonto2							= 0;
    LET vpromedio2						= 0;
	LET	vidreceptor						= '';
	LET	vinfreceptor					= '';
    LET vproducto2          			= '';
    LET vperiodo2           			= '';
    LET vidreceptor2        			= '';
    LET vinfreceptor2       			= '';
    LET vmetodocaptura2     			= '';
    LET vesnacional2        			= '';
    LET vproductotarjeta    			= "";
    LET vproductotarjeta2   			= "";
	LET v_ranking						= 0;
	LET v_ranking1						= 0;
	LET RUTA_DESTINO 					= '/RESPALDOSNEW/';
	--LET RUTA_DESTINO					= '/home/syscybauttar/clc/gironeg/';
	LET TIPO_PLANTILLA					= 'GirosNegocioNacional';
    LET TIPO_PLANTILLA2					= 'ReporteEstablecimientoNacional';
	LET NOMBRE_ARCHIVO					= 'unl_sp_reportenegocio_2_';
    LET SCRIPT_EJECUCION				= 'script_sp_reportenegocio_2.sql';
	LET CONTADOR_TRANSACCIONES_DBLOAD	= 5000;
	LET CONTADOR_TRANSACCIONES			= 1000;
	
	--CONTROL DE TRANSACCIONALIDAD
    LET	vsFlagEnTransaccion		= '';
    LET	viContadorRegistros		= 0;
	LET	CODIGO_RETORNO			= '00000';
    LET	MENSAJE_RETORNO			= 'PROCESO EXITOSO';
	LET fecha_nomenclatura 		= '';


BEGIN

	

	ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
		--SET DEBUG FILE TO RUTA_DESTINO || "sp_reportenegocio.out" WITH APPEND;
        --TRACE ON;
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		IF ( SQLERR <> 0 ) THEN
			LET CODIGO_RETORNO = SQLERR;
			LET MENSAJE_RETORNO = ERROR_INFO;
				
			RETURN CODIGO_RETORNO, MENSAJE_RETORNO;

		END IF;

	END EXCEPTION;
	
		-- Inicia la creacion del reporte
	UPDATE intercard:tb_control_reporteria_general set fecha_inicio_creacion_reporte = CURRENT 
	WHERE nombre_reporte = 'GirosNegocioNacional';
	
	UPDATE intercard:tb_control_reporteria_general set fecha_inicio_creacion_reporte = CURRENT 
	WHERE nombre_reporte = 'EstablecimientoNacional';
		

	--SET DEBUG FILE TO "/home/c90439717/reportenegocio/SP_reportenegocio_paralelo.out";
	--TRACE ON;

		
	CREATE TABLE IF NOT EXISTS paso_nego 
	(
		ranking             integer,
		codgironeg          varchar(4),
		descgironeg       	varchar(80),
		metodocaptura       varchar(2),
		descripcion         varchar(30),
		transacciones     	integer,
		monto               decimal(19,4),
		promedio			decimal(19,4),
		producto            varchar(4),
		esnacional          varchar(1),
		periodo             varchar(6)
	);
				
	CREATE TABLE IF NOT EXISTS paso_estab 
	(
		ranking             integer,
		codgironeg          varchar(4),
		descgironeg       	varchar(80),
		idreceptor          varchar(4),
		infreceptor         varchar(40),
		metodocaptura       varchar(2),
		descripcion         varchar(30),
		transacciones     	integer,
		monto               decimal(19,4),
		promedio			decimal(19,4),
		producto            varchar(4),
		esnacional          varchar(1),
		periodo             varchar(6)
	);
		
	-- Se limpia tablas paso_nego
	TRUNCATE TABLE intercard:paso_nego;
	TRUNCATE TABLE intercard:paso_estab;
		
	-- Se obtienen las fechas de la tabla control para crear el reporte
	SELECT fecha_inicio,fecha_final
	INTO vfecha_inicio,vfecha_fin
	FROM intercard:tb_control_reporteria_general
	WHERE nombre_reporte = 'GirosNegocioNacional';
	
	--se crea vaniomes para nomenclatura con fecha current
	SELECT REPLACE(LPAD(to_char(CURRENT),7),'-','') 
	INTO fecha_nomenclatura;

	-- Se crea el anio mes para el nombre del reporte
	SELECT REPLACE(LPAD(to_char(fecha_inicio),7),'-','') 
	INTO vaniomes
	FROM intercard:tb_control_reporteria_general 
	WHERE nombre_reporte='GirosNegocioNacional';
			
	-- Se aplica conteo de la tabla movimiento con las fechas guardadas en tabla control intercard:tb_control_reporteria_general
	SET ISOLATION to dirty read;
	SELECT COUNT(*)
	INTO vconteo_select
	FROM movimiento
	WHERE fechahorainauth BETWEEN vfecha_inicio AND vfecha_fin;
	

	--Se validad que la consulta con las fechas obtenidas tenga datos de lo contrario termina el proceso sin error
	IF vconteo_select > 0 then
			
		SET ISOLATION to dirty read;	
		select codgironeg, metodocaptura, tipotransaccionposdigitada, codigoiso, monto, 
		esnacional, numtarjeta, prodind, formato, movreversado, idreceptor, infreceptor
		from intercard:movimiento
		where fechahorainauth between vfecha_inicio and vfecha_fin
		into temp temporal_1 with no log;
		
		
		select codgironeg, metodocaptura, tipotransaccionposdigitada, codigoiso, monto, esnacional, 
		numtarjeta, prodind, formato, movreversado, idreceptor, infreceptor
		from temporal_1
		where codigoiso = '00'
		and prodind = '02'
		and formato in ('0200','0220','0221','0420')
		and movreversado = 'F'
		and metodocaptura is not null
		and metodocaptura != ('null')
		into temp temporal_2 with no log;
		
		
		
		select numtarjeta
		from temporal_2
		group by 1
		into temp temporal_3 with no log;
		
		
		select a.numtarjeta, b.codproductotarjeta
		from temporal_3 a
		join intercard:tarjeta b
		on a.numtarjeta = b.numtarjeta
		into temp temporal_4 with no log;
		
		
		
		select m.codgironeg, m.metodocaptura, DECODE(m.metodocaptura,
				'02','Banda magnetica leida', 
				'03','Lectura de codigo de barras',
				'05','Chip',
				'90','Deslizada',
				'81','Ecomerce MasterCard',
				'80','FallBack',
				'07','Contacless',
				'10','Pre-registro en comercio electronico',
				'91','Contactless Banda',
				'95','Chip leido CVV no confiable',
				'00','Metodos Captura No Determinados',
				tipotransaccionposdigitada,
				'AV','Telemarketing',
				'CE','Comercio_Elect',
				'CA','Cargo_AutÃ³matico',
				'HO','Hotel',
				'TG','TAG',
				'ND','No_Determinada',
				' ','No_clasificada' ) as descripcion
				, m.codigoiso, m.monto, t.codproductotarjeta, m.esnacional, vaniomes as periodo
		from temporal_2 m
		join temporal_4 t
		on m.numtarjeta = t.numtarjeta
		into temp temporal_5 with no log;
		
		
		select m.codgironeg, g.descgironeg, m.metodocaptura, m.descripcion, m.codigoiso, nvl(m.monto,0) as monto, m.codproductotarjeta, m.esnacional, m.periodo
		from temporal_5 m
		join intercard:gironegocio g
		on m.codgironeg = g.codgironeg
		into temp temporal_6 with no log;
		
		
		select m.codgironeg, m.descgironeg, m.metodocaptura, m.descripcion, count(m.codigoiso) as transacciones, sum(m.monto) as monto,
		( sum(m.monto) / count(m.codigoiso) ) as promedio, m.codproductotarjeta, m.esnacional, m.periodo
		from temporal_6 m
		group by 1,2,3,4,8,9,10
		into temp temporal_7 with no log;
						
				BEGIN WORK;
				LET iCont = 0;
				
				FOREACH WITH HOLD
				
					SELECT  codproductotarjeta 
					INTO vproductotarjeta 
					FROM intercard:productotarjeta 
					WHERE permitetransdigitadas in ('V','F')
				
					let v_ranking1 =0;
				
					FOREACH WITH HOLD
						SELECT FIRST 10 codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,codproductotarjeta,esnacional,periodo
						INTO vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2
						FROM temporal_7 
						WHERE codproductotarjeta = vproductotarjeta 
						AND periodo= vaniomes 
						AND esnacional = 'V'
						ORDER BY transacciones DESC
		
						let v_ranking1 = v_ranking1 + 1;
						
						INSERT INTO paso_nego(ranking,codgironeg,descgironeg,metodocaptura,descripcion,transacciones,monto,promedio,producto,esnacional,periodo)
						VALUES (v_ranking1,vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2);
		
						LET iCont = iCont + 1;
						IF iCont = CONTADOR_TRANSACCIONES THEN
							COMMIT;
							LET iCont = 0;
							BEGIN WORK;
						END IF;
					END FOREACH;
				END FOREACH;
				
				COMMIT;
		
				-- Generar archivo por Giro de Negocio GirosNegocioNacional
			   let vExecuteSQL ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
		        system vExecuteSQL;
		
			   let vExecuteSQL = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Metodo_Captura|Descripcion|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||TRIM(fecha_nomenclatura)||'.txt';
				system vExecuteSQL;
				
				let vExecuteSQL=  'echo "/*SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;*/  UNLOAD TO '||RUTA_DESTINO||'rpt_GirosNegocioNacionalbase_'||TRIM(fecha_nomenclatura)||'.txt '||
				          ' SELECT ranking, codgironeg, descgironeg, metodocaptura, descripcion, transacciones, monto, promedio, producto, esnacional, periodo FROM paso_nego WHERE esnacional = \"V\"'||
						  ' ;">'||RUTA_DESTINO||SCRIPT_EJECUCION;
				system vExecuteSQL;
				
				let vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION;
				system vExecuteSQL;
				
			   -- Resultado del unload se complementa con el encabezado del reporte
				let vExecuteSQL = "sed 's/|$//g' "||RUTA_DESTINO||'rpt_GirosNegocioNacionalbase_'||TRIM(fecha_nomenclatura)||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||TRIM(fecha_nomenclatura)||'.txt';
				system vExecuteSQL;
				
				let vExecuteSQL ='rm -f '||RUTA_DESTINO||'rpt_GirosNegocioNacionalbase_'||TRIM(fecha_nomenclatura)||'.txt';
				system vExecuteSQL;
				
				
				
				BEGIN WORK;
				
				LET iCont = 0;
				
				SET ISOLATION to dirty read;
				
				select codgironeg, metodocaptura, tipotransaccionposdigitada, codigoiso, monto, 
				esnacional, numtarjeta, prodind, formato, movreversado, idreceptor, infreceptor
				from intercard:movimiento
				where fechahorainauth between vfecha_inicio and vfecha_fin
				into temp temporal_11 with no log;
				
				
				select codgironeg, metodocaptura, tipotransaccionposdigitada, codigoiso, monto, esnacional, 
				numtarjeta, prodind, formato, movreversado, idreceptor, infreceptor
				from temporal_11
				where codigoiso = '00'
				and prodind = '02'
				and formato in ('0200','0220','0221','0420')
				and movreversado = 'F'
				and metodocaptura is not null
				and metodocaptura != ('null')
				into temp temporal_22 with no log;
				
				
				
				select numtarjeta
				from temporal_22
				group by 1
				into temp temporal_33 with no log;
				
				
				select a.numtarjeta, b.codproductotarjeta
				from temporal_33 a
				join intercard:tarjeta b
				on a.numtarjeta = b.numtarjeta
				into temp temporal_44 with no log;
				
				
				select m.codgironeg, m.metodocaptura, DECODE(m.metodocaptura,
					'02','Banda magnetica leida', 
					'03','Lectura de codigo de barras',
					'05','Chip',
					'90','Deslizada',
					DECODE(tipotransaccionposdigitada,
					'AV','Telemarketing',
					'CE','Comercio_Elect',
					'CA','Cargo_AutÃ³matico',
					'HO','Hotel',
					'TG','TAG',
					'ND','No_Determinada',
					' ','No_clasificada'),
					'81','Ecomerce MasterCard',
					'80','FallBack',
					'07','Contacless',
					'10','Pre-registro en comercio electronico',
					'91','Contactless Banda',
					'95','Chip leido CVV no confiable',
					'00','Metodos Captura No Determinados'
					) as descripcion
					, m.idreceptor, m.infreceptor, m.codigoiso, m.monto, t.codproductotarjeta, m.esnacional, vaniomes as periodo
					from temporal_22 m
					join temporal_44 t
					on m.numtarjeta = t.numtarjeta
					into temp temporal_8 with no log;
				
			
					
					
					select m.codgironeg, g.descgironeg,  m.idreceptor, m.infreceptor,m.metodocaptura, m.descripcion,
					m.codigoiso, nvl(m.monto,0) as monto, m.codproductotarjeta, m.esnacional, m.periodo
					from temporal_8 m
					join intercard:gironegocio g
					on m.codgironeg = g.codgironeg
					into temp temporal_9 with no log;
						
		
					select m.codgironeg, m.descgironeg, m.idreceptor, m.infreceptor,  m.metodocaptura, m.descripcion,
					count(m.codigoiso) as transacciones, sum(m.monto) as monto,
					( sum(m.monto) / count(m.codigoiso) ) as promedio, m.codproductotarjeta, m.esnacional, m.periodo
					from temporal_9 m
					group by 1,2,3,4,5,6,10,11,12
					into temp temporal_10 with no log;
					
					
					
					select codgironeg, descgironeg, idreceptor, infreceptor, metodocaptura, descripcion, 
					sum(transacciones) as transacciones, sum (monto) as monto,sum (promedio) as promedio, 
					codproductotarjeta ,esnacional, periodo
					from temporal_10 
					group by 1,2,3,4,5,6,10,11,12
					into temp datos_establecimiento with no log;
		
						
						
						
						
					LET vproductotarjeta = '';
						
		FOREACH WITH HOLD
				
					SELECT  codproductotarjeta 
					INTO vproductotarjeta 
					FROM intercard:productotarjeta 
					WHERE permitetransdigitadas in ('V','F')
				
					let v_ranking =0;
				
			FOREACH WITH HOLD
				SELECT FIRST 10 a.codgironeg,a.descgironeg,a.metodocaptura,a.descripcion,a.transacciones,a.monto,a.idreceptor ,a.infreceptor,a.promedio,a.codproductotarjeta,a.esnacional,a.periodo
				INTO vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vtransacciones2,vmonto2,vidreceptor,vinfreceptor,vpromedio2,vproducto2,vesnacional2,vperiodo2
				FROM datos_establecimiento a 
				--JOIN mes_anterior_1 b on a.codgironeg = b.codgironeg
				WHERE codproductotarjeta = vproductotarjeta 
				AND periodo= vaniomes 
				AND a.esnacional = 'V'
				ORDER BY transacciones DESC

				let v_ranking = v_ranking+1;
				
				INSERT  INTO paso_estab(ranking,codgironeg,descgironeg,metodocaptura,descripcion,idreceptor,infreceptor,transacciones,monto,promedio,producto,esnacional,periodo)
				VALUES (v_ranking,vcodgironeg2,vdescgironeg2,vmetodocaptura2,vdescripcion2,vidreceptor,vinfreceptor,vtransacciones2,vmonto2,vpromedio2,vproducto2,vesnacional2,vperiodo2);

				LET iCont = iCont + 1;
				
				IF iCont = CONTADOR_TRANSACCIONES THEN
					COMMIT;
					LET iCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
		END FOREACH;

		COMMIT;
		let vExecuteSQL ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA2||'*';
		system vExecuteSQL;

		let vExecuteSQL = 'echo "Rank|Giro de Comercio|Desc. Giro Comercio|Num.Establecimiento|Numero de Comercio|Metodo_Captura|Descripcion|Num. Transacciones|Monto Total Compras|Compra Promedio|Producto|Nacional(V)/Internacional(F)|Periodo">'||RUTA_DESTINO||TIPO_PLANTILLA2||'_'||TRIM(fecha_nomenclatura)||'.txt';
		system vExecuteSQL;
		let vExecuteSQL =  'echo "/* SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;*/ UNLOAD TO '||RUTA_DESTINO||'rpt_EstablecimientoNacionalbase_'||TRIM(fecha_nomenclatura)||'.txt '||
							' SELECT ranking, codgironeg, descgironeg, idreceptor, infreceptor, metodocaptura, descripcion, transacciones, monto, promedio, producto, esnacional, periodo FROM paso_estab WHERE esnacional = \"V\"'||
							' ;">'||RUTA_DESTINO||SCRIPT_EJECUCION;
		system vExecuteSQL;
		
		let vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION;
		system vExecuteSQL;
		
		-- Resultado del unload se complementa con el encabezado del reporte
		let vExecuteSQL = "sed 's/|$//g' "||RUTA_DESTINO||'rpt_EstablecimientoNacionalbase_'||TRIM(fecha_nomenclatura)||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA2||'_'||TRIM(fecha_nomenclatura)||'.txt';
		system vExecuteSQL;

		let vExecuteSQL ='rm -f '||RUTA_DESTINO||'rpt_EstablecimientoNacionalbase_'||TRIM(fecha_nomenclatura)||'.txt';
		system vExecuteSQL;
		
		
		let vExecuteSQL ='rm '||RUTA_DESTINO||SCRIPT_EJECUCION;
		system vExecuteSQL;
		
		
		BEGIN WORK;
		
		LET iCont = 0;
		
		COMMIT;
		
		-- Se limpian variables
		LET vfecha_inicio='';
		LET vfecha_fin ='';

		-- Se obtiene la fecha del siguiente mes
		select add_months(fecha_inicio,+1) 
		INTO vfecha_inicio
		from intercard:tb_control_reporteria_general 
		WHERE nombre_reporte ='GirosNegocioNacional';

		select add_months(fecha_final,+1) 
		INTO vfecha_fin
		from intercard:tb_control_reporteria_general
		WHERE nombre_reporte = 'GirosNegocioNacional';


			-- Se actualiza la tabla control guarda la fecha de termino del reporte
		UPDATE intercard:tb_control_reporteria_general 
		set fecha_inicio 				= vfecha_inicio,
		reporte_creado 					= 'T', 
		codigo_devuelto_spl 			= CODIGO_RETORNO,
		fecha_final 					= vfecha_fin
		where nombre_reporte				= 'GirosNegocioNacional';

		UPDATE intercard:tb_control_reporteria_general 
		set fecha_inicio				= vfecha_inicio,
		reporte_creado 					= 'T', 
		codigo_devuelto_spl				= CODIGO_RETORNO,
		fecha_final						= vfecha_fin
		where  nombre_reporte				= 'EstablecimientoNacional';
		
		
		
		
		INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha,nombre_spl,mensaje) VALUES(CURRENT,'sp_reportenegocio',CODIGO_RETORNO ||MENSAJE_RETORNO);
		
					
	ELSE
	
		-- En caso de notener registros del mes a consultar en la tabla movimiento
		LET CODIGO_RETORNO = '00000';
		LET MENSAJE_RETORNO = 'Sin datos en tabla movimiento, proceso exitoso';
		
		INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha,nombre_spl,mensaje) VALUES(CURRENT,'sp_reportenegocio',CODIGO_RETORNO ||MENSAJE_RETORNO);
		
	END IF;
		
		
		UPDATE intercard:tb_control_reporteria_general 
		set fecha_termino_creacion_reporte 				= current
		where nombre_reporte				= 'GirosNegocioNacional';

		UPDATE intercard:tb_control_reporteria_general 
		set fecha_termino_creacion_reporte				= current
		where  nombre_reporte				= 'EstablecimientoNacional';
		
		DROP TABLE IF EXISTS paso_nego;
		DROP TABLE IF EXISTS paso_estab;
		
		
		
		
	RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
	


		
END;
	


END PROCEDURE
DOCUMENT
'Modificacion: 15/12/2020',
'Autor: Marcos Gerardo Ayala Ponce',
'Descripcion: Proceso que corresponde al JOB 875',
'Modificacion: 02/03/2024',
'Autor: Softtek / A. Canseco',
'Descripcion: Optimizacion del SP dado el reporte por parte de Gerencia de Produccion y Base de Datos por altos tiempos y costos',
'Modificacion: 06/03/2025',
'Autor: Christopher Jose Leyva Castro / Maria Fernanda Ortiz Figueroa',
'Descripcion: Optimizacion del SP dado el reporte por parte de Gerencia de Produccion y Base de Datos por altos tiempos y costos, se reconstruye SP',
'Autor: Christopher Jose Leyva Castro',
'Descripcion: Se cambia la logica para el Case y borrado de archivo .sql con consulta para llenado de reporte',
'Modificacion: 26/08/2025'
;

CREATE PROCEDURE "informix".sp_validaproducto1(pNumProd CHAR(4), pNumTarjeta CHAR(16), pNumOpc CHAR(1),pClave CHAR(3),Tipot CHAR(1), Clavetp CHAR(3) )
   RETURNING CHAR(5), CHAR(6), CHAR(3), INTEGER;

   DEFINE cCodRet            CHAR(5);
   DEFINE iSqlErr            INTEGER;
   DEFINE cCodBin            CHAR(6);
   DEFINE cCodProd           CHAR(3);
   DEFINE cCodClaveTar       INTEGER;
   DEFINE cNumCta            CHAR(12);
   DEFINE cLimiteAut         money (14,2);

   LET cCodRet              = '00000';
   LET cCodBin              = '000000';
   LET cCodProd             = '000';
   LET cCodClaveTar         = 0;

BEGIN
                   ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;

                             RETURN cCodRet, cCodBin, cCodProd, cCodClaveTar;
                         END IF;
                   END EXCEPTION;

                --SET DEBUG FILE TO "/tmp/combinacion/Sp_ValidaProducto.out";
                --TRACE ON;

                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

               SELECT codproductotarjeta,clave_tipotarjeta,bin
               INTO cCodProd,cCodClaveTar,cCodBin
               FROM intercard:tipotarjeta
               WHERE codproductotarjeta = pClave
               AND Tipo = Tipot
               AND clave = Clavetp;
                --AND flagsolicitud = 1;

                         IF pNumProd = "6001" THEN

                            SELECT LIMIT 1 num_credito INTO cNumCta FROM bdicred: sd_tarjeta WHERE num_tarjeta = pNumTarjeta;
                            SELECT LIMIT 1 monto_otorgado INTO cLimiteAut FROM bdicred: sd_maesdos where num_credito = cNumCta;

                            --* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
                            SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cCodProd
                            FROM intercard:"informix".segmentoproducto
                            WHERE tipo_producto = "C"
                            AND limite_max >= NVL(cLimiteAut,0)
                            AND limite_min <= NVL(cLimiteAut,0);
                          END IF;

              IF cCodBin IS NULL or cCodClaveTar IS NULL or cCodBin IS NULL THEN
                      LET  cCodRet = '00001';
              END IF;


               RETURN cCodRet, cCodBin, cCodProd,cCodClaveTar;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Irma Ureta Gaxiola',
'FECHA: 17/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar que en nÃ¢ÂÂmero de producto de la cuenta exista en la base de datos intercard ';


CREATE PROCEDURE "informix".sp_aplica_genconadmin_pba( psNumEmpleado CHAR (8), psArchivoOrigen CHAR(3), psNombreArchivo CHAR (21), 
psFlag_AplicarSaldos CHAR(1), pdtFecha_Conciliacion DATETIME YEAR TO FRACTION (5))

--****************************************************************************************************
-- DESCRIPCION:  SP QUE VALIDA LOS PARAMETROS DE ENTRADA PROVENIENTES DEL TRIGER () Y DECIDE EJECUTAR LA CONCILIACION ADMINISTRATIVA (sp_GenConAdMin)
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 09/02/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico  --- ADMINI8STRATIVA
-- MODIFICADO :  
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsNomArchivoComplemento CHAR(21);
DEFINE vsFechaArchivo CHAR(8);
DEFINE vsArchivoOrigen CHAR(3);
DEFINE vsRuta_Repositorio_WIN CHAR(100);

DEFINE vsNomArchivoCom CHAR(21);
DEFINE vsNomArchivoCred CHAR(20);
DEFINE vsNomArchivoDeb CHAR(20);
DEFINE vsRuta_Repositorio_AIX CHAR(100);

DEFINE vsRespuesta CHAR(5);
DEFINE Total_Registros INTEGER;
DEFINE Mensaje_Respuesta CHAR(1000);


DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsNomArchivoComplemento = '';
LET vsFechaArchivo = '';
LET vsArchivoOrigen = '';
LET vsRuta_Repositorio_WIN = '';

LET vsNomArchivoCom = '';
LET vsNomArchivoCred = '';
LET vsNomArchivoDeb = '';
LET vsRuta_Repositorio_AIX = '';

LET vsRespuesta = '';
LET Total_Registros = 0;
LET Mensaje_Respuesta = '';



LET visqlerr = 0;

SET DEBUG FILE TO 'sp_aplica_genconadmin_pba.out';
TRACE ON ;

BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
		
	END EXCEPTION;
	
	IF ( psNumEmpleado = '3' )	THEN
		--SET DEBUG FILE TO '/informixuc7/perifericos/Trace_Aplica_GenConAdmin.txt';
		--TRACE ON ;
	END IF ;
	
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
	IF (psArchivoOrigen = 'TCC') THEN
		LET vsNomArchivoComplemento = 'BCPLTCD_' || SUBSTRING (psNombreArchivo FROM 9 FOR 12);
		LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
		LET vsNomArchivoCred = psNombreArchivo;
		LET vsNomArchivoDeb = vsNomArchivoComplemento;
	ELIF (psArchivoOrigen = 'TCD') THEN
		LET vsNomArchivoComplemento = 'BCPLTCC_' || SUBSTRING (psNombreArchivo FROM 9 FOR 12);
		LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
		LET vsNomArchivoCred = vsNomArchivoComplemento;
		LET vsNomArchivoDeb = psNombreArchivo;
	END IF;
	
	
	IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
	ELIF (( psNombreArchivo <> 'TCC' ) AND ( psNombreArchivo = 'TCD' )) THEN --ARCHIVOS NO CORRESPONDIENTES CON TIENDAS COPPEL NO SE PROCESAN
	ELIF ( pdtFecha_Conciliacion::DATE <> CURRENT::DATE ) THEN -- VALIDA QUE LA FECHA CORRESPONDA CON LA ACTUAL
	ELIF ( SUBSTRING (psNombreArchivo FROM 9 FOR 8) <> vsFechaArchivo ) THEN -- VALIDA QUE EL ARCHIVO CORRESPONDA CON LA FECHA DE CONCILIACION (AUTOMATICA) 
	ELIF ( NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE FechaConciliacion::DATE = pdtFecha_Conciliacion::DATE AND TRIM(Nom_Archivo) = TRIM(psNombreArchivo)) ) THEN --VALIDA KE EXISTA EL REGISTRO 	
	ELIF ( NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE FechaConciliacion::DATE = pdtFecha_Conciliacion::DATE AND TRIM(Nom_Archivo) = TRIM(vsNomArchivoComplemento)) ) THEN --VALIDA KE EXISTA EL REGISTRO DEL ARCHIVO COMPLEMENTO EN LA MISMA FECHA	
	ELSE -- OK
		
		--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
		EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 30 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
		
		--CORRE LA CONCILIACION ADMINISTRATIVA
		--EXECUTE PROCEDURE intercard:sp_genconadmin_pba(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, pdtFecha_Conciliacion::DATE) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;
		EXECUTE PROCEDURE intercard:sp_genconadmin_pba('/home/sysconau/conciliacion/tcoppel') INTO vsRespuesta;

		
	END IF;
	
END
END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SP QUE VALIDA LOS PARAMETROS DE ENTRADA PROVENIENTES DEL TRIGER () Y DECIDE EJECUTAR LA CONCILIACION ADMINISTRATIVA (sp_GenConAdMin).',
'Fecha: 2010/02/09',
'Version: 20100209.1613',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_aplica_genconadmin ( psNumEmpleado CHAR (8), psArchivoOrigen CHAR(3), psNombreArchivo CHAR (23), 
psFlag_AplicarSaldos CHAR(1), pdtFecha_Conciliacion DATETIME YEAR TO FRACTION (5))

--****************************************************************************************************
-- DESCRIPCION:  SP QUE VALIDA LOS PARAMETROS DE ENTRADA PROVENIENTES DEL TRIGER () Y DECIDE EJECUTAR LA CONCILIACION ADMINISTRATIVA (sp_GenConAdMin)
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 09/02/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico  --- ADMINI8STRATIVA
-- MODIFICADO : 23/04/2010 Casanova Edeza Hector Juan --Se agrego la logica para considerar a archivos de corresponsales de pagos(CCP), depositos(CCD) para que se active la conciliacion administratica de corresponsales
-- MODIFICADO : 09/06/2010 Casanova Edeza Hector Juan --Se modificaron los criterios de busqueda de archivos conciliados para que contemplen las tablas de conciliacion automatica y conciliacion manual.
-- MODIFICADO : 26/05/2011 Casanova Edeza Hector Juan --Se agrega la funcionalidad de la conciliacion administrativa para el archivo de TPD.
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsNomArchivoComplemento CHAR(23);
DEFINE vsFechaArchivo CHAR(8);
DEFINE vsArchivoOrigen CHAR(3);
DEFINE vsRuta_Repositorio_WIN CHAR(100);

DEFINE vsNomArchivoCom CHAR(23);
DEFINE vsNomArchivoCred CHAR(23);
DEFINE vsNomArchivoDeb CHAR(23);
DEFINE vsRuta_Repositorio_AIX CHAR(100);

DEFINE vsRespuesta CHAR(5);
DEFINE Total_Registros INTEGER;
DEFINE Mensaje_Respuesta CHAR(1000);

DEFINE vdtFechaArchivo DATE;


DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsNomArchivoComplemento = '';
LET vsFechaArchivo = '';
LET vsArchivoOrigen = '';
LET vsRuta_Repositorio_WIN = '';

LET vsNomArchivoCom = '';
LET vsNomArchivoCred = '';
LET vsNomArchivoDeb = '';
LET vsRuta_Repositorio_AIX = '';

LET vsRespuesta = '';
LET Total_Registros = 0;
LET Mensaje_Respuesta = '';

LET vdtFechaArchivo = CURRENT::DATE;


LET visqlerr = 0;


--SET DEBUG FILE TO '/home/sysifx/conciliacion/TraceAplica_genconadmin.sql';
--TRACE ON ;

BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
		
	END EXCEPTION;
	
	
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	IF ((psArchivoOrigen = 'TCC') OR (psArchivoOrigen = 'TCD')) THEN --INTERREDES
		
		--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
		IF (psArchivoOrigen = 'TCC') THEN
			LET vsNomArchivoComplemento = 'BCPLTCD_' || SUBSTRING (psNombreArchivo FROM 9 FOR 12);
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vsNomArchivoCred = psNombreArchivo;
			LET vsNomArchivoDeb = vsNomArchivoComplemento;
		ELIF (psArchivoOrigen = 'TCD') THEN
			LET vsNomArchivoComplemento = 'BCPLTCC_' || SUBSTRING (psNombreArchivo FROM 9 FOR 12);
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vsNomArchivoCred = vsNomArchivoComplemento;
			LET vsNomArchivoDeb = psNombreArchivo;
		END IF;
		
		IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
			ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V') 
				AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V')) THEN  --VALIDA KE EXISTA EL REGISTRO
			ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V') 
				AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V')) THEN ----VALIDA KE EXISTA EL REGISTRO DEL ARCHIVO COMPLEMENTO EN LA MISMA FECHA
		ELSE -- OK
			--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
			EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 70 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			
			IF (vdtFechaArchivo <> CURRENT::DATE) THEN --ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
				--concitarjMMDDAAAA.txt
				LET vsNomArchivoCom = SUBSTRING (vsNomArchivoCom FROM 1 FOR 9) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
			END IF;
			
			--CORRE LA CONCILIACION ADMINISTRATIVA INTERREDES
			EXECUTE PROCEDURE Intercard:sp_GenConAdMin(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, vdtFechaArchivo) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;			
		END IF;
		
	ELIF ((psArchivoOrigen = 'CCD') OR (psArchivoOrigen = 'CCP')) THEN --CORRESPONSALES 
		--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
		--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt 
		IF (psArchivoOrigen = 'CCP') THEN --CORRESPONSALES CREDITO
			LET vsNomArchivoComplemento = 'BCPLCCD_' || SUBSTRING (psNombreArchivo FROM 9 FOR 15);
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			LET vsNomArchivoCred = psNombreArchivo;
			LET vsNomArchivoDeb = vsNomArchivoComplemento;
		ELIF (psArchivoOrigen = 'CCD') THEN --CORRESPONSALES DEBITO
			LET vsNomArchivoComplemento = 'BCPLCCP_' || SUBSTRING (psNombreArchivo FROM 9 FOR 15);
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			LET vsNomArchivoCred = vsNomArchivoComplemento;
			LET vsNomArchivoDeb = psNombreArchivo;
		ELIF (psArchivoOrigen = 'TPD') THEN --TRANSFERENCIA PRESTAMOS COPPEL
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			LET vsNomArchivoCred = 'TPD';
			LET vsNomArchivoDeb = psNombreArchivo;
		END IF;
		
		
		IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
		ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V') 
			AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V')) THEN  --VALIDA KE EXISTA EL REGISTRO
		ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V') 
			AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V')) THEN ----VALIDA KE EXISTA EL REGISTRO DEL ARCHIVO COMPLEMENTO EN LA MISMA FECHA
		ELSE -- OK
			--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
			EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 71 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			
			IF (vdtFechaArchivo <> CURRENT::DATE) THEN --ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
				--concicorrMMDDAAAA.txt
				LET vsNomArchivoCom = SUBSTRING (vsNomArchivoCom FROM 1 FOR 9) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
			END IF;
			
			--CORRE LA CONCILIACION ADMINISTRATIVA CORRESPONSALES
			EXECUTE PROCEDURE Intercard:sp_GenConAdMinCorr(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, vdtFechaArchivo) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;
		END IF;
		
	ELIF (psArchivoOrigen = 'TPD') THEN -- TRANSFERENCIA PRESTAMOS COPPEL
		--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
		--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt 
		
		LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
		LET vsNomArchivoCred = 'TPD';
		LET vsNomArchivoDeb = psNombreArchivo;		
		
		IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
		ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V') 
			AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V')) THEN  --VALIDA KE EXISTA EL REGISTRO
		ELSE -- OK
			--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
			EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 72 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			
			IF (vdtFechaArchivo <> CURRENT::DATE) THEN --ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
				--concicorrMMDDAAAA.txt
				LET vsNomArchivoCom = SUBSTRING (vsNomArchivoCom FROM 1 FOR 9) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
			END IF;
			
			--CORRE LA CONCILIACION ADMINISTRATIVA CORRESPONSALES
			EXECUTE PROCEDURE Intercard:sp_GenConAdMinCorr(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, vdtFechaArchivo) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;
		END IF;
		
	END IF;
	
	
END
END PROCEDURE 
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SP QUE VALIDA LOS PARAMETROS DE ENTRADA PROVENIENTES DEL TRIGER () Y DECIDE EJECUTAR ',
'LA CONCILIACION ADMINISTRATIVA (sp_GenConAdMin).',
'Fecha: 2010/02/09',
'Version: 20100209.1613',
'BD: Intercard',
'',
'Modificado: Javier Chavez BANCOPPEL',
'Proyecto: Conciliacion Automatica',
'Descripcion: Al validar el tipo de archivo se modifico parametro psNombreArchivo por el de ',
'psArchivoOrigen. Cambio de formato de nombre del archivo "BCPL_TCD" y "BCPL_TCC" por "BCPLTCD_" y "BCPLTCC_".',
'Fecha: 02/19/2010',
'Version: 20100219.1646',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1107',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego la logica para considerar a archivos de corresponsales de pagos(CCP),', 
'depositos(CCD) para que se active la conciliacion administratica de corresponsales.',
'Fecha: 2010/04/23',
'Version: 20100423.1858',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modificaron los criterios de busqueda de archivos conciliados para que contemplen ',
'las tablas de conciliacion automatica y conciliacion manual.',
'Fecha: 2010/06/09',
'Version: 20100609.1657',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - TRANSFERENCIA DE PRESTAMOS COPPEL',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega la funcionalidad de la conciliacion administrativa para el archivo de TPD.',
'Fecha: 2011/05/26',
'Version: 20110526.1712',
'BD: Intercard'; */
;

CREATE PROCEDURE "informix".sp_clasifica_devoluciones_pos_pba
(psNomArchivo VARCHAR(30), psArchivoOrigen VARCHAR(3), psNumTarjeta VARCHAR(20), psSecuenciaAutArchivo VARCHAR(6), pmMontoArchivo MONEY, psNomComercio VARCHAR(30), psEncontrado VARCHAR(1), pmMontoIntercard MONEY, piStatusConciliacion INTEGER, psMovConciliado CHAR(1), psFechaHoraInAuth DATETIME YEAR TO FRACTION )

--RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  GUARDA REGISTRO DE LOS TIPOS DE DEVOLUCIONES PROCESADAS EN LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 26/08/2011
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica -- 
-- MODIFICADO : Casanova Edeza Hector Juan 2011/11/28' --SE AGREGA LA VALIDACION DEL CAMPO MOVCONCILIADO PARA VALIDAR LA TRANSACCION ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/01' --SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS CON MONTO MAYOR PARA QUE SE CALSIFIQUEN COMO PENDIENTES CON ERROR.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/07' --SE AJUSTA EL FILTRO PARA OBTENER DE MANERA CERTERA LA REFERENCIA DEL MOVIMIENTO ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/15' --SE MODIFICA LA VALIDACION DEL RETENIDO PARA CREDITO Y DEBITO.
--***************************************************************************************************


/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;
DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE vsEstado VARCHAR(1);
DEFINE vsMotivo VARCHAR(60);
DEFINE vsFolioSucursal VARCHAR(16);
DEFINE vsReferencia23 VARCHAR(40);
DEFINE viKeyx INTEGER;
DEFINE vsAplicado VARCHAR(1);

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET vsEstado = '';
LET vsMotivo = '';
LET vsFolioSucursal = '';
LET vsReferencia23 = '';
LET viKeyx = 0;
LET vsAplicado = '';


BEGIN

ON EXCEPTION SET viSQLerr
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsCodRet = '00100';
	
END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT MAX(KeyX), FolioSucursal, Referencia
	INTO viKeyx, vsFolioSucursal, vsReferencia23
	FROM Intercard:"informix".Central 
	WHERE NombreArchivo = psNomArchivo
	AND NumTarjeta = psNumTarjeta
	AND TipoMov in ('A','D')
	AND Importe = pmMontoArchivo
	GROUP BY keyx, FolioSucursal, Referencia;

		
	IF ((psEncontrado <> 'V') OR (LENGTH(TRIM(psSecuenciaAutArchivo)) < 6 ) OR (TRIM(psSecuenciaAutArchivo) IN ('', '000000', '111111', '222222', '333333', '444444', '555555', '666666', '777777', '888888', '999999'))) THEN 
		--REGISTRO NO ENCONTRADO (NO CONCUERDA NUM TARJETA O SECUENCIA AUTORIZACION).
		--DISCRIMINAR SECUENCIAS CONSECUTIVAS.
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsMotivo = 'El número de autorización no coincide con la compra';
		LET vsEstado = 'P';
		LET vsAplicado = 'F';
	
	ELIF ((psMovConciliado <> 'V') AND (EXISTS (SELECT Fecha_Hoy FROM bdinteg:"informix".Si_Fechas WHERE ((Fecha_Hoy::DATE - (psFechaHoraInAuth::DATE) >8 ))))) THEN 
	
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';	
		
	
	ELIF (psMovConciliado <> 'V') THEN 
		-- VALIDA QUE EL MOVIMIENTO ORIGINAL ESTE CONCILIADO.
		LET vsMotivo = 'La compra original todavía no esta marcada como conciliada';
		--LET vsEstado = 'P';
		--LET vsAplicado = 'F';
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
	/*	
	ELIF ((psArchivoOrigen IN ('VND','VID')) --SOLO DEBITO
	AND (EXISTS (SELECT Cuenta FROM BdiCheq:"informix".Sc_DocRet 
	WHERE Folio_Suc = NVL(vsFolioSucursal, '')
	AND Cancelado = 'L'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO 
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
		
	ELIF ((psArchivoOrigen IN ('VNC', 'VIC')) --SOLO CREDITO
	AND (EXISTS (SELECT Num_Credito FROM BdiCred:"informix".Sd_MaeRetenido 
	WHERE Empresa = '001' AND Num_Credito IS NOT NULL  
	AND Folio_Suc = NVL(vsFolioSucursal, '')
	AND Estatus  = 'S'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO
	*/
	
	
	ELIF (pmMontoArchivo > pmMontoIntercard) THEN
		--MONTO ARCHIVO MAYOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		LET vsMotivo = 'Devolucion con monto mayor a la compra original';
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsEstado = 'P';
		LET vsAplicado = 'E';
		
	ELIF (pmMontoArchivo < pmMontoIntercard) THEN 
		--MONTO MENOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		--APLICACION FORZADA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'F';
		LET vsAplicado = 'F';	
		
	ELSE -- TODO COINCIDE
		--CONCILIADA (OK), SE APLICA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'A';
		LET vsAplicado = 'F';
		
	END IF;

	
	
	--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt
	--REGISTRO DE DETALLE
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	INSERT INTO BdiTarjeta:"informix".Td_DevolucionesPOS 
	(
		NomArchivo, 
		ArchivoOrigen, 
		Fecha, 
		TipoArchivo, 
		NumTarjeta, 
		SecuenciaAutArchivo, 
		MontoArchivo, 
		NomComercio, 
		Referencia, 
		Encontrado, 
		MontoIntercard, 
		Motivo,
		Estado,
		Aplicado
	) 
	VALUES 
	(
		psNomArchivo, 
		psArchivoOrigen, 
		SUBSTR(psNomArchivo,11,2) || '/' || (SUBSTR(psNomArchivo,9,2) || '/' ||  SUBSTR(psNomArchivo,13,4)),  --FECHA
		(CASE WHEN (psArchivoOrigen IN ('VNC', 'VIC')) THEN 'C'	WHEN (psArchivoOrigen IN ('VND', 'VID')) THEN 'D' ELSE 'X' END),  --TIPOARCHIVO
		NVL(psNumTarjeta, ''), 
		NVL(psSecuenciaAutArchivo, ''), 
		NVL(pmMontoArchivo, 0.0), 
		NVL(psNomComercio, ''), 
		NVL(vsReferencia23, ''), 
		NVL(psEncontrado, ''), 
		NVL(pmMontoIntercard, 0.0), 
		NVL(vsMotivo, ''), 
		NVL(vsEstado, ''),
		NVL(vsAplicado, '')
	);
	
	--RETURN vsCodRet, vsMensaje_Respuesta;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA REGISTRO DE LOS TIPOS DE DOVOLUCIONES PROCESADAS EN LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.',
'Fecha: 2011/08/25',
'Version: 20110825.0933',
'BD: Intercard', 
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LA VALIDACION DEL CAMPO MOVCONCILIADO PARA VALIDAR LA TRANSACCION ORIGINAL.',
'Fecha: 2011/11/28',
'Version: 2011128.1910',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS CON MONTO MAYOR PARA QUE SE CALSIFIQUEN COMO PENDIENTES CON ERROR.',
'Fecha: 2011/12/01',
'Version: 20111201.1900',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA EL FILTRO PARA OBTENER DE MANERA CERTERA LA REFERENCIA DEL MOVIMIENTO ORIGINAL.',
'Fecha: 2011/12/07',
'Version: 20111207.1648',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA VALIDACION DEL RETENIDO PARA CREDITO Y DEBITO.',
'Fecha: 2011/12/15',
'Version: 20111215.1025',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_clasifica_devoluciones_pos
(psNomArchivo VARCHAR(30), psArchivoOrigen VARCHAR(3), psNumTarjeta VARCHAR(20), psSecuenciaAutArchivo VARCHAR(6), pmMontoArchivo MONEY, psNomComercio VARCHAR(30), psEncontrado VARCHAR(1), pmMontoIntercard MONEY, piStatusConciliacion INTEGER, psMovConciliado CHAR(1), psFechaHoraInAuth DATETIME YEAR TO FRACTION )

--RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  GUARDA REGISTRO DE LOS TIPOS DE DEVOLUCIONES PROCESADAS EN LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 26/08/2011
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica -- 
-- MODIFICADO : Casanova Edeza Hector Juan 2011/11/28' --SE AGREGA LA VALIDACION DEL CAMPO MOVCONCILIADO PARA VALIDAR LA TRANSACCION ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/01' --SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS CON MONTO MAYOR PARA QUE SE CALSIFIQUEN COMO PENDIENTES CON ERROR.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/07' --SE AJUSTA EL FILTRO PARA OBTENER DE MANERA CERTERA LA REFERENCIA DEL MOVIMIENTO ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/15' --SE MODIFICA LA VALIDACION DEL RETENIDO PARA CREDITO Y DEBITO.
--***************************************************************************************************


/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;
DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE vsEstado VARCHAR(1);
DEFINE vsMotivo VARCHAR(60);
DEFINE vsFolioSucursal VARCHAR(16);
DEFINE vsReferencia23 VARCHAR(40);
DEFINE viKeyx INTEGER;
DEFINE vsAplicado VARCHAR(1);

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET vsEstado = '';
LET vsMotivo = '';
LET vsFolioSucursal = '';
LET vsReferencia23 = '';
LET viKeyx = 0;
LET vsAplicado = '';


BEGIN

ON EXCEPTION SET viSQLerr
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsCodRet = '00100';
	
END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT MAX(KeyX), FolioSucursal, Referencia
	INTO viKeyx, vsFolioSucursal, vsReferencia23
	FROM Intercard:Central 
	WHERE NombreArchivo = psNomArchivo
	AND NumTarjeta = psNumTarjeta
	AND TipoMov in ('A','D')
	AND Importe = pmMontoArchivo
	GROUP BY keyx, FolioSucursal, Referencia;

		
	IF ((psEncontrado <> 'V') OR (LENGTH(TRIM(psSecuenciaAutArchivo)) < 6 ) OR (TRIM(psSecuenciaAutArchivo) IN ('', '000000', '111111', '222222', '333333', '444444', '555555', '666666', '777777', '888888', '999999'))) THEN 
		--REGISTRO NO ENCONTRADO (NO CONCUERDA NUM TARJETA O SECUENCIA AUTORIZACION).
		--DISCRIMINAR SECUENCIAS CONSECUTIVAS.
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsMotivo = 'El número de autorización no coincide con la compra';
		LET vsEstado = 'P';
		LET vsAplicado = 'F';
	
	ELIF ((psMovConciliado <> 'V') AND (EXISTS (SELECT Fecha_Hoy FROM bdinteg:"informix".Si_Fechas WHERE ((Fecha_Hoy::DATE - (psFechaHoraInAuth::DATE) >8 ))))) THEN 
	
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';	
		
	
	ELIF (psMovConciliado <> 'V') THEN 
		-- VALIDA QUE EL MOVIMIENTO ORIGINAL ESTE CONCILIADO.
		LET vsMotivo = 'La compra original todavía no esta marcada como conciliada';
		--LET vsEstado = 'P';
		--LET vsAplicado = 'F';
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
	/*	
	ELIF ((psArchivoOrigen IN ('VND','VID')) --SOLO DEBITO
	AND (EXISTS (SELECT Cuenta FROM BdiCheq:"informix".Sc_DocRet 
	WHERE Folio_Suc = NVL(vsFolioSucursal, '')
	AND Cancelado = 'L'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO 
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
		
	ELIF ((psArchivoOrigen IN ('VNC', 'VIC')) --SOLO CREDITO
	AND (EXISTS (SELECT Num_Credito FROM BdiCred:"informix".Sd_MaeRetenido 
	WHERE Empresa = '001' AND Num_Credito IS NOT NULL  
	AND Folio_Suc = NVL(vsFolioSucursal, '')
	AND Estatus  = 'S'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO
	*/
	
	
	ELIF (pmMontoArchivo > pmMontoIntercard) THEN
		--MONTO ARCHIVO MAYOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		LET vsMotivo = 'Devolucion con monto mayor a la compra original';
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsEstado = 'P';
		LET vsAplicado = 'E';
		
	ELIF (pmMontoArchivo < pmMontoIntercard) THEN 
		--MONTO MENOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		--APLICACION FORZADA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'F';
		LET vsAplicado = 'F';	
		
	ELSE -- TODO COINCIDE
		--CONCILIADA (OK), SE APLICA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'A';
		LET vsAplicado = 'F';
		
	END IF;

	
	
	--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt
	--REGISTRO DE DETALLE
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	INSERT INTO BdiTarjeta:Td_DevolucionesPOS 
	(
		NomArchivo, 
		ArchivoOrigen, 
		Fecha, 
		TipoArchivo, 
		NumTarjeta, 
		SecuenciaAutArchivo, 
		MontoArchivo, 
		NomComercio, 
		Referencia, 
		Encontrado, 
		MontoIntercard, 
		Motivo,
		Estado,
		Aplicado
	) 
	VALUES 
	(
		psNomArchivo, 
		psArchivoOrigen, 
		SUBSTR(psNomArchivo,11,2) || '/' || (SUBSTR(psNomArchivo,9,2) || '/' ||  SUBSTR(psNomArchivo,13,4)),  --FECHA
		(CASE WHEN (psArchivoOrigen IN ('VNC', 'VIC')) THEN 'C'	WHEN (psArchivoOrigen IN ('VND', 'VID')) THEN 'D' ELSE 'X' END),  --TIPOARCHIVO
		NVL(psNumTarjeta, ''), 
		NVL(psSecuenciaAutArchivo, ''), 
		NVL(pmMontoArchivo, 0.0), 
		NVL(psNomComercio, ''), 
		NVL(vsReferencia23, ''), 
		NVL(psEncontrado, ''), 
		NVL(pmMontoIntercard, 0.0), 
		NVL(vsMotivo, ''), 
		NVL(vsEstado, ''),
		NVL(vsAplicado, '')
	);
	
	--RETURN vsCodRet, vsMensaje_Respuesta;

END;
END PROCEDURE;