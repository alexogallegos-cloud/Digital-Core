CREATE PROCEDURE "informix".sp_consulta_errorarchivo_bei(pIdEvaluacion INTEGER, pNoReg INTEGER,pRegIni INTEGER)
    RETURNING CHAR(5), INTEGER,CHAR(20), SMALLINT, char(500), char(17), char(10), SMALLINT, MONEY, char(12);
	
--****************************************************************************************************
-- DESCRIPCION:  Consulta los errores de los archivos de dispersion 
-- AUTOR : SOLSER - Rosa Martinez
-- FECHA : 08/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel - Cordinacion Internet - G3
-- FECHA DE LIBERACIÃN: 
--***************************************************************************************************

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE iTotalReg INTEGER ;

    DEFINE pSeccion char(17);
    DEFINE pRenglon SMALLINT;
    DEFINE pDescripcion char(500);
    DEFINE pNombre char(17);
    DEFINE pHoraAlta char(10);
    DEFINE pEmpleados SMALLINT;
    DEFINE pImporte MONEY;
    DEFINE pFechaApli char(12);

	LET cod_ret    = "00000";
    LET pSeccion   = "";
    LET pRenglon   = "";
    LET pDescripcion   = "";
    LET pNombre    = "";
    LET pHoraAlta  = "";
    LET pEmpleados = "";
    LET pImporte   = "";
    LET pFechaApli = "";


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, NVL(iTotalReg,0), NVL(pSeccion,''), NVL(pRenglon,0), NVL(pDescripcion,''), NVL(pNombre, ''), NVL(pHoraAlta,''), NVL(pEmpleados,0), NVL(pImporte, ''),  NVL(pFechaApli,'');
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--**************************************************************************************************************
     IF NVL(pIdEvaluacion,-1) == -1 THEN
          LET cod_ret = '00001'; -- No mando el id 
        RETURN cod_ret, NVL(iTotalReg,0), NVL(pSeccion,''), NVL(pRenglon,0), NVL(pDescripcion,''), NVL(pNombre, ''), NVL(pHoraAlta,''), NVL(pEmpleados,0), NVL(pImporte, ''),  NVL(pFechaApli,'');
      END IF ;    
--**************************************************************************************************************
--**************************************************************************************************************


	SET LOCK MODE TO WAIT 4;


            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_errores_archivo er
            JOIN bdibei:"informix".bei_archivos_eval ar ON (er.id_evaluacion = ar.id_evaluacion)
            JOIN bdibei:"informix".bei_cat_errores_arch cat ON (er.id_desc_error = cat.id_desc_error)
           WHERE er.id_evaluacion = pIdEvaluacion;

     IF iTotalReg == 0 THEN
          LET cod_ret = '003'; -- No hay Registros
            RETURN   cod_ret, NVL(iTotalReg,0), NVL(pSeccion,''), NVL(pRenglon,0), NVL(pDescripcion,''), NVL(pNombre, ''), NVL(pHoraAlta,''), NVL(pEmpleados,0), NVL(pImporte, ''),  NVL(pFechaApli,'');
      END IF ;
--**************************************************************************************************************
--**************************************************************************************************************

        FOREACH
            SELECT SKIP pRegIni FIRST pNoReg  er.renglon_error, cat.seccion, cat.descripcion_error,ar.nom_tem_archivo, 
                   TO_CHAR(ar.fecha_alta,'%H:%M'), ar.cant_empleados, ar.importe, TO_CHAR(ar.fecha_aplicacion,'%d/%m/%y')                  
              INTO pRenglon, pSeccion, pDescripcion, pNombre,  
                   pHoraAlta, pEmpleados, pImporte,   pFechaApli
              FROM bdibei:"informix".bei_errores_archivo er
              JOIN bdibei:"informix".bei_archivos_eval ar ON (er.id_evaluacion = ar.id_evaluacion)
              JOIN bdibei:"informix".bei_cat_errores_arch cat ON (er.id_desc_error = cat.id_desc_error)
             WHERE er.id_evaluacion = pIdEvaluacion
          Order By er.renglon_error asc
            


               RETURN cod_ret, NVL(iTotalReg,0), NVL(pSeccion,''), NVL(pRenglon,0), NVL(pDescripcion,''), NVL(pNombre, ''), NVL(pHoraAlta,''), NVL(pEmpleados,0), NVL(pImporte, ''),  NVL(pFechaApli,'') WITH RESUME;
       END FOREACH;

END
END PROCEDURE;