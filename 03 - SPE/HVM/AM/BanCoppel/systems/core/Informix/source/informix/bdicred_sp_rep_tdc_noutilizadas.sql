CREATE PROCEDURE "informix".sp_rep_tdc_noutilizadas(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cNomArchivo      CHAR(100);
DEFINE vsql             CHAR(2000);
DEFINE iNum_dia         SMALLINT;
DEFINE iNum_mes         SMALLINT;
DEFINE iNum_anio        SMALLINT;
DEFINE cNom_mes         CHAR(10);
DEFINE dFecha           DATE;
DEFINE dFechaProc       DATE;
DEFINE cNumCredito     CHAR(20); 
DEFINE cNumCte         CHAR(20);
DEFINE cApellPaterno   CHAR(26);
DEFINE cApellMaterno   CHAR(26);
DEFINE cNombre1        CHAR(26);
DEFINE cNombre2        CHAR(26);
DEFINE cSexo           CHAR(10);
DEFINE cTelefono1      CHAR(13);
DEFINE cTelefono2      CHAR(13);
DEFINE cTelefono3      CHAR(13);
DEFINE cExtension      CHAR(05);
DEFINE sTDC90SinUtilizar SMALLINT;
DEFINE sTDCNunca         SMALLINT;
DEFINE dFechaMov       DATE;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= 'ERROR en la ejecución del reporte de TDC NO UTILIZADAS ';
      RETURN cCodRet, cMensajeRet;
   END IF;

END EXCEPTION;

--SET DEBUG FILE TO "sp_Rep_TDC_noutilizadas.out";
--TRACE ON;
 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = '';
LET cCodRet         = '000000';
LET cMensajeRet     = 'El reporte de TDC NO UTILIZADAS se realizó correctamente';
LET iNum_dia        = 0;
LET iNum_mes        = 0;
LET iNum_anio       = 0;
LET cNom_mes        = '';    
LET dFecha          = DATE(0);     
LET dFechaProc      = DATE(0);     
LET cNomArchivo     = '';
LET vsql            = '';
LET cNumCredito     = ''; 
LET cNumCte         = '';
LET cApellPaterno   = '';
LET cApellMaterno   = '';
LET cNombre1        = '';
LET cNombre2        = '';
LET cSexo           = '';
LET cTelefono1      = '';
LET cTelefono2      = '';
LET cTelefono3      = '';
LET cExtension      = '';
LET sTDC90SinUtilizar = 0;
LET sTDCNunca       = 0;
LET dFechaMov       = '';

SELECT fecha_hoy,pri_dia_mes 
  INTO dFecha,dFechaProc
FROM sd_fechas;

LET iNum_dia  = day(dFecha);
LET iNum_mes  = month(dFecha);
LET iNum_anio = year(dFecha);

--La fecha se posiciona al último día del mes pasado (-1) y se restan 90 días adicionales para buscar créditos con 
--últimos movimientos de más de 90 días con respecto al último día del mes pasado
LET dFechaProc = dFechaProc - 1 - 90;

  IF iNum_mes = 1  THEN LET cNom_mes = 'Diciembre';   LET iNum_anio = year(dFecha) - 1; END IF;
  IF iNum_mes = 2  THEN LET cNom_mes = 'Enero';       END IF;
  IF iNum_mes = 3  THEN LET cNom_mes = 'Febrero';     END IF;
  IF iNum_mes = 4  THEN LET cNom_mes = 'Marzo';       END IF;
  IF iNum_mes = 5  THEN LET cNom_mes = 'Abril';       END IF;
  IF iNum_mes = 6  THEN LET cNom_mes = 'Mayo';        END IF;
  IF iNum_mes = 7  THEN LET cNom_mes = 'Junio';       END IF;
  IF iNum_mes = 8  THEN LET cNom_mes = 'Julio';       END IF;
  IF iNum_mes = 9  THEN LET cNom_mes = 'Agosto';      END IF;
  IF iNum_mes = 10 THEN LET cNom_mes = 'Septiembre';  END IF;
  IF iNum_mes = 11 THEN LET cNom_mes = 'Octubre';     END IF;
  IF iNum_mes = 12 THEN LET cNom_mes = 'Noviembre';   END IF;

  SET ISOLATION TO dirty READ;
  SET LOCK MODE TO WAIT 3;

  IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_nunca') THEN
     DROP TABLE temp_nunca;
  END IF;

-- TDC nunca o no utilizadas
  CREATE TABLE "informix".temp_nunca ( 
      num_credito    CHAR(20), 
      numcte         CHAR(20),
      sucursal       CHAR(04),
      fecha_apertura DATE,
      apell_paterno  CHAR(26),
      apell_materno  CHAR(26),
      nombre1        CHAR(26),
      nombre2        CHAR(26),
      sexo           CHAR(10),
      telefono1      CHAR(13),
      telefono2      CHAR(13),
      telefono3      CHAR(13),
      extension      CHAR(05),
      fecha_ult_movto DATE,
      tdc_noutilidas       SMALLINT,
      tdc_90dias_sinutil   SMALLINT
  );

  LET cNomArchivo = 'Rep_TDC_noutilizadas'||TRIM(cNom_mes)||iNum_anio||'.txt';

  INSERT INTO "informix".temp_nunca 
  SELECT mae.num_credito,mae.numcte,mae.sucursal,fecha_apertura,'','','','','','','','','','','',''
    FROM bdicred:sd_maecred mae,
         bdicred:sd_maesdos mas
   WHERE mae.empresa = '001'
     AND mae.empresa = mas.empresa
     AND mae.num_credito = mas.num_credito
     AND mae.status_cred <> 'CV'
     AND mas.sdo_cap_insoluto = 0; 
--into temp paso_nunca with no log;

  CREATE unique INDEX inxtemp_nunca ON "informix".temp_nunca(num_credito,tdc_noutilidas,tdc_90dias_sinutil);
  UPDATE STATISTICS MEDIUM FOR TABLE "informix".temp_nunca(num_credito);

FOREACH

  SELECT num_credito,numcte
    INTO cNumCredito,cNumCte
    FROM informix.temp_nunca

  SELECT cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,
    CASE WHEN ctf.sexo='M' THEN 'MASCULINO' ELSE
    CASE WHEN ctf.sexo='F' THEN 'FEMENINO' END END
    INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2,cSexo
    FROM bdinteg:si_cliente cte
    JOIN bdinteg:si_ctepf ctf ON ctf.numcte = cte.numcte
   WHERE cte.numcte = cNumCte;
/*
  SELECT dir.telefono1,dir.telefono2,dir.telefono3,dir.extension
    INTO cTelefono1,cTelefono2,cTelefono3,cExtension
    FROM bdinteg:si_direcciones dir
   WHERE dir.numcte = cNumCte
     AND dir.secuencia = (select max(secuencia) from bdinteg:si_direcciones where numcte = dir.numcte and tipo_dir = '1');
*/
	select  telefono
		into  cTelefono1 
	from bdinteg:si_telefonos_actual 
	where numcte = cNumCte 
		and tipo_tel = 1 and cofetel ='V'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 1 and cofetel ='V');
	select  telefono
		into  cTelefono2
	from bdinteg:si_telefonos_actual 
	where numcte = cNumCte 
		and tipo_tel = 2 and cofetel ='V'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 2 and cofetel ='V');
	select  telefono,extension
		into  cTelefono3,cExtension
	from bdinteg:si_telefonos_actual 
	where numcte = cNumCte 
		and tipo_tel = 3 and cofetel ='V'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 3 and cofetel ='V');
