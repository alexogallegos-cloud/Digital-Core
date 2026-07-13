CREATE PROCEDURE "informix".sp_ordenpago_cons_detalle(
													pEmpresa CHAR(3),
													pNum_Cte CHAR(9),
													pno_control CHAR(20),
		                                            pArchivo CHAR(12),
													pTipoDisp CHAR(4), 
													pFecha date,
													pRegistro SMALLINT
													)
    returning 
      CHAR(5) as codigo, --CODIGO 
      CHAR(20) as archivo, --Nombre del Archivo(bdibei:bei_dispersiones_odp:archivo):  solo para la consulta por archivo.
      CHAR(20) as alias,--Alias Beneficiario (bdibei:bei_dispersiones_odp: alias):
      CHAR(104) as nombre_completo,--Nombre Beneficiario (bdibei:bei_dispersiones_odp: nombre_completo):
      CHAR(12) as clave_envio,--Numero de control ( bdisac:sac_enviosdineroya:no_control/bdibei:bei_dispersiones_odp :clave_envio):   bdisac:sac_enviosdineroyahis:no_control
      CHAR(16) as num_referencia,--Numero de referencia: (bdibei:bei_dispersiones_odp: num_referencia): 
      CHAR(20) as cuenta_origen, --cuenta donde se realizo el cobro de la orden (bdibei:bei_dispersiones_odp: cta_origen)
      CHAR(30) as concepto,---Concepto (bdibei:bei_dispersiones_odp:concepto): 
      DECIMAL(16,2) as importe_envio,--Importe envio (importe_envio): bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
      DECIMAL(16,2) as comision,--ComisiÃÂ³n (comision): bdisac:sac_enviosdineroya / bdisac:sac_enviosdineroyahis
      DECIMAL(16,2) as iva,--Iva Comision (iva): bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
      DECIMAL(16,2) as importe_total,--importe_total(importe_total): bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
      CHAR(4) as suc_origen,--Sucursal Origen (suc_origen): bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
      DATE as fechas_origen, --Fecha origen del envio vfecha_envio bdisac:"informix".sac_enviosdineroya/bdisac:sac_enviosdineroyahis
      DATETIME HOUR TO FRACTION(3) as hora_origen,--Hora origen del envio vhora_envio bdisac:"informix".sac_enviosdineroya/bdisac:sac_enviosdineroyahis
      DATE as fechas_estatus, --Fecha depende del estatus 
      DATETIME HOUR TO FRACTION(3) as hora_estatus,--Hora depende del estatus
      CHAR(4) as suc_cance, --Sucursal donde se cancela (suc_cance):  bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
	  CHAR (2) as cod_status,
	  CHAR(20) as des_status;

		  
    DEFINE sql_err integer ;
    DEFINE cod_ret CHAR(5);
    DEFINE varchivo CHAR(20); --Nombre del Archivo(bdibei:bei_dispersiones_odp:archivo):  solo para la consulta por archivo.
    DEFINE valias CHAR(20);
    DEFINE vnombre_completo CHAR(104);
    DEFINE vclave_envio CHAR(12);
    DEFINE vnum_referencia CHAR(16);
	DEFINE Vcuenta_origen CHAR(20);
    DEFINE vconcepto CHAR(30);
    DEFINE vimporte_envio DECIMAL(16,2);
    DEFINE vcomision  DECIMAL(16,2);
    DEFINE viva  DECIMAL(16,2);
    DEFINE vimporte_total  DECIMAL(16,2);
    DEFINE vsuc_origen CHAR(4);
    DEFINE vfecha_envio DATE; --Fecha de Origen (fecha_envio):  bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
    DEFINE vhora_envio DATETIME HOUR TO FRACTION(3);
    DEFINE vfecha_pago DATE;
    DEFINE vhora_pago DATETIME HOUR TO FRACTION(3);
    DEFINE vsuc_cance CHAR(4); --Sucursal donde se cancela (suc_cance):  bdisac:sac_enviosdineroya/bdisac:sac_enviosdineroyahis
    DEFINE vfecha_cance DATE;
    DEFINE vhora_cance DATETIME HOUR TO FRACTION(3);
    DEFINE vfecha_bloq  DATE;
	DEFINE vhoy DATETIME YEAR to DAY;
	DEFINE vfechaStatus DATE;
	DEFINE vhoraStatus DATETIME HOUR TO FRACTION(3);
	DEFINE vcodestatus CHAR(2);
	DEFINE vdesestatus CHAR(20);
	DEFINE VdiasBloqueo SMALLINT;
	
    --SET debug FILE TO "/home/informix/BereniceOut/sp_ordenpago_cons_detalle.out";
    --Trace ON;

    LET sql_err =0;
    LET cod_ret ='00000';
    LET varchivo ='';
    LET valias ='';
    LET vnombre_completo ='';
    LET vclave_envio ='';
    LET vnum_referencia ='';
	LET vcuenta_origen='';
    LET vconcepto='';
    LET vimporte_envio = 0.0;
    LET vcomision  = 0.0;
    LET viva  = 0.0;
    LET vimporte_total  = 0.0;
	LET vsuc_origen ='';
    LET vfecha_envio  = '01/01/1900';
    LET vhora_envio  = '00:00:00.001';
    LET vfecha_pago = '01/01/1900';
    LET vhora_pago = '00:00:00.001';
    LET vsuc_cance='';
    LET vfecha_cance  = '01/01/1900';
    LET vhora_cance = '00:00:00.001';
    LET vfecha_bloq   = '01/01/1900';
	LET vhoy = CURRENT year to day;
	LET vfechaStatus = '01/01/1900';
	LET vhoraStatus  = '00:00:00.001';
	LET vcodestatus ='';
	LET vdesestatus ='';
	LET VdiasBloqueo =0;
	

	--*****************************************************************************************************************************
	-- BD: bdibei
	-- Clonado: se crea spl para consultar el detalla de una orden de pago deacuerdo a su estatus y tipo(Archivo o individual)
    -- POR: Berenice Noriega
	-- FECHA:	13-Agosto-2019
	--**************************************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
	   
		   return cod_ret, varchivo, valias, vnombre_completo, vclave_envio, vnum_referencia, vcuenta_origen, vconcepto, vimporte_envio, vcomision, viva, vimporte_total, vsuc_origen, vfecha_envio, vhora_envio, vfechaStatus, vhoraStatus, vsuc_cance, vcodestatus, vdesestatus;
      END IF;
   END EXCEPTION;

      
			
