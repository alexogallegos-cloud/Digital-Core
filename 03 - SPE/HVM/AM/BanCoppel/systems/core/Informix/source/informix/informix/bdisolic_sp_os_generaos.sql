CREATE PROCEDURE "informix".sp_os_generaos()
RETURNING CHAR(5);


    DEFINE sNum_solicitud     CHAR (20);
    DEFINE dFecha_solicitud   DATE;
    DEFINE SQL_ERR            INTEGER;
    DEFINE ISAM_ERR           INTEGER;
    DEFINE ERROR_INFO         VARCHAR(80);
    DEFINE P_COD_RET          CHAR(5);
	DEFINE C_MENSAJE		  CHAR(80); 	
	DEFINE VPROCESO			  CHAR(10);	
    DEFINE vCodRet            CHAR(5);
	DEFINE vempresa			  CHAR(3);
    DEFINE iMaxFolio          INTEGER;
    DEFINE iMaxSecuencia      INTEGER;
    DEFINE iCuantos           INTEGER;
    DEFINE iNuevaSecuencia    INTEGER;
    DEFINE iMultiplo          INTEGER;
    DEFINE cNum_solicitudCoppel     CHAR (20);
	DEFINE cNum_solicitudBanco     CHAR (20);
	
	DEFINE dFecha_Hoy   DATE;
	DEFINE dFecha_SesentaDias   DATE;
	DEFINE dFecha_SinNueveDias   DATE;
    
	DEFINE V_NumSolicitud 				LIKE bdisolic:"informix".ss_osclientesupervisar.Num_Solicitud;
	DEFINE V_FechaSolicitud 			LIKE bdisolic:"informix".ss_osclientesupervisar.FechaSolicitud;
	DEFINE V_tiendafolio 				LIKE bdisolic:"informix".ss_osclientesupervisar.tiendafolio;
	DEFINE V_nombre1 					LIKE bdisolic:"informix".ss_osclientesupervisar.nombre1;
	DEFINE V_nombre2 					LIKE bdisolic:"informix".ss_osclientesupervisar.nombre2;
	DEFINE V_apellidopaterno 			LIKE bdisolic:"informix".ss_osclientesupervisar.apellidopaterno;
	DEFINE V_apellidomaterno 			LIKE bdisolic:"informix".ss_osclientesupervisar.apellidomaterno;
	DEFINE V_personasvivenendomicilio 	LIKE bdisolic:"informix".ss_osclientesupervisar.personasvivenendomicilio;
	DEFINE V_fechaaltacliente 			LIKE bdisolic:"informix".ss_osclientesupervisar.fechaaltacliente;
	DEFINE dtFechaHora 					DATE;
	DEFINE SQL_ERR_2					INTEGER;
	DEFINE P_MENSAJE_2					VARCHAR(80);
	
