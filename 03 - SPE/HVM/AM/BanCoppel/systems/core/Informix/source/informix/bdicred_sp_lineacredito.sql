CREATE PROCEDURE "informix".sp_lineacredito(P_FECHA_IN	DATE,
      P_FECHA_FIN	DATE      
     ) RETURNING VARCHAR(6),VARCHAR(80);

	 
--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la búsqueda de tabla si_ingresos

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET             VARCHAR(6);
DEFINE  P_MENSAJE             VARCHAR(80);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
	DELETE FROM sd_lineacredito;
	
	INSERT INTO sd_lineacredito(numerocliente,nombrecliente,fechasolicitud,montooriginal,fechaincremento,montonuevo,ingresocomprobado)   
	SELECT si.numcte,TRIM(si.apell_paterno) || '  '  || TRIM(si.apell_materno) || '  '  || TRIM(si.nombre1) || '  '   || TRIM(si.nombre2),
		   ss.fecha_insert,ss.monto_solicitado,mv.fecha_mov,md.monto_otorgado,ig.ingreso_mensual
	FROM bdicred:sd_movhis mv ,
		 bdicred:sd_maecred ma,
		 bdinteg:si_cliente si,
		 bdicred:sd_maesdos md,
		 bdisolic:ss_solicitudes ss,
	     bdinteg:si_ingresos ig	     
	WHERE mv.codigo_fun = '008' 
	AND mv.fecha_mov >= P_FECHA_IN
	AND mv.fecha_mov <= P_FECHA_FIN 
	AND ma.num_credito = mv.num_credito 
	AND md.num_credito = mv.num_credito  
	AND ma.numcte = si.numcte 
	AND ss.num_solicitud = ma.num_credito
	AND ig.numcte = ma.numcte
	AND ig.tipo_ingreso = 'T'
	AND ig.sec_ingreso = (SELECT MAX(sec_ingreso) 
						  FROM bdinteg:si_ingresos a 
						  WHERE a.numcte=si.numcte 
						  AND a.tipo_ingreso = 'T');

   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;