-- Selecciona TDC nunca
  select count(*) 
  into sTDCNunca
  from bdicred:sd_movhis where empresa = '001' 
  and num_credito = cNumCredito and codigo_fun <> '001' and folio_suc not in ('CalifCartReserva','CalifCart');

  if sTDCNunca is null or sTDCNunca = 0 then 
     let sTDCNunca = 1; 
  else 
-- Selecciona TDC con mas de 90 dias sin movimiento
     select max(fecha_mov) 
     into dFechaMov
     from bdicred:sd_movhis where empresa='001' and num_credito = cNumCredito 
     and codigo_fun <> '001' and folio_suc not in ('CalifCartReserva','CalifCart');

     if dFechaMov is not null and dFechaMov < dFechaProc then 
        let sTDC90SinUtilizar =  1; 
     else 
        let sTDC90SinUtilizar = 0; 
     end if;
  end if;

  IF cNumCredito <> '' OR cNumCredito IS NOT NULL THEN
      UPDATE "informix".temp_nunca
         SET
          apell_paterno = cApellPaterno,
          apell_materno = cApellMaterno,
          nombre1       = cNombre1,
          nombre2       = cNombre2,
          sexo          = cSexo,
          telefono1     = cTelefono1,
          telefono2     = cTelefono2,
          telefono3     = cTelefono3,
          extension     = cExtension,
          fecha_ult_movto   = dFechaMov,
          tdc_noutilidas    = sTDCNunca,
          tdc_90dias_sinutil  = sTDC90SinUtilizar
       WHERE num_credito = cNumCredito;
   END IF;    

    LET sTDCNunca = 0;
    LET sTDC90SinUtilizar = 0;
    LET dFechaMov       = '';