--    SET debug file to '/informix/Israel/sp_os_GeneraOs.out';
--    trace on;

    --Modificacion: 09-08-2007(dd-mm-aaaa)
    --inicializar el secuencial a un multiplo de 10000, por unica vez.
    --Va relacionado con cambio en sp_os_integracion, para usar la secuencia como folio, en lugar del numero de cliente.
	
	--Modificacion: Enrique Lizarraga Lugo 20-10-2010
	--Se agrega validacion despuues de la ejecucion de sp_os_integracion para cambiar status de solicitud de acuerdo al codigo de error regresado por dicho SP.
	
	--Modificacion: Enrique Lizarraga Lugo 05-01-2011
	--Se modIFica el proceso para insercion en bitacora y evitar sequential scans.
	
	--Modificacion:	10/Jun/2011
	--Modifico:		Jesus Manuel Aguilar Heredia
	--Cambio:		Se realiza homologacion del proceso productivo con la version para contemplar el producto coppel.
	
	--Modificacion:	01/Feb/2023
	--Modifico:		Veronica Rodriguez 
	--Cambio:		Se modifica sp para realizar filtrado por fechas.
	--Etiqueta: VZRI

	LET vCodRet = '00000';
	LET P_COD_RET = '00000';
	LET C_MENSAJE = '';
	LET VPROCESO = '1005';
	LET vempresa = '001';
	
    LET SQL_ERR = 0;
    LET ISAM_ERR = '';
    LET ERROR_INFO = '';
	
	LET sNum_solicitud     = '';
    LET dFecha_solicitud   = DATE(1);
   
    LET iMaxFolio       = 0;
    LET iMaxSecuencia   = 0;
    LET iCuantos        = 0;
    LET iNuevaSecuencia = 0;
	LET cNum_solicitudCoppel     = '';
	LET cNum_solicitudBanco     = '';
 
	LET V_NumSolicitud 				='';
	LET V_FechaSolicitud 			=DATE(1);
	LET V_tiendafolio 				=0;
	LET V_nombre1 					='';
	LET V_nombre2 					='';
	LET V_apellidopaterno 			='';
	LET V_apellidomaterno 			='';
	LET V_personasvivenendomicilio 	=0;
	LET V_fechaaltacliente 			=DATE(1);
	LET dtFechaHora 				=DATE(1);
	LET SQL_ERR_2					=0;
	LET P_MENSAJE_2					='';
	
    BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
           LET P_COD_RET = SQL_ERR;
	       LET C_MENSAJE = ERROR_INFO;
           CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, VPROCESO, P_COD_RET, C_MENSAJE, '02');
		RETURN P_COD_RET;         
        END EXCEPTION;
		
		CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, VPROCESO, P_COD_RET, C_MENSAJE, '01');
		
         LET iMultiplo = 10000;
        
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		
		SELECT MAX(secuencia) AS foliomax, MAX(secuencia) AS secuenciamax, COUNT(*)
        INTO iMaxFolio, iMaxSecuencia, iCuantos
        FROM "informix".ss_osclientesupervisar;		
		
        IF iCuantos = iMaxSecuencia THEN  --Significa que hasta ahora, la secuencia esta en su forma original, un consecutivo, que coincide con el total de registros.
		--Considerar el maximo numero de cliente ya usado como folio, para calcular el nuevo secuencial.
            LET iNuevaSecuencia = (((iMaxFolio - MOD(iMaxFolio,iMultiplo))/iMultiplo)+1) * iMultiplo ;

            IF (iNuevaSecuencia - iMaxFolio) <= 1000 THEN  --que haya minimo 1000(mil) numeros de dIFerencia entre el nuevo consecutivo y el maximo folio ya usado.
				LET iNuevaSecuencia = iNuevaSecuencia + iMultiplo;
			END IF;

		BEGIN WORK;
            UPDATE "informix".ss_ossecuencia SET secuencia = iNuevaSecuencia - 1;
            --como la nueva os suma 1 al consecutivo, tomara el multiplo de 10000 sigte
		COMMIT WORK;

        END IF;
		-- SE EJECUTARA EL sp_os_integracion SOLO UNA VEZ POR CLIENTE EN VEZ DE POR CADA SOLICITUD
        FOREACH WITH HOLD		
      	
			SELECT  MAX( CASE WHEN b.tipo_solicitud = "C" THEN b.num_solicitud ELSE "" END),
					MAX (CASE WHEN b.tipo_solicitud <> "C" THEN b.num_solicitud ELSE "" END)
				INTO cNum_solicitudCoppel,cNum_solicitudBanco 
			FROM "informix".ss_solicitud_os a, "informix".ss_solicitudes b
				WHERE b.status_solicitud NOT IN ('CN','CM','RT','AP','AT','PC','AN')
				AND status = 'S'				
				AND b.empresa = vempresa
				AND a.num_solicitud =b.num_solicitud							
			GROUP BY numcte					
			UNION
			SELECT a.num_solicitud,''
				FROM "informix".ss_solicitudes a
				left join ss_nuevo_parametrico c on (c.empresa = a.empresa and a.num_solicitud =c.num_solicitud)
				left join ss_solicitud_os d on (a.num_solicitud =d.num_solicitud)
					WHERE a.status_solicitud  IN ('AT','AP') 
					AND a.num_producto = '6500'
					AND a.fecha_insert >= today -1					
					and c.status_solicitud = 'A' 
					AND c.flag_altadirecta_asupervisar = 1 
					AND d.status = 'S'	
					AND a.empresa = vempresa
				
				
			--- Valida que se envien a OS solo estatus validos.
			IF EXISTS (select num_solicitud from bdisolic:"informix".ss_solicitudes 
						where num_solicitud <> '' and num_solicitud = cNum_solicitudBanco and status_solicitud NOT IN ('EE','CE')) THEN
				CONTINUE FOREACH;
			END IF;
			IF  EXISTS (select num_solicitud from bdisolic:"informix".ss_solicitudes 
						where num_solicitud <> '' and num_solicitud = cNum_solicitudCoppel 
						and cNum_solicitudBanco = '' and status_solicitud NOT IN ('EE','CE','AT','AP')) THEN
				CONTINUE FOREACH;
			END IF;
			
			IF NVL(cNum_solicitudBanco,"") <> "" THEN
				LET sNum_solicitud = cNum_solicitudBanco;
			ELSE
				LET sNum_solicitud = cNum_solicitudCoppel;
			END IF;	
			  
				SELECT a.fecha_solicitud
				INTO dFecha_solicitud
				FROM "informix".ss_solicitud_os a, "informix".ss_solicitudes b
				WHERE a.num_solicitud = b.num_solicitud
				AND status = 'S' AND a.num_solicitud = sNum_solicitud;
			
				EXECUTE PROCEDURE  "informix".sp_os_integracion(sNum_solicitud, dFecha_solicitud)  INTO vCodRet;
				IF vCodRet IN ('00002' , '00012' , '00013', '00014' , '00015') THEN
					BEGIN WORK;
					UPDATE "informix".ss_solicitud_os SET status = 'P' WHERE empresa = '001' AND fecha_solicitud = dFecha_solicitud AND num_solicitud = cNum_solicitudBanco;
					UPDATE "informix".ss_solicitud_os SET status = 'P' WHERE empresa = '001' AND fecha_solicitud = dFecha_solicitud AND num_solicitud = cNum_solicitudCoppel;
					COMMIT WORK;
				END IF
		END FOREACH;
		
        CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, VPROCESO, vCodRet, C_MENSAJE, '02');
		--SE EJECUTA NUEVO PROCESO DE GENERACION DE OS PARA PROSPECTOS EN PBA PILOTO SIN AFECTAR FLUJO PRODUCTIVO
		IF (SELECT COUNT(numcte_pros)FROM bdiprospectos:"informix".pr_cliente WHERE empresa = vempresa AND status_numcte_pros in ('EE','CE')) > 0 THEN	
		--VZRI, Se agrega filtro para que traiga las solicitudes de al dia actual, la de 60 dias atras y 59.
			LET dFecha_Hoy = today;
			--LET dFecha_SesentaDias = today - 60;
			--LET dFecha_SinNueveDias = today - 59;
			
			FOREACH WITH HOLD

				SELECT numcte_pros, fecha_insert, sucursal, TRIM(NVL(nombre1,'')), TRIM(NVL(nombre2,'')), TRIM(NVL(apell_paterno,'')), TRIM(NVL(apell_materno,'')),
						string2 as PersonasViven, fecha_alta,fecha_hora
				INTO V_NumSolicitud, V_FechaSolicitud , V_tiendafolio,V_nombre1, V_nombre2, V_apellidopaterno, V_apellidomaterno,V_personasvivenendomicilio,
						V_fechaaltacliente,dtFechaHora
				FROM bdiprospectos:"informix".pr_cliente
				WHERE tipo_cliente = 3 
				AND status_numcte_pros in ('EE','CE')
				AND fecha_insert = dFecha_Hoy
				--AND fecha_insert IN (dFecha_Hoy,dFecha_SesentaDias,dFecha_SinNueveDias) --VZRI
							
				CALL sp_os_generaos_prospecto_piloto (V_NumSolicitud, V_FechaSolicitud , V_tiendafolio,V_nombre1, V_nombre2, V_apellidopaterno, V_apellidomaterno,V_personasvivenendomicilio,V_fechaaltacliente,dtFechaHora,vempresa)
				RETURNING SQL_ERR_2,P_MENSAJE_2;

				IF SQL_ERR_2 <> "00000" THEN
					BEGIN;
					INSERT INTO bdisolic:"informix".ss_os_errores(num_solicitud, fechasolicitud, Codigo_Error, descripcion_error, FechaProceso )
					VALUES(V_NumSolicitud, V_FechaSolicitud, SQL_ERR_2, P_MENSAJE_2, CURRENT);
					COMMIT;
					CONTINUE FOREACH;
				END IF;
			
			END FOREACH;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, VPROCESO, vCodRet, C_MENSAJE, '02');
		END IF;	
		EXECUTE PROCEDURE "informix".sp_os_generaos_prospecto(vempresa) into vCodRet , C_MENSAJE;
		CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, VPROCESO, vCodRet, C_MENSAJE, '03');

	  RETURN P_COD_RET;

    END;
END PROCEDURE;