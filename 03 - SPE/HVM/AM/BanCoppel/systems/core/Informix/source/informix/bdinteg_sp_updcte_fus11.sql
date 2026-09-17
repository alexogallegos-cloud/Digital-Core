CREATE PROCEDURE "informix".sp_updcte_fus11() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vd_FechaHoy      DATE;
DEFINE vc_AnioMes       CHAR(6);
DEFINE vi_num_serial    INTEGER;
DEFINE vc_rfc           CHAR(13);
DEFINE vc_ref_ret       CHAR(20);
DEFINE vc_tipo_cta      CHAR(1);
DEFINE vc_sucursal      CHAR(4);
DEFINE vc_num_cta       CHAR(20);
DEFINE vd_fecha_mov     DATE;
DEFINE vm_imp_tot_dep   MONEY(10,2);
DEFINE vm_imp_ide       MONEY(10,2);
DEFINE vc_user_insert   CHAR(8);
DEFINE vd_fecha_insert  DATE;
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Credito        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_num_tarjeta   CHAR(20);
DEFINE vc_rfc_ori       CHAR(13);
DEFINE vc_numsolic      CHAR(20);
DEFINE vc_statusolic    CHAR(2);
DEFINE vi_MaxSec        INTEGER;
DEFINE vi_SecTit        INTEGER;
DEFINE vc_NumCteDirec   CHAR(20);
DEFINE vi_SecDirec      INTEGER;
DEFINE vd_FechaSolic    DATE;
DEFINE vc_TipoDir       CHAR(1);
DEFINE vtransaccion INTEGER;
DEFINE vtipo_cob       CHAR(1);
DEFINE dfecha_in       DATE;
DEFINE iExiste      SMALLINT;
DEFINE vc_empresa	CHAR(3);
DEFINE vc_apellpat	CHAR(26);
DEFINE vc_apellmat	CHAR(26);
DEFINE vc_nombre1	CHAR(26);
DEFINE vc_nombre2	CHAR(26);
DEFINE vc_fecnac	DATE;
DEFINE vc_curp		CHAR(20);
DEFINE vc_sexo		CHAR(1);
DEFINE vc_edocivil	CHAR(2);
DEFINE vc_nacionalidad	CHAR(3);
DEFINE vc_nofm3		CHAR(18);
DEFINE vc_codident	CHAR(2);
DEFINE vc_persdom	CHAR(2);
DEFINE vc_email		CHAR(60);
DEFINE vc_parentesco	CHAR(2);
DEFINE vc_apellcas	CHAR(26);
DEFINE vc_ctebanco	CHAR(20);
DEFINE vc_cteref	CHAR(20);
DEFINE vc_calle          	CHAR(40);
DEFINE vc_colonia        	CHAR(60);
DEFINE vc_entre_calles   	CHAR(40);
DEFINE vc_pais           	CHAR(3);
DEFINE vc_estado         	CHAR(2);
DEFINE vc_ciudad         	CHAR(3);
DEFINE vc_municipio      	CHAR(5);
DEFINE vc_cod_postal     	CHAR(5);
DEFINE vc_apart_postal   	CHAR(11);
DEFINE vc_tipo_telef1    	CHAR(1);
DEFINE vc_telefono1      	CHAR(13);
DEFINE vc_tipo_telef2    	CHAR(1);
DEFINE vc_telefono2      	CHAR(13);
DEFINE vc_tipo_telef3    	CHAR(1);
DEFINE vc_telefono3      	CHAR(13);
DEFINE vc_extension      	CHAR(5);
DEFINE vc_estado_inegi   	CHAR(2);
DEFINE vc_municipio_inegi	CHAR(3);
DEFINE vc_localidad_inegi	CHAR(4);
DEFINE vc_numerociudad   	SMALLINT;
DEFINE vc_numeroextcalle 	CHAR(10);
DEFINE vc_numerointcalle 	CHAR(10);
DEFINE vc_departamento   	CHAR(6);
DEFINE vc_numerocalle    	INTEGER;
DEFINE vc_numerocolonia  	INTEGER;
DEFINE vc_puntocardinal  	CHAR(1);
DEFINE vc_unidadhabitac  	CHAR(1);
DEFINE vc_manzana        	SMALLINT;
DEFINE vc_otros          	SMALLINT;
DEFINE vc_andador        	SMALLINT;
DEFINE vc_etapa          	SMALLINT;
DEFINE vc_lote           	SMALLINT;
DEFINE vc_edificio       	SMALLINT;
DEFINE vc_entrada        	SMALLINT;
DEFINE vc_observaciones  	CHAR(80);
DEFINE pClienteTitular        CHAR(20);
DEFINE pClienteTraspasaCtas        CHAR(20);
DEFINE pCte        CHAR(20);
   
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vd_FechaHoy = "";
LET vc_AnioMes = "";
LET vi_num_serial = 0;
LET vc_rfc = "";
LET vc_ref_ret = "";
LET vc_tipo_cta = "";
LET vc_sucursal = "";
LET vc_num_cta = "";
LET vd_fecha_mov = "";
LET vm_imp_tot_dep = 0;
LET vm_imp_ide = 0;
LET vc_user_insert = "";
LET vd_fecha_insert = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vc_Cuenta = "";
LET vc_Credito = "";
LET vi_secuencia = 0;
LET vc_num_tarjeta = "";
LET vc_rfc_ori = "";
LET vc_numsolic = "";
LET vc_statusolic = "";
LET vi_MaxSec = 0;
LET vi_SecTit = 0;
LET vc_NumCteDirec = "";
LET vi_SecDirec = 0;
LET vd_FechaSolic = "";
LET vc_TipoDir = "";
LET vtransaccion = 0;
LET vtipo_cob='';
LET dfecha_in = "";
LET iExiste=0;
LET vc_empresa ="";
LET vc_apellpat ="";
LET vc_apellmat ="";
LET vc_nombre1 ="";
LET vc_nombre2 ="";
LET vc_fecnac ="";
LET vc_curp ="";
LET vc_sexo ="";
LET vc_edocivil ="";
LET vc_nacionalidad ="";
LET vc_nofm3 ="";
LET vc_codident ="";
LET vc_persdom ="";
LET vc_email ="";
LET vc_parentesco ="";
LET vc_apellcas ="";
LET vc_cteref  ="";
LET vc_ctebanco ="";
LET vc_calle ="";
LET vc_colonia ="";
LET vc_entre_calles ="";
LET vc_pais ="";
LET vc_estado ="";
LET vc_ciudad ="";
LET vc_municipio ="";
LET vc_cod_postal ="";     
LET vc_apart_postal ="";
LET vc_tipo_telef1 ="";
LET vc_telefono1 ="";
LET vc_tipo_telef2 =""; 
LET vc_telefono2 ="";
LET vc_tipo_telef3 =""; 
LET vc_telefono3 ="";
LET vc_extension =""; 
LET vc_estado_inegi =""; 
LET vc_municipio_inegi ="";
LET vc_localidad_inegi ="";
LET vc_numerociudad = 0;
LET vc_numeroextcalle = "";
LET vc_numerointcalle = "";
LET vc_departamento   = "";
LET vc_numerocalle   = 0;
LET vc_numerocolonia = 0;
LET vc_puntocardinal = "";
LET vc_unidadhabitac = "";
LET vc_manzana  = 0;
LET vc_otros    = 0;
LET vc_andador  = 0;
LET vc_etapa    = 0;
LET vc_lote     = 0;
LET vc_edificio = 0;
LET vc_entrada  = 0;
LET vc_observaciones = "";
LET pClienteTitular="";
LET pClienteTraspasaCtas="";
LET pCte="";