--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

	If (NVL(pNum_Cte,0) == 0) OR (pNum_Cte is null) Then
		LET cod_ret='00001';
		   return cod_ret, varchivo, valias, vnombre_completo, vclave_envio, vnum_referencia, vcuenta_origen, vconcepto, vimporte_envio, vcomision, viva, vimporte_total, vsuc_origen, vfecha_envio, vhora_envio, vfechaStatus, vhoraStatus, vsuc_cance, vcodestatus, vdesestatus;	End If;
	
	If (NVL(pno_control,0) == 0) OR (pno_control is null) Then
		LET cod_ret='00002';
		   return cod_ret, varchivo, valias, vnombre_completo, vclave_envio, vnum_referencia, vcuenta_origen, vconcepto, vimporte_envio, vcomision, viva, vimporte_total, vsuc_origen, vfecha_envio, vhora_envio, vfechaStatus, vhoraStatus, vsuc_cance, vcodestatus, vdesestatus;	End If;
	
	select valor 
	into VdiasBloqueo
	from bdisac:"informix".sac_param 
	where cod_param='73'  --- LImite de dias antes de bloquear un envÃÂ­o 
	and empresa=pEmpresa;

 
    IF (NVL(pArchivo,'') == '') OR (pArchivo is null)   THEN --No se recibe numero de archivo, es individual
	  
       --Entra al listado de orden por archivo individual   vfecha_bloq, vcodestatus;
			FOREACH
				SELECT 
				a.alias, a.nombre_completo, a.concepto, b.importe_envio, a.clave_envio, a.archivo, b.fecha_envio, b.estatus, 
				a.num_referencia, a.cta_origen, b.comision, b.iva, b.importe_total, b.suc_origen, b.hora_envio, b.fecha_pago, b.hora_pago, 
				b.suc_cance, b.fecha_cance, b.hora_cance
				Into 
				valias,vnombre_completo, vconcepto,vimporte_envio, vclave_envio, varchivo, vfecha_envio, vcodestatus, 
				vnum_referencia, vcuenta_origen, vcomision, viva, vimporte_total, vsuc_origen, vhora_envio, vfecha_pago, vhora_pago, 
				vsuc_cance, vfecha_cance, vhora_cance
				From   bdibei:"informix".bei_dispersiones_odp  as a, bdisac:"informix".sac_enviosdineroya as b
				Where  a.num_cliente = pNum_Cte
				And    a.tipo_dispersion = pTipoDisp
				--And    a.fecha = pFecha
				AND    a.clave_envio=b.no_control
				AND    b.no_control=pno_control 
				
			UNION ALL
			
				SELECT 
				a.alias, a.nombre_completo, a.concepto, b.importe_envio, a.clave_envio, a.archivo, b.fecha_envio, b.estatus, 
				a.num_referencia, a.cta_origen, b.comision, b.iva, b.importe_total, b.suc_origen, b.hora_envio, b.fecha_pago, b.hora_pago, 
				b.suc_cance, b.fecha_cance, b.hora_cance
				
				From   bdibei:"informix".bei_dispersiones_odp  as a, bdisac:"informix".sac_enviosdineroyahis as b
				Where  a.num_cliente = pNum_Cte
				And    a.tipo_dispersion = pTipoDisp
				--And    a.fecha = pFecha
				AND    a.clave_envio=b.no_control
				AND    b.no_control=pno_control
						
			
			--*************************************************************************--
					--Determinar la fecha segun el estatus------------------------
					IF (vcodestatus='00' OR vcodestatus='01' ) THEN --incompleto / Activo 
					LET vfechaStatus=vfecha_envio;
					LET vhoraStatus=vhora_envio;
					
					ELIF vcodestatus='03'  THEN ----Bloqueado
					LET vfechaStatus=vfecha_envio + VdiasBloqueo; --para saber cuando se bloqueo se le suman los dias a la fecha de original 
					LET vhoraStatus='';
					
					ELIF vcodestatus='04'  THEN --Pagadp
					LET vfechaStatus=vfecha_pago;
					LET vhoraStatus=vhora_pago;
				   
					ELIF (vcodestatus='02' OR vcodestatus='05') THEN --cancelado o reversado
					LET vfechaStatus=vfecha_cance;
					LET vhoraStatus=vhora_cance;
					END IF;
			--*************************************************************************--
			select descripcion INTO vdesestatus from bdisac:"informix".sac_estatus where estatus=vcodestatus;

		   return cod_ret, varchivo, valias, vnombre_completo, vclave_envio, vnum_referencia, vcuenta_origen, vconcepto, vimporte_envio, vcomision, viva, vimporte_total, vsuc_origen, vfecha_envio, vhora_envio, vfechaStatus, vhoraStatus, vsuc_cance, vcodestatus, vdesestatus;        
		END FOREACH;	
     
    ELSE --tienen numero de archivo (opcion "VER detalle" del listado de dispersion de ordenes de pago por archivo)
			FOREACH
				SELECT 
				a.alias, a.nombre_completo, a.concepto, b.importe_envio, a.clave_envio, a.archivo, b.fecha_envio, b.estatus, 
				a.num_referencia, a.cta_origen, b.comision, b.iva, b.importe_total, b.suc_origen, b.hora_envio, b.fecha_pago, b.hora_pago, 
				b.suc_cance, b.fecha_cance, b.hora_cance
				Into 
				valias,vnombre_completo, vconcepto,vimporte_envio, vclave_envio, varchivo, vfecha_envio, vcodestatus, 
				vnum_referencia, vcuenta_origen, vcomision, viva, vimporte_total, vsuc_origen, vhora_envio, vfecha_pago, vhora_pago, 
				vsuc_cance, vfecha_cance, vhora_cance					 
				From   bdibei:"informix".bei_dispersiones_odp as a, bdisac:"informix".sac_enviosdineroya as b
				Where  num_cliente = pNum_Cte
				And    tipo_dispersion = pTipoDisp
				--And    fecha = pFecha
				AND    archivo=pArchivo
				And    a.clave_envio=b.no_control
				AND    b.no_control=pno_control
			
			UNION ALL
				SELECT 
				a.alias, a.nombre_completo, a.concepto, b.importe_envio, a.clave_envio, a.archivo, b.fecha_envio, b.estatus, 
				a.num_referencia, a.cta_origen, b.comision, b.iva, b.importe_total, b.suc_origen, b.hora_envio, b.fecha_pago, b.hora_pago, 
				b.suc_cance, b.fecha_cance, b.hora_cance
				From   bdibei:"informix".bei_dispersiones_odp as a, bdisac:"informix".sac_enviosdineroyahis as b
				Where  num_cliente = pNum_Cte
				And    tipo_dispersion = pTipoDisp
				--And    fecha = pFecha
				AND    archivo=pArchivo
				And    a.clave_envio=b.no_control
				AND    b.no_control=pno_control
			
			
			--*************************************************************************--
					--Determinar la fecha segun el estatus------------------------
					IF (vcodestatus='00' OR vcodestatus='01' ) THEN --incompleto / Activo 
					LET vfechaStatus=vfecha_envio;
					LET vhoraStatus=vhora_envio;
					
					ELIF vcodestatus='03'  THEN ----Bloqueado
					LET vfechaStatus=vfecha_envio + VdiasBloqueo; --para saber cuando se bloqueo se le suman los dias a la fecha de original 
					LET vhoraStatus='';
					
					ELIF vcodestatus='04'  THEN --Pagadp
					LET vfechaStatus=vfecha_pago;
					LET vhoraStatus=vhora_pago;
				   
					ELIF (vcodestatus='02' OR vcodestatus='05') THEN --cancelado o reversado
					LET vfechaStatus=vfecha_cance;
					LET vhoraStatus=vhora_cance;
					END IF;
			--*************************************************************************--
			select descripcion INTO vdesestatus from bdisac:"informix".sac_estatus where estatus=vcodestatus;
			
		   return cod_ret, varchivo, valias, vnombre_completo, vclave_envio, vnum_referencia, vcuenta_origen, vconcepto, vimporte_envio, vcomision, viva, vimporte_total, vsuc_origen, vfecha_envio, vhora_envio, vfechaStatus, vhoraStatus, vsuc_cance, vcodestatus, vdesestatus;		
		   END FOREACH;	
END IF;
END;
END PROCEDURE;