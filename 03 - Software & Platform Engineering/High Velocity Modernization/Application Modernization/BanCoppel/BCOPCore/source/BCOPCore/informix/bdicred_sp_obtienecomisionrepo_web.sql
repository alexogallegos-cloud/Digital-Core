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