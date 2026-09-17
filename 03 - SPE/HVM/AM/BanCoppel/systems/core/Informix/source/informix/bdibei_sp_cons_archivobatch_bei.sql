CREATE PROCEDURE "informix".sp_cons_archivobatch_bei(pIdEvaluacion INTEGER)
returning CHAR(5), INTEGER, char(10), char(17), char(10), INTEGER,MONEY, char(10),char(20),INTEGER,INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Consulta los archivos de dispersión en proceso batch
-- AUTOR : SOLSER 
-- FECHA : 08/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel - Cordinacion Internet - G3
-- FECHA DE LIBERACIÓN: 
--***************************************************************************************************

    DEFINE cod_ret      char(5);
    DEFINE sql_err      integer ;
	DEFINE iId_evaluacion   	INTEGER;
    DEFINE vConcepto        	char(10);
    DEFINE vArchivo             char(17);
    DEFINE vhora_alta           char(10);
	DEFINE iCant_empleados  	INTEGER;
	DEFINE mImporte         	MONEY;
	DEFINE vFecha_aplicacion	char(10);
	DEFINE vCta_origen      	char(20);
    DEFINE iNumCtasO            INTEGER;
    DEFINE iNumCtasB            INTEGER;

    LET cod_ret     = "00000";
    LET iId_evaluacion = 0;
    LET vFecha_aplicacion  = '';
    LET vCta_origen ='';
    LET iCant_empleados=0;
    LET vConcepto='';
    LET mImporte=0;
    LET vArchivo = '';
    LET vhora_alta='';
    LET iNumCtasO = 0;
    LET iNumCtasB = 0;
	 
 BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        let cod_ret = sql_err;
        RETURN cod_ret, NVL(iId_evaluacion,0),NVL(vConcepto,''), NVL(vArchivo,''),NVL(vhora_alta,''),NVL(iCant_empleados,0), NVL(mImporte,0), NVL(vFecha_aplicacion,''),NVL(vCta_origen,''),NVL(iNumCtasB,0),NVL(iNumCtasO,0);
      END IF ;
   END EXCEPTION ;


	IF NVL(pIdEvaluacion,0) == 0 THEN
        LET cod_ret = '001'; 
        RETURN cod_ret, NVL(iId_evaluacion,0),NVL(vConcepto,''), NVL(vArchivo,''),NVL(vhora_alta,''),NVL(iCant_empleados,0), NVL(mImporte,0), NVL(vFecha_aplicacion,''),NVL(vCta_origen,''),NVL(iNumCtasB,0),NVL(iNumCtasO,0);
	END IF;

    SET LOCK MODE TO WAIT 4;


   SELECT   id_evaluacion,TO_CHAR(fecha_aplicacion,'%d/%m/%Y'),cta_origen,cant_empleados,concepto,importe,nom_tem_archivo,TO_CHAR(fecha_alta,'%H:%M'), numctasb, numctaso
    INTO    iId_evaluacion, vFecha_aplicacion, vCta_origen ,iCant_empleados,vConcepto,  mImporte, vArchivo,vhora_alta,iNumCtasB,iNumCtasO
    FROM    bdibei:"informix".bei_archivos_eval
   WHERE    id_evaluacion = pIdEvaluacion;

    IF  NVL(vArchivo,'') == '' THEN
      LET cod_ret = '002'; 
    END IF;

    RETURN cod_ret, NVL(iId_evaluacion,0),NVL(vConcepto,''), NVL(vArchivo,''),NVL(vhora_alta,''),NVL(iCant_empleados,0), NVL(mImporte,0), NVL(vFecha_aplicacion,''),NVL(vCta_origen,''),NVL(iNumCtasB,0),NVL(iNumCtasO,0);

END
END PROCEDURE;