END FOREACH

--  LET vsql = 'echo "UNLOAD TO ' || '''/pisa/leo/Rep_TDC_noutilizadas.unl''' || ' DELIMITER ' || '''|'''|| 
  LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Rep_TDC_noutilizadas.unl''' || ' DELIMITER ' || '''|'''|| 
             ' select num_credito,numcte,sucursal,fecha_apertura,apell_paterno,apell_materno,nombre1,nombre2,sexo,telefono1,telefono2,telefono3,extension,fecha_ult_movto '||
             ' from temp_nunca a where tdc_noutilidas = 1 or tdc_90dias_sinutil = 1'|| 
--             ' " > /pisa/leo/Rep_TDC_noutilizadas.sql';
             ' " > /resplogifx/archivoscartera/Rep_TDC_noutilizadas.sql';
  SYSTEM vsql;

  LET vSql = '';
  LET vSql = 'dbaccess bdicred /resplogifx/archivoscartera/Rep_TDC_noutilizadas.sql';
--  LET vSql = 'dbaccess bdicred /pisa/leo/Rep_TDC_noutilizadas.sql';
  SYSTEM vSql;

  LET vsql = 'echo "CREDITO'|| '|'|| 'CLIENTE'|| '|'|| 'SUCURSAL'|| '|'|| 'FECHA APERTURA' || '|'|| 'APELLIDO PATERNO' || '|'|| 'APELLIDO MATERNO' || '|'|| 
             ' PRIMER NOMBRE'|| '|'|| 'SEGUNDO NOMBRE'|| '|'|| 'SEXO'|| '|'|| 'TEL. CASA' || '|'|| 'TEL. CELULAR' || '|'|| 'TEL. OFICINA' || '|'|| 'EXTENSION' || '|'|| 'FECHA ULT. MOVTO.' || 
             ' " > /resplogifx/archivoscartera/'|| cNomArchivo;
--             ' " > /pisa/leo/'|| cNomArchivo;
  SYSTEM vsql;

  LET vSql = "sed 's/|$//g' /resplogifx/archivoscartera/Rep_TDC_noutilizadas.unl >> /resplogifx/archivoscartera/" || cNomArchivo;
--  LET vSql = "sed 's/|$//g' /pisa/leo/Rep_TDC_noutilizadas.unl >> /pisa/leo/" || cNomArchivo;  
  SYSTEM vSql;
     
  LET vSql = '';
--  LET vSQL = 'rm /pisa/leo/Rep_TDC_noutilizadas.sql /pisa/leo/Rep_TDC_noutilizadas.unl';
  LET vSQL = 'rm /resplogifx/archivoscartera/Rep_TDC_noutilizadas.sql /resplogifx/archivoscartera/Rep_TDC_noutilizadas.unl';
  SYSTEM vSql;

--  DROP TABLE temp_nunca;

  LET cMensajeRet= 'El reporte de TDC NO UTILIZADAS se realizó correctamente';

  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;