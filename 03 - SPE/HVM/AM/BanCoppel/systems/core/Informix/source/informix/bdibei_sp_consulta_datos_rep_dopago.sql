CREATE PROCEDURE "informix".sp_consulta_datos_rep_dopago(
													pRegIni integer,
													pNumCliente CHAR(9),
													pTipoDisp CHAR(4),
													pFecha DATE,
                                                    pArchivo CHAR(12)
													)
    returning CHAR(5),CHAR(20),CHAR(104),CHAR(30), MONEY,CHAR(12),CHAR(12), CHAR(2), DATE;

    DEFINE sql_err integer ;
    DEFINE cod_ret CHAR(5);
    DEFINE sAlias CHAR(20);
    DEFINE sNombre CHAR(104);
    DEFINE sConcepto CHAR(30);
    DEFINE mImporte MONEY;
    DEFINE sClave CHAR(12);
    DEFINE sArchivo CHAR(12);
	DEFINE vestatus CHAR(2);
	DEFINE vfechaStatus DATE;
	DEFINE vfenvio DATE; 
	DEFINE vfpago DATE; 
	DEFINE vfcance DATE;
    

   -- SET debug FILE TO "/home/informix/BereniceOut/sp_consulta_datos_rep_dopago.out";
    --Trace ON;

    LET cod_ret  = '00000';
    LET sql_err = '';
    LET sAlias ='';
    LET sNombre = '';
    LET sConcepto = '';
    LET mImporte = 0.0;
    LET sClave= '';
    LET sArchivo = '';
    LET vestatus ='';
	LET vfechaStatus = '01/01/1900'; --'1900-01-01' 01/01/1900
	LET vfenvio = '01/01/1900'; --'1900-01-01' 01/01/1900
	LET vfpago = '01/01/1900'; --'1900-01-01' 01/01/1900
	LET vfcance = '01/01/1900'; --'1900-01-01'   01/01/1900

	--****************************************************************************************************
	-- BD: bdibei
	-- Clonado: se clona del spl sp_consulta_datos_rep_dopago y se modifica para regresar parametros extras
	-- MODIFICADO POR: Berenice Noriega
	-- FECHA:	29-Mayo-2019
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus;
      END IF ;
   END EXCEPTION ;

      
			
--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

	If NVL(pNumCliente,0) == 0 Then
		Let cod_ret='00001';
		return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus;
	End If;
	
	If NVL(pTipoDisp,0) == 0 Then
		Let cod_ret='00002';
		return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus;
	End If;

	If NVL(pFecha,'') == '' Then
		Let cod_ret='00003';
		return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus;
	End If;
 
    IF NVL(pArchivo,'') == '' THEN --No se recibe numero de archivo

     IF (pTipoDisp == '3004') THEN ---Entra al listado de Dispersion de ordenes de pago "por archivo"
        FOREACH
           Select SKIP pRegIni FIRST 10   
		   concepto,sum(importe) AS importe, archivo
           Into sConcepto, mImporte, sArchivo
           From   "informix".bei_dispersiones_odp 
           Where  num_cliente = pNumCliente
           And    tipo_dispersion = pTipoDisp
           And    fecha = pFecha
           		   		   
		   Group by concepto, archivo 
           Order by archivo asc
		   
           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus WITH RESUME;
          END FOREACH;
		  
		  
     ELSE  --Entra al listado de orden por archivo individual
        FOREACH
           Select SKIP pRegIni FIRST 10   
		    a.alias, a.nombre_completo, a.concepto, a.importe, a.clave_envio, a.archivo, b.fecha_envio, b.estatus, b.fecha_pago, b.fecha_cance
            Into sAlias, sNombre, sConcepto, mImporte, sClave, sArchivo, vfenvio, vestatus, vfpago, vfcance
            From   "informix".bei_dispersiones_odp as a, bdisac:"informix".sac_enviosdineroya as b
            Where  a.num_cliente = pNumCliente
            And    a.tipo_dispersion = pTipoDisp
            And    a.fecha = pFecha
			And    a.clave_envio=b.no_control
			union
			select a.alias, a.nombre_completo, a.concepto, a.importe, a.clave_envio, a.archivo, b.fecha_envio, b.estatus, b.fecha_pago, b.fecha_cance 
            From   "informix".bei_dispersiones_odp  as a, bdisac:"informix".sac_enviosdineroyahis as b
            Where  a.num_cliente = pNumCliente
            And    a.tipo_dispersion = pTipoDisp
            And    a.fecha = pFecha
			And    a.clave_envio=b.no_control
			--*************************************************************************--
			--*************************************************************************--
					--Determinar la fecha segun el estatus------------------------
					IF vestatus='00' or vestatus='01' THEN --incompleto / Activo
					LET vfechaStatus=vfenvio;
				   
					ELIF vestatus='03'  THEN --Bloqueado
					LET vfechaStatus=vfenvio;
				   
					ELIF vestatus='04'  THEN --Pagadp
					LET vfechaStatus=vfpago;
				   
					ELIF vestatus='02' or vestatus='05' THEN --cancelado o reversado
					LET vfechaStatus=vfcance;
					END IF;
					--------------------------------------------------------------
			--*************************************************************************--
			--*************************************************************************--
			--necesitamos sacar el estatus y la fecha de dicho estatus

           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus WITH RESUME;
         END FOREACH;
     END IF;
     
    ELSE --tienen numero de archivo (opcion "VER detalle" del listado de dispersion de ordenes de pago por archivo)

     FOREACH
           Select SKIP pRegIni FIRST 10   
		    a.alias,a.nombre_completo,a.concepto,a.importe, a.clave_envio,a.archivo, b.fecha_envio, b.estatus, b.fecha_pago, b.fecha_cance
            Into sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vfenvio, vestatus, vfpago, vfcance
            From   "informix".bei_dispersiones_odp as a, bdisac:"informix".sac_enviosdineroya as b
            Where  num_cliente = pNumCliente
            And    tipo_dispersion = pTipoDisp
            And    fecha = pFecha
            And    archivo=pArchivo
			And    a.clave_envio=b.no_control
			union 
			Select a.alias,a.nombre_completo,a.concepto,a.importe, a.clave_envio,a.archivo, b.fecha_envio, b.estatus, b.fecha_pago, b.fecha_cance 
            From   "informix".bei_dispersiones_odp as a, bdisac:"informix".sac_enviosdineroyahis as b
            Where  num_cliente = pNumCliente
            And    tipo_dispersion = pTipoDisp
            And    fecha = pFecha
            And    archivo=pArchivo
			And    a.clave_envio=b.no_control
			
			--*************************************************************************--
			--*************************************************************************--
					--Determinar la fecha segun el estatus------------------------
					IF vestatus='00' or vestatus='01' THEN --incompleto / Activo
					LET vfechaStatus=vfenvio;
				   
					ELIF vestatus='03'  THEN --Bloqueado
					LET vfechaStatus=vfenvio;
				   
					ELIF vestatus='04'  THEN --Pagadp
					LET vfechaStatus=vfpago;
				   
					ELIF vestatus='02' or vestatus='05' THEN --cancelado o reversado
					LET vfechaStatus=vfcance;
					END IF;
					--------------------------------------------------------------
			--*************************************************************************--
			--*************************************************************************--

			
           return cod_ret, sAlias,sNombre, sConcepto,mImporte, sClave, sArchivo, vestatus, vfechaStatus WITH RESUME;
    END FOREACH;
	
END IF;

END
END PROCEDURE;