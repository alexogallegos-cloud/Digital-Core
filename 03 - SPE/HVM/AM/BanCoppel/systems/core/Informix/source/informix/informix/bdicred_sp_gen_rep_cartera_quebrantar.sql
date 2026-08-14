CREATE PROCEDURE "informix".sp_gen_rep_cartera_quebrantar(pEmpresa char(3))
returning char (6);

DEFINE SQL_ERR         INTEGER;
DEFINE ISAM_ERR        INTEGER;
DEFINE ERROR_INFO  	   VARCHAR(80);
DEFINE P_COD_RET       VARCHAR(6);
DEFINE P_MENSAJE       VARCHAR(80);
DEFINE cSql            CHAR(2034);
DEFINE cNombreArchivo1 CHAR(600);
DEFINE cNombreArchivo2 CHAR(600);
DEFINE cNombreArchivo3 CHAR(600);
DEFINE cNombreArchivo4 CHAR(600);
DEFINE cNombreArchivo5 CHAR(600);
DEFINE var_rga         CHAR(05);
DEFINE dFechaHoy	   DATE;
DEFINE dFechaAnt 	   DATE;



--Set debug file to '/RESPALDOSNEW/reportes_cartera/PRUEBAS_PEDRO/sps/sp_gen_rep_cartera_quebrantar.out';
--trace on;

LET cSql 	= "";
LET var_rga	= '';
LET dFechaHoy = DATE(1);
LET dFechaAnt = DATE(1);


BEGIN
   
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        RETURN P_COD_RET;
    END EXCEPTION;
	
	set isolation to dirty read;
	set lock mode to wait 3;	

	SELECT Fecha_Hoy, fecha_ant
	  INTO dFechaHoy, dFechaAnt
	  FROM bdicred:sd_fechas
	WHERE empresa = '001';
	 
	--LET dFechaHoy = mdy('02','04','2022');
	--LET dFechaAnt = MDY('02','03','2022');
	 

	LET  cNombreArchivo1 = '/pisa/CarteraQuebrantadaPrevio' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';
	LET  cNombreArchivo2 = '/pisa/CifrasCarteraQuebrantadaPrevio' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';
	LET  cNombreArchivo3 = '/pisa/CifrasCarteraQuebrantadaOperPrevio' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';
	LET  cNombreArchivo4 = '/pisa/CarteraQuebrantadaCreditoPrevio' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';



