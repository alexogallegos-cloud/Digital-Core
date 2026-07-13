CREATE PROCEDURE "informix".sp_recupera_estatussolic(pcel CHAR(10))
	RETURNING CHAR(5) AS codret, CHAR(160) AS estatus;
    
	DEFINE vsqlerr, vcant INTEGER;

    DEFINE vcodret 			CHAR(5);
	DEFINE vTermSolic 		CHAR(4);
	DEFINE vSolicitud 		CHAR(20);
	DEFINE vStatusSolic 	CHAR(50);
	DEFINE vNumProducto 	CHAR(4);
	DEFINE vNombProducto 	CHAR(80);
	DEFINE vcadena 			CHAR(500);

    LET vcodret    		= '00000';
	LET vTermSolic   	= '';
	LET vSolicitud   	= '';
	LET vStatusSolic 	= '';
	LET vNumProducto 	= '';
	LET vNombProducto 	= '';
	LET vcadena	   		= '';
	
    
    BEGIN

		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF LENGTH(pcel) <> 10 THEN
			LET vcodret = "00001";
			RETURN vcodret,'NUMERO TELEFONICO INVALIDO, VERIFIQUE.';
		END IF;


		----============================================================================================VALIDA NUMCTE=================
		SELECT {+INDEX(bdisolic:ss_solicitudes.idx_ss_solicitudes2)} 
				COUNT(DISTINCT(S.numcte)) INTO vcant
		FROM bdinteg:si_telefonos_actual T
			, bdisolic:ss_solicitudes S	
			, bdisolic:ss_status_sol E
			, bdicred:sd_definicion D
		WHERE telefono=pcel
			AND S.num_producto IN('6001','6300','6500','7600','7700')
			AND T.numcte=S.numcte 
			AND S.status_solicitud=E.status_solicitud
			AND S.num_producto=D.num_producto
			AND T.tipo_tel='2' 
			AND T.status_tel='A' 
			AND S.fecha_insert::date > today -90
			AND S.status_solicitud IN ('EA','RT','EE','AT','AN','PC','CC','OA','OS','RA','BC','CE','ST','CN','RP','CM','LC','MC','EC','PA');


		--SI HAY MAS DE UN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
		IF vcant > 1 THEN 
	        LET vcodret = "00002";
	        RETURN vcodret,'';

	    --SI NO HAY NINGUN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
	    ELIF vcant < 1 THEN 
	        LET vcodret = "00000";
	        RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UNA SOLICITUD DE CREDITO.';
	    END IF;
	    --=======================================================================================================================================
 
		
		FOREACH SELECT {+INDEX(bdisolic:ss_solicitudes.idx_ss_solicitudes2)} 
				DISTINCT(S.num_solicitud)
				, CASE
					WHEN E.status_solicitud='AT' 
					  OR E.status_solicitud='PA' THEN 'AUTORIZADA'
					WHEN E.status_solicitud='RT' 
					  OR E.status_solicitud='CN' 
					  OR E.status_solicitud='RP' 
					  OR E.status_solicitud='CM' THEN 'RECHAZADA'
					ELSE 'EN PROCESO'
				  END AS ESTATUS
				, S.num_producto
				, CASE 
					WHEN D.num_producto = '6001' 	THEN 'TDC BANCOPPEL' 
					WHEN D.num_producto = '6500' 	THEN 'CREDITO COPPEL' 
					WHEN D.num_producto = '6300' 
					  OR D.num_producto = '7600' 
					  OR D.num_producto = '7700' 	THEN 'PRESTAMO PERSONAL BANCOPPEL' 
					ELSE D.num_producto 
				END AS producto
			INTO vSolicitud, vStatusSolic, vNumProducto, vNombProducto
		FROM bdinteg:si_telefonos_actual T
			, bdisolic:ss_solicitudes S	
			, bdisolic:ss_status_sol E
			, bdicred:sd_definicion D
		WHERE telefono=pcel
			AND S.num_producto IN('6001' --Tarjeta de Credito Bancoppel VISA
								  --,'6011' --Reestructura
								  ,'6300' --Prestamo Personal Bancoppel
								  --,'6400' --Prestamo directo nÃ³mina
								  ,'6500' --Tarjeta de Credito COPPEL
								  --,'6600' --Tarjeta de Credito BÃ¡sica
								  ,'7600' --Prestamo Personal Bancoppel 18
								  ,'7700' --Prestamo Personal Bancoppel 24
								  --,'7800' --Anticipo de NÃ³mina
								  --,'8100' --Tarjeta de Credito Bancoppel ORO
									)
			AND T.numcte=S.numcte 
			AND S.status_solicitud=E.status_solicitud
			AND S.num_producto=D.num_producto
			AND T.tipo_tel='2' 
			AND T.status_tel='A' 
			AND S.fecha_insert::date > today -90
			AND S.status_solicitud IN ('EA' --En Analisis
									  ,'RT' --Rechazada
									  ,'EE' --En Estudio Supervision
									  ,'AT' --Autorizada
									  --,'AP' --Autorizacion de Apertura
									  ,'AN' --Anulada por el Cliente
									  ,'PC' --Solicitud Pre-Calificada
									  ,'CC' --En Circulo de Credito
									  ,'OA' --Orden Supervision en Aclaracion
									  ,'OS' --Enviada a Orden de Supervision
									  ,'RA' --REQUIERE AUTORIZACIÃ?N
									  ,'BC' --En Buro de Credito
									  ,'CE' --Catalogo de domicilio en estudio
									  ,'ST' --SupervisiÃ³n TelefÃ³nica
									  ,'CN' --Cancelada
									  ,'RP' --Rechazo por PrecalificaciÃ³n
									  ,'CM' --CancelaciÃ³n por Mesa de Control
									  ,'LC' --En DeterminaciÃ³n de LÃ­nea
									  ,'MC' --Mesa de Control
									  ,'EC' --Evaluacion Coppel
									  ,'PA' --Pre-Autorizada)
									  ) 
		GROUP BY 1,2,3,4
														
			LET vTermSolic = SUBSTR(TRIM(vSolicitud),9,4);

			LET vcadena = TRIM(vcadena) || " " || TRIM(vNombProducto) || ": " || UPPER(TRIM(vStatusSolic)) || ", ";
			
		END FOREACH;

					
		IF vcant = 1 THEN
			RETURN vcodret, 'EL ESTATUS DE SU SOLICITUD DE CREDITO ES,' || SUBSTR(SUBSTR(vcadena,1,LEN(vcadena) - 1),1,160);
		ELSE
			RETURN vcodret, 'EL ESTATUS DE SUS SOLICITUDES DE CREDITO ES, ' || SUBSTR(SUBSTR(vcadena,1,LEN(vcadena) - 1),1,160);
		END IF;

	END;
END PROCEDURE;