CREATE PROCEDURE "informix".sp_gen_rep_eficiencia_col_tdcoro(pEmpresa char(3))
returning 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
--************************ Definicion de variables *****************************
    DEFINE iSql_err                  integer;
    DEFINE cSql                      char(2080);
    DEFINE cNumCte                   char(20);
    DEFINE cNum_Solicitud              char(20);
    DEFINE cNum_Producto  char(4);          
    DEFINE dFecha_Solicitud           date;     
    DEFINE dfecha_hoy                date;
    DEFINE cMensajeRet               char(80);
    DEFINE cCodRet        char(6); 
    DEFINE cNum_dia                  char(02);
    DEFINE cNum_mes                  char(02);
    DEFINE cNum_anio        char(04);
	DEFINE cStatus_Solicitud   CHAR(2);
	-- RQM 10 679 - 2 ADENDUM 
	DEFINE dLineaOtorgada			decimal(18,2);
	DEFINE cNombreArchivo_ant  VARCHAR(150);
	DEFINE cNombreArchivo  	VARCHAR(150);
	DEFINE cEncabezado		CHAR(2500);	
	DEFINE v_sepa               		CHAR(2);
	
     
    LET iSql_err = 0;
    LET cSql    = '';
    LET cNumCte = '';
    LET cNum_Solicitud= '';
    LET cStatus_Solicitud	= '';
    LET dFecha_Solicitud = DATE(1);
    LET dFecha_hoy = DATE(1);
    LET cMensajeRet= 'El reporte de EFICIENCIA TDC ORO se realizo correctamente';
    LET cCodRet    = '000000';
    LET cNum_Producto = '';
    LET cNum_dia   ='';
    LET cNum_mes  ='';
    LET cNum_anio  = '';	

	-- RQM 10 679 - 2 ADENDUM 
	LET dLineaOtorgada		= 0.00;
	LET cNombreArchivo_ant = '';
	LET cNombreArchivo  = '';
	LET cEncabezado		= '';	
	LET v_sepa                 		= '\|';
	
--**************************** Control de errores ******************************
    begin
    on exception set iSql_err
		if iSql_err <> 0 then
           let cCodRet= iSql_err;
           let cMensajeRet= 'ERROR en la ejecucion del reporte de ColocaciÃ³n de Eficiencia TDC Oro' || cNum_Solicitud;

           RETURN cCodRet,cMensajeRet;
		END IF;
	END EXCEPTION;


 --SET DEBUG FILE TO "/tmp/sp_gen_rep_eficiencia_col_tdcoro.out";
 --TRACE ON;


--*************************** Programa principal *******************************
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    SELECT fecha_hoy INTO dFecha_hoy FROM bdicred:sd_fechas WHERE empresa = pEmpresa;

--temporal para pruebas
   --let dFecha_hoy = mdy('11','01','2018');
--temporal para pruebas

	LET cNum_dia  = lpad(DAY(dFecha_hoy),2,'0');
    LET cNum_mes  = lpad(MONTH(dFecha_hoy),2,'0');
    LET cNum_anio = lpad(YEAR(dFecha_hoy),4,'0');
	
	LET cNombreArchivo_ant = 'TDC_BanCoppel.txt' ;
	LET cNombreArchivo = 'TDC_BanCoppel_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ;

  	LET cEncabezado = 'echo Fecha solicitud'||v_sepa||'Numero solicitud'||v_sepa||'Numero cliente'||v_sepa||'ID producto'||v_sepa||'Status'||v_sepa||'Linea Otorgada' ||' > /resplogifx/archivoscartera/' || TRIM(cNombreArchivo);	
	SYSTEM cEncabezado;
	
--Reporte de eficiencia de colocaciÃ³n de tdc oro
    LET cSql = 'echo " unload to '''|| '/resplogifx/archivoscartera/'||TRIM(cNombreArchivo_ant) || ''''||" delimiter '|' "||
	   ' select fecha_insert, num_solicitud, numcte, num_producto, status_solicitud, monto_autorizado ' ||
       ' from bdisolic:"informix".ss_solicitudes WHERE empresa = '''|| pempresa  || ''' AND num_producto = "8100"'||
       ' " > /resplogifx/archivoscartera/query_rep_eficiencia.sql';
    system cSql;
    LET cSql='';
    LET cSql = 'dbaccess bdisolic /resplogifx/archivoscartera/query_rep_eficiencia.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_rep_eficiencia.sql';
    SYSTEM cSql;

	LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/"||TRIM(cNombreArchivo_ant)||" >> /resplogifx/archivoscartera/"||TRIM(cNombreArchivo);  
	SYSTEM cSql;

	LET cSql = '';	
	LET cSql = 'rm /resplogifx/archivoscartera/'||TRIM(cNombreArchivo_ant);
    SYSTEM cSql;
	
	RETURN cCodRet,cMensajeRet;
END;
END PROCEDURE