-- para Generar el archivo de Salida de Cartera Quebrantada.

              let cSql = "";
              let cSql = ' UNLOAD TO ' || '''/pisa/CarteraQuebrantadaRegistros.unl''' || ' DELIMITER ' || '''"|"''';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  ' SELECT ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Num_Credito,' || '''" "''' || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCte,' || '''" "''' || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a. Apellido1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Apellido2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nombre1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nombre2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.FechaNac,date"("1")"")", ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Rfc,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Curp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sexo,' || '''" "''' || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EdoCivil,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ApellidoCasada,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nacionalidad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Actividad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.TipoIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Email,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumEstado,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCiudad,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Poblacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumColonia,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCalle,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumExterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumInterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.CodPostal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PuntoCardinal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Manzana,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Andador,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Etapa,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Lote,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Edificio,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Entrada,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Departamento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Complemento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EntreCalles,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.AntigDomic,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Telefono,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Otros,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.SituacionEsp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.CausaSitEsp,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Sector,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.LugarTrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.AntigTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Puesto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.IngresoMensual,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumEstadoTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCiudadTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PoblacionTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumColoniaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCalleTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumExteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumInteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.CodPostalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PuntoCardinalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.ManzanaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.AndadorTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EtapaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.LoteTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EdificioTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EntradaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.DepartamentoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ComplementoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EntreCallesTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.OtrosTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.TelTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ExtTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.sucursal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Fecha_Ult_Disp,date"("1")"")", ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Ult_Disp,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Comi_Ult_Disp,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Abono_Mensual_Al_Qub,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Capit,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Capit,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Mes_Ant,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Actual,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Vencido,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Fecha_Ult_Mov,date"("1")"")", ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Tipo_Ult_Mov,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Ult_Mov,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Vencido,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Vencido,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Mora_Ordi,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Mora_Ordi,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Mora_Cope,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Mora_Cope,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.meses_vencidos,0")", ';              
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Numero_Tarjeta,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ReferenciaCoppel,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '"),"';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("replace"("replace"("a.Producto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '"),"';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("replace"("replace"("a.grupo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '"),"';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
--IPCB RQM 09 484		SE QUITO POR EL MOMENTO ESTE REQUERIMEINTO	  
              --let cSql =  '  nvl"("replace"("replace"("a.cte_conflicto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '"),"';
              --call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              --let cSql =  '  nvl"("a.fecha_ult_pago,date"("1")"")", ' ;
              --call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
--IPCB RQM 09 484	
		      
--pruebas pedro Campos Faltantes RQM 04 127
				
			  let cSql =  '  nvl"("a.ban_envio_mc,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.ban_atendio_mc,0")," ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  
			  let cSql =  '  nvl"("a.Sdo_no_exig,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Vencido_bal,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Vencido_bal,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.fechaReporte,date"("1")"")", ' ;    
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.fechaapertura,date"("1")"")", ' ;   
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Telefono,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",'; 
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.situacionpago,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.meseshistoria,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;			  
			  let cSql =  '  nvl"("replace"("replace"("a.evaluacc,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.monto_otorgado,0")" ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
--***********************************************************************************************************
			  
              --let cSql =' FROM bdicobranza:cb_rep_cart_quebrantar a where a.fechareporte = date"("current")" ';
			  let cSql =' FROM bdicobranza:cb_rep_cart_quebrantar a where a.fechareporte = ' || '''"''' || dFechaHoy || '''"''';
			  
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =' order by a.Num_Credito '||''';''';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /pisa/CarteraQuebrantadaQuerys.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' /pisa/CarteraQuebrantadaRegistros.unl > " || cNombreArchivo1;
              SYSTEM cSql;

              LET cSql = '';

-- para Generar el archivo de Salida de Cartera Quebrantada Credito. 

              let cSql = "";
              let cSql = ' UNLOAD TO ' || '''/pisa/CarteraQuebrantadaRegistros2.unl''' || ' DELIMITER ' || '''"|"''';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  ' SELECT ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Num_Credito,' || '''" "''' || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCte,' || '''" "''' || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a. Apellido1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Apellido2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nombre1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nombre2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.FechaNac,date"("1")"")", ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Rfc,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Curp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sexo,' || '''" "''' || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EdoCivil,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ApellidoCasada,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nacionalidad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Actividad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';

              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.TipoIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Email,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumEstado,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCiudad,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Poblacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumColonia,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCalle,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumExterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumInterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.CodPostal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PuntoCardinal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Manzana,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Andador,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Etapa,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Lote,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Edificio,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Entrada,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Departamento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Complemento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EntreCalles,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.AntigDomic,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Telefono,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Otros,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.SituacionEsp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.CausaSitEsp,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Sector,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.LugarTrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.AntigTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Puesto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.IngresoMensual,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumEstadoTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCiudadTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PoblacionTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumColoniaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCalleTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumExteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumInteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.CodPostalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PuntoCardinalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.ManzanaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.AndadorTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EtapaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.LoteTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EdificioTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EntradaTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.DepartamentoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ComplementoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EntreCallesTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.OtrosTrab,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.TelTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ExtTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.sucursal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Fecha_Ult_Disp,date"("1")"")", ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Ult_Disp,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Comi_Ult_Disp,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Abono_Mensual_Al_Qub,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Capit,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Capit,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Mes_Ant,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Actual,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Vencido,0")", ';
			  ------------------------------------------------------------------ 	sdfm	
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.sdo_no_exig,0")", ';
			  ------------------------------------------------------------------ 	sdfm				  
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Fecha_Ult_Mov,date"("1")"")", ' ;
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Tipo_Ult_Mov,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Ult_Mov,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Vencido,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Vencido,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Vencido_bal,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Vencido_bal,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Mora_Ordi,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Mora_Ordi,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Mora_Cope,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Mora_Cope,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.meses_vencidos,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.dias_vencido,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.atr,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.act,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("to_char"("a.fecha_vencido,''"''' || '%d/%m/%Y' || '''"''")",date"("1")"")", ' ;              
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Numero_Tarjeta,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ReferenciaCoppel,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '"),"';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
	          ------------------------------------------------------------------ 	sdfm	
			  let cSql =  '  nvl"("a.fechareporte,date"("1")"")", ' ;
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.fechaapertura,date"("1")"")", ' ;
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;		
              let cSql =  '  nvl"("replace"("replace"("a.telefonocel,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.situacionpago,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;			  
			  let cSql =  '  nvl"("a.meseshistoria,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.evaluacc,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.monto_otorgado,0")", ';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  ------------------------------------------------------------------- 	sdfm 		
			  let cSql =  '  nvl"("replace"("replace"("a.Producto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("replace"("replace"("a.grupo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.ban_envio_mc,0")", ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("a.ban_atendio_mc,0")" ';
			  call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  --let cSql =' FROM bdicobranza:cb_rep_cart_quebrantar a where a.fechareporte = date"("current")" ';
			  let cSql =' FROM bdicobranza:cb_rep_cart_quebrantar a where a.fechareporte = ' || '''"''' || dFechaHoy || '''"'''; 
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;
			  let cSql =' order by a.Num_Credito '||''';''';
              call sp_genera_archivo ('/pisa/CarteraQuebrantadaQuerys2.sql',cSql) returning var_rga;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /pisa/CarteraQuebrantadaQuerys2.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' /pisa/CarteraQuebrantadaRegistros2.unl > " || cNombreArchivo4 ;
              SYSTEM cSql;

              LET cSql = '';
           
-- cifras de control Sistemas Cartera
              LET cSql = 'echo "UNLOAD TO ' || '''/pisa/CarteraQuebrantadaCifras.unl''' || ' DELIMITER ' || '''|'''  ||
                                ' SELECT ' ||
								' sum(a.Totalregistros)::INTEGER, ' ||
                                ' sum(a.Saldoactual_total), ' ||
                                ' a.fechareporte ' ||
                                --' FROM bdicobranza:cb_rep_cart_quebrantar_cifras a where a.fechareporte = date(current) ' ||
								' FROM bdicobranza:cb_rep_cart_quebrantar_cifras a where a.fechareporte = ' || '''"''' || dFechaHoy || '''"''' ||
                                ' group by a.fechareporte ' ||
                                ' " > /pisa/CarteraQuebrantadaQuerys_Cifras.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /pisa/CarteraQuebrantadaQuerys_Cifras.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' /pisa/CarteraQuebrantadaCifras.unl > " || cNombreArchivo2;
              SYSTEM cSql;

              LET cSql = '';
              LET cSQL = 'rm /pisa/CarteraQuebrantadaRegistros.unl /pisa/CarteraQuebrantadaRegistros2.unl /pisa/CarteraQuebrantadaQuerys_Cifras.sql /pisa/CarteraQuebrantadaQuerys.sql /pisa/CarteraQuebrantadaQuerys2.sql /pisa/CarteraQuebrantadaCifras.unl';
              SYSTEM cSql;
            -- cifras de control Operaciones
              LET cSql = 'echo "UNLOAD TO ' || '''/pisa/CarteraQuebrantadaCifras_Oper.unl''' || ' DELIMITER ' || '''|'''  ||
                                ' SELECT ' ||
								' a.num_producto, ' ||
								' a.Totalregistros, ' ||
                                ' a.Saldoactual_total, ' ||
                                ' a.fechareporte ' ||
                                --' FROM bdicobranza:cb_rep_cart_quebrantar_cifras a where a.fechareporte = date(current) ' ||
								' FROM bdicobranza:cb_rep_cart_quebrantar_cifras a where a.fechareporte = ' || '''"''' || dFechaHoy || '''"''' ||
                                '" > /pisa/CarteraQuebrantadaQuerys_Cifras_Oper.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /pisa/CarteraQuebrantadaQuerys_Cifras_Oper.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' /pisa/CarteraQuebrantadaCifras_Oper.unl > " || cNombreArchivo3;
              SYSTEM cSql;

              LET cSql = '';

              LET cSQL = 'rm /pisa/CarteraQuebrantadaQuerys_Cifras_Oper.sql /pisa/CarteraQuebrantadaCifras_Oper.unl';
              SYSTEM cSql;

              LET cSql = '';
			  LET cSql = "cp " || trim(cNombreArchivo1) || " /resplogifx/archivoscartera/respaldo/";
              SYSTEM cSql;

              LET cSql = '';
			  LET cSql = "cp " || trim(cNombreArchivo2) || " /resplogifx/archivoscartera/respaldo/";
              SYSTEM cSql;

              LET cSql = '';
			  LET cSql = "cp " || trim(cNombreArchivo3) || " /resplogifx/archivoscartera/respaldo/";
              SYSTEM cSql;

			  LET cSql = '';
			  LET cSql = "cp " || trim(cNombreArchivo4) || " /resplogifx/archivoscartera/respaldo/";
              SYSTEM cSql;
			
			  
    LET P_COD_RET = '000000';
    LET cSql = '';


    RETURN P_COD_RET;

END;

END PROCEDURE;