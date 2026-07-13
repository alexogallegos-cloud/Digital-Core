CREATE PROCEDURE "informix".sp_consulta_operaciones_bei(pTipoMenu CHAR(5), pRegInicial INTEGER)
   returning char(5), integer,INTEGER,INTEGER,CHAR(50),CHAR(5),CHAR(5),INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE iTotalReg INTEGER ;

    DEFINE sid_cat_oper        		INTEGER;
    DEFINE sid_cat_padre			INTEGER ;
    DEFINE sdesc_oper      			CHAR(50);
    DEFINE srango        			BOOLEAN;
 	DEFINE smancomunidad    		BOOLEAN;
    DEFINE crango        			CHAR(5);
 	DEFINE cmancomunidad    		CHAR(5);
    DEFINE sidmenuoper        		INTEGER;
 	DEFINE sTipoMenu INTEGER;

    LET iTotalReg=0;
    LET cod_ret  = "000";

    LET sid_cat_oper        	= 0;
    LET sid_cat_padre			= 0 ;
    LET sdesc_oper      		= "000";
    LET srango        			='f' ;
 	LET smancomunidad    		='f' ;
    LET sidmenuoper        		= 0;
 	LET sTipoMenu        		= 0;
    LET crango        			='f' ;
 	LET cmancomunidad    		='f' ;
	
--****************************************************************************************************
-- DESCRIPCION:  Consulta Operaciones para Alta de Usuario
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
-- MODIFICACION: se castea la variable de entrada ptipomenu a integer para asignarla a sTipoMenu
-- FECHA: 27 Abril 2015
-- MODIFICO: Berenice Noriega Guevara
--***************************************************************************************************


  BEGIN

  
  
  
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, iTotalReg,sid_cat_oper,sid_cat_padre,sdesc_oper,srango,smancomunidad,sidmenuoper;
      END IF ;
   END EXCEPTION ;
   
   
        SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
	

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE Menu Operacion
--**************************************************************************************************************
 IF NVL(pTipoMenu,'') == '' THEN
          LET cod_ret = '00001'; -- No mando Nombre de Usuario Valido
          RETURN cod_ret, iTotalReg,sid_cat_oper,sid_cat_padre,sdesc_oper,srango,smancomunidad,sidmenuoper;
      END IF ;
	SET LOCK MODE TO WAIT 4;
		LET sTipoMenu = (pTipoMenu)::INTEGER;

            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_menu_oper  mper
            WHERE  mper.tipo_menu  = sTipoMenu
            AND mper.activo='t';



     IF iTotalReg == 0 THEN
          LET cod_ret = '002'; -- No ay Registros
          RETURN cod_ret, iTotalReg,sid_cat_oper,sid_cat_padre,sdesc_oper,crango,cmancomunidad,sidmenuoper;
      END IF ;

--**************************************************************************************************************
--OBTIENES DATOS DE OPERACIONES
--**************************************************************************************************************



          FOREACH
            SELECT SKIP pRegInicial FIRST 10
          	cper.id_cat_oper ,cper.id_cat_padre,
            cper.nombre_corto,mper.rango,
            mper.mancomunidad,mper.id_menu_oper
            INTO sid_cat_oper,sid_cat_padre,sdesc_oper,srango,smancomunidad,sidmenuoper
            FROM bdibei:"informix".bei_menu_oper  mper
            JOIN bdibei:"informix".bei_cat_operaciones cper ON cper.id_cat_oper=mper.id_cat_oper
            WHERE  mper.tipo_menu  = sTipoMenu
            AND mper.activo='t'
			      AND cper.id_cat_oper <> 600
            ORDER BY id_cat_padre, id_cat_oper

			LET crango = 'f';
				IF (srango) THEN
					LET crango = 't';
				END IF;

			LET cmancomunidad = 'f';
			IF (smancomunidad) THEN
				LET cmancomunidad = 't';
			END IF;

            RETURN cod_ret, iTotalReg,sid_cat_oper,sid_cat_padre,sdesc_oper,crango,cmancomunidad,sidmenuoper WITH RESUME;
          END FOREACH;


END
END PROCEDURE;