set isolation to dirty read;
set lock mode to wait 3;

BEGIN
    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO "/tmp/sp_updcte_fus11.out";
--    TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>''

--**************************************INICIA TRASPASO DE TABLA ADICOPPEL ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)} FIRST 1 numcte INTO pCte FROM bdinteg:si_adiccoppel WHERE numcte=pClienteTraspasaCtas;
	LET iExiste = dbinfo("sqlca.sqlerrd2");
	    IF iExiste>0 THEN
            FOREACH 
                SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)} secuencia, tipotar INTO vi_secuencia, vc_TipoDir
                FROM bdinteg:si_adiccoppel WHERE numcte=pClienteTraspasaCtas            

                LET vc_tabla = "si_adiccoppel";
                LET vc_detalle_mov = TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_TipoDir);
                LET vc_proceso='ADICIONAL COPPEL';

                INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

                INSERT INTO bdinteg:si_fusadiccoppel
                SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)} * FROM bdinteg:si_adiccoppel where numcte=pClienteTraspasaCtas and empresa='001' and secuencia = vi_secuencia;

                UPDATE {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)} bdinteg:si_adiccoppel SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas and empresa='001' and secuencia = vi_secuencia; 
            END FOREACH;
        END IF;
--********************************************************************************************************** 

--**************************************INICIA TRASPASO DE TABLA REFDIRECCIONES ********************************************************************
	SET ISOLATION TO DIRTY READ; 
	SELECT {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} FIRST 1 numcte INTO pCte FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTraspasaCtas;
	LET iExiste = dbinfo("sqlca.sqlerrd2");
	    IF iExiste>0 THEN
			SELECT {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} COUNT(*) INTO iExiste FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTitular;
				IF iExiste>0 THEN
					SELECT {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} MAX(secuencia) INTO vi_MaxSec FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTitular;
				END IF;
            FOREACH 
                SELECT {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} secuencia, tipo_dir INTO vi_secuencia, vc_TipoDir
                FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTraspasaCtas            

                LET vc_tabla = "si_refdirecciones";
                LET vc_detalle_mov = TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_TipoDir);
                LET vc_proceso='REFERENCIAS DIRECCIONES';

                INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

                INSERT INTO bdinteg:si_fusrefdirecciones
                SELECT {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} * FROM bdinteg:si_refdirecciones where numcte=pClienteTraspasaCtas and secuencia = vi_secuencia;

				IF iExiste>0 THEN
					LET vi_MaxSec = vi_MaxSec + 1;

					SELECT {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
					cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, estado_inegi, municipio_inegi, localidad_inegi,
					numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote,
					edificio, entrada, observaciones, numcte_banco, user_insert, fecha_insert
					INTO vc_TipoDir, vc_calle, vc_colonia, vc_entre_calles, vc_pais, vc_estado, vc_ciudad, vc_municipio, vc_cod_postal, vc_apart_postal, 
					vc_tipo_telef1, vc_telefono1, vc_tipo_telef2, vc_telefono2, vc_tipo_telef3, vc_telefono3, vc_extension, vc_estado_inegi, vc_municipio_inegi, vc_localidad_inegi, 
					vc_numerociudad, vc_numeroextcalle, vc_numerointcalle, vc_departamento, vc_numerocalle, vc_numerocolonia, vc_puntocardinal, vc_unidadhabitac, vc_manzana, vc_otros, 
					vc_andador, vc_etapa, vc_lote, vc_edificio, vc_entrada, vc_observaciones, vc_ctebanco, vc_user_insert, vd_fecha_insert
					FROM bdinteg:si_refdirecciones                                                         
					WHERE numcte=pClienteTraspasaCtas and secuencia = vi_secuencia;
					
					INSERT INTO bdinteg:si_refdirecciones (numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, tipo_telef1, 
					telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
					numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, 
					lote, edificio, entrada, observaciones, numcte_banco, user_insert, fecha_insert)
					VALUES (pClienteTitular, vi_MaxSec, vc_TipoDir, vc_calle, vc_colonia, vc_entre_calles, vc_pais, vc_estado, vc_ciudad, vc_municipio, vc_cod_postal, vc_apart_postal, 
					vc_tipo_telef1, vc_telefono1, vc_tipo_telef2, vc_telefono2, vc_tipo_telef3, vc_telefono3, vc_extension, vc_estado_inegi, vc_municipio_inegi, vc_localidad_inegi, 
					vc_numerociudad, vc_numeroextcalle, vc_numerointcalle, vc_departamento, vc_numerocalle, vc_numerocolonia, vc_puntocardinal, vc_unidadhabitac, vc_manzana, vc_otros, 
					vc_andador, vc_etapa, vc_lote, vc_edificio, vc_entrada, vc_observaciones, vc_ctebanco, vc_user_insert, vd_fecha_insert);
				ELSE 
					UPDATE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} bdinteg:si_refdirecciones SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas and secuencia = vi_secuencia; 
				END IF;
            END FOREACH;
			DELETE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTraspasaCtas;
        END IF;
--**********************************************************************************************************

--**************************************INICIA TRASPASO DE TABLA REFCLIENTES ********************************************************************
	SET ISOLATION TO DIRTY READ; 
	SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FIRST 1 numcte INTO pCte FROM bdinteg:si_refclientes WHERE numcte=pClienteTraspasaCtas;
	LET iExiste = dbinfo("sqlca.sqlerrd2");
	    IF iExiste>0 THEN
			SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} COUNT(*) INTO iExiste FROM bdinteg:si_refclientes WHERE numcte=pClienteTitular;
				IF iExiste>0 THEN
					SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} MAX(secuencia) INTO vi_MaxSec FROM bdinteg:si_refclientes WHERE numcte=pClienteTitular;
				END IF;
            FOREACH				
                SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} secuencia, num_solicitud INTO vi_secuencia, vc_numsolic
                FROM bdinteg:si_refclientes WHERE numcte=pClienteTraspasaCtas
				
				LET vc_tabla = "si_refclientes";
                LET vc_detalle_mov = TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_numsolic);
                LET vc_proceso='REFERENCIAS CLIENTES';
				
				INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

				INSERT INTO bdinteg:si_fusrefclientes
				SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} * FROM bdinteg:si_refclientes where numcte=pClienteTraspasaCtas and secuencia = vi_secuencia and empresa='001';
				
				IF iExiste>0 THEN
					LET vi_MaxSec = vi_MaxSec + 1;

					SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)}empresa, sucursal, apell_paterno, apell_materno, nombre1, nombre2, rfc, fecha_nac, curp, sexo,
					estado_civil, nacionalidad, no_fm3, codidentifi, pers_domicilio, email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert
					INTO vc_empresa, vc_sucursal, vc_apellpat, vc_apellmat, vc_nombre1, vc_nombre2, vc_rfc, vc_fecnac, vc_curp, vc_sexo, vc_edocivil, vc_nacionalidad,
					vc_nofm3, vc_codident, vc_persdom, vc_email, vc_parentesco, vc_apellcas, vc_cteref, vc_ctebanco, vc_user_insert, vd_fecha_insert
					FROM bdinteg:si_refclientes
					WHERE numcte=pClienteTraspasaCtas and secuencia = vi_secuencia and empresa='001';
					
					INSERT INTO bdinteg:si_refclientes (empresa, numcte, sucursal, secuencia, apell_paterno, apell_materno, nombre1, nombre2, rfc, fecha_nac, curp, sexo,
					estado_civil, nacionalidad, no_fm3, codidentifi, pers_domicilio, email,	parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert)
					VALUES (vc_empresa, pClienteTitular, vc_sucursal, vi_MaxSec, vc_apellpat, vc_apellmat, vc_nombre1, vc_nombre2, vc_rfc, vc_fecnac, vc_curp, vc_sexo,
					vc_edocivil, vc_nacionalidad, vc_nofm3, vc_codident, vc_persdom, vc_email, vc_parentesco, vc_apellcas, vc_cteref, vc_ctebanco, vc_user_insert,
					vd_fecha_insert);
				ELSE 
					UPDATE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} bdinteg:si_refclientes SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas and secuencia = vi_secuencia and empresa='001'; 
				END IF;
            END FOREACH;
			DELETE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FROM bdinteg:si_refclientes WHERE numcte=pClienteTraspasaCtas;
        END IF;
--********************************************************************************************************** 

--**************************************INICIA TRASPASO DE TABLA INGRESOS ********************************************************************
	SET ISOLATION TO DIRTY READ; 
	SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} FIRST 1 numcte INTO pCte FROM bdinteg:si_ingresos WHERE numcte=pClienteTraspasaCtas;
	LET iExiste = dbinfo("sqlca.sqlerrd2");
	    IF iExiste>0 THEN
			SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} COUNT(*) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTitular;
            FOREACH 
                SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} sec_ingreso, tipo_ingreso INTO vi_secuencia, vc_TipoDir
                FROM bdinteg:si_ingresos WHERE numcte=pClienteTraspasaCtas            

                LET vc_tabla = "si_ingresos";
                LET vc_detalle_mov = TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_TipoDir);
                LET vc_proceso='INGRESOS';

                INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

                INSERT INTO bdinteg:si_fusingresos
                SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} * FROM bdinteg:si_ingresos where numcte=pClienteTraspasaCtas and sec_ingreso = vi_secuencia and empresa='001';
				
				IF iExiste=0 THEN
					UPDATE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} bdinteg:si_ingresos SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas and sec_ingreso = vi_secuencia and empresa='001'; 
				ELSE
					DELETE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} FROM bdinteg:si_ingresos WHERE numcte=pClienteTraspasaCtas and sec_ingreso = vi_secuencia and empresa='001'; 
				END IF;
				
            END FOREACH;
        END IF;			 
--********************************************************************************************************** 
END FOREACH;  
    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;