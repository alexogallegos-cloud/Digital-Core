CREATE PROCEDURE "informix".sp_repos_cat(pfecha_rep DATE, pusuario CHAR(8))
RETURNING  CHAR(6), CHAR(150);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			  INTEGER;
DEFINE isam_err 		  INTEGER;
DEFINE error_info		  CHAR(150);
DEFINE cCod_ret           CHAR(6);
DEFINE ccCod_ret          CHAR(6);
DEFINE cMensaje           CHAR(150);
DEFINE ccMensaje          CHAR(150);
DEFINE cCadena            CHAR (500);
DEFINE vNomArch           CHAR(30);
DEFINE vNomArch2          CHAR(30);
DEFINE vPathOri           CHAR(50);
DEFINE vPath              CHAR(50);
DEFINE vempresa           CHAR(3);
DEFINE vproceso           CHAR(20);
DEFINE cNum_sol			  CHAR(20);
DEFINE cNumCte			  CHAR(20);
DEFINE cStatus_sol		  CHAR(2);
DEFINE cSucursal		  CHAR(4);
DEFINE dFecha_insert      DATE;
DEFINE cNombre_completo   CHAR(80);
DEFINE cTel_casa		  CHAR(13);
DEFINE cCelular			  CHAR(13);
DEFINE cTel_trab		  CHAR(13);
DEFINE cExt_trab		  CHAR(5);
DEFINE deMonto_sol		  DECIMAL(18,2);
DEFINE pSeparador         CHAR(1);
DEFINE vpusuario          CHAR(8);
DEFINE dFecha_ini		  DATE;
DEFINE dDia				  DATE;
DEFINE dFecha_fin		  DATE;
DEFINE dFechaBorra		  DATE;
DEFINE eDias			  INTEGER;
DEFINE vmeses_historial   INTEGER;
DEFINE vtipo_comprobante  CHAR(4);
DEFINE vsql 			  CHAR(5054);


    LET dFecha_insert = '';	     
    LET cCod_ret      = '00000';
    LET sql_err       = 0;
    LET cMensaje      = 'PROCESO EXITOSO';
    LET cCadena       = '';
    LET vPathOri        = '';
    LET vPath         = '';
    LET vempresa      = '001';
    LET vproceso      = '1001';   
    LET cNum_sol            = '';		
    LET cNumCte             = '';	  
    LET cStatus_sol         = '';	 
    LET cSucursal           = '';		 
    LET cNombre_completo    ='';	
    LET cTel_casa	  = '';		
    LET cCelular	  = '';		
    LET cTel_trab	  = '';	
    LET cExt_trab	  = '';		
    LET deMonto_sol	  = 0.00;	
    LET pSeparador    = '|';
    LET vpusuario     = pusuario;
    LET dFecha_ini	  = '';
    LET dDia		  = '';
    LET dFecha_fin 	  = '';
    LET dFechaBorra = '';
    LET eDias         = '';
    LET vsql 	      = '';
       
      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01');
                
    --SET DEBUG FILE TO "/home/syscobra/sp_cat_arch_cartbase.out";
    --TRACE ON;

------------------------------------------------------------------------------------
    TRUNCATE cb_repos_cat;

    SELECT valor INTO vNomArch
	FROM bdicobranza:cb_param
	WHERE cod_param= '2' AND empresa= vempresa;

    LET vNomArch2 = vNomArch;

    -- ARMAR NOMBRE DEL ARCHIVO TXT
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(pfecha_rep,'%Y%m%d') || '.txt';

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

    -- EXTRAER LA RUTA DEPOSITO DE ARCHIVO
    SELECT TRIM(valor) 
    INTO vPathOri
	FROM Bdicobranza:cb_param
	WHERE cod_param= '1' AND empresa= vempresa;
    SELECT valor INTO eDias
	FROM Bdicobranza:cb_param
	WHERE cod_param= '5' AND empresa= vempresa;
   
    Let vPath = TRIM(vPathOri);

        --obtiene el dia de la semana en que se genera el reporte
		LET dDia= weekday(pfecha_rep);

        IF dDia = 1 THEN
			LET dFecha_ini = pfecha_rep -3;
			LET dFecha_fin = pfecha_rep -1;
		ELSE
			LET dFecha_ini = pfecha_rep -1;
			LET dFecha_fin = pfecha_rep -1;
		END IF;

        

        LET dFechaBorra =  pfecha_rep - eDias;

        LET dFechaBorra = dFechaBorra;

        SET ISOLATION TO DIRTY READ;
		FOREACH

			SELECT a.num_solicitud,a.numcte,a.status_solicitud,a.sucursal,a.fecha_insert,
			TRIM(d.nombre1) || " " || TRIM(d.nombre2) || " " ||TRIM(d.apell_paterno) || " " || TRIM(d.apell_materno), 
			tel1.telefono , tel2.telefono , tel3.telefono , tel3.extension ,a.monto_solicitado
			INTO cNum_sol, cNumCte, cStatus_sol, cSucursal, dFecha_insert, cNombre_completo, 
			cTel_casa, cCelular, cTel_trab, cExt_trab, deMonto_sol
			FROM  bdisolic:ss_solicitudes a
			join bdinteg:si_cliente d on (a.numcte = d.numcte)
			left join bdinteg:si_telefonos tel1 on (tel1.numcte = a.numcte and tel1.tipo_tel = 1 and 
					tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = a.numcte and tipo_tel = 1))
			left join bdinteg:si_telefonos tel2 on (tel2.numcte = a.numcte and tel2.tipo_tel = 2 and 
					tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = a.numcte and tipo_tel = 2))
			left join bdinteg:si_telefonos tel3 on (tel3.numcte = a.numcte and tel3.tipo_tel = 3 and 
					tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = a.numcte and tipo_tel = 3))
			WHERE a.fecha_insert  BETWEEN  dFecha_ini AND dFecha_fin
			AND a.status_solicitud in ('AP','OA','OS','EE','AT')  
		
            --SELECT nvl(meses_historia,0)
            SELECT NVL (MAX(meses_historia),0) as meses_historia
            INTO vmeses_historial
            FROM bdisolic:ss_resum_scor_fin                
            WHERE empresa = vempresa
            AND num_solicitud = cNum_sol;

            CALL bdidigital@coppelimg_tcp:sp_tipo_comprobante(cNumCte, cNum_sol)   
            RETURNING ccCod_ret, ccMensaje, vtipo_comprobante;
-- let vtipo_comprobante = '';---------------------------------------------------------------------------------PUEBAS
			--se insertan los datos generados 
			INSERT INTO cb_repos_cat (num_solicitud, numcte, status_solicitud, sucursal, fecha_insert, 
									 nombre_completo,tel_casa,  celular, tel_trab, ext_trab, monto_sol, meses_historial, tipo_comprobante)
			VALUES(cNum_sol, cNumCte, cStatus_sol, cSucursal, dFecha_insert, cNombre_completo, 
				   cTel_casa, cCelular, cTel_trab, cExt_trab, deMonto_sol, vmeses_historial, vtipo_comprobante);
                              
		END FOREACH;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

            LET cCadena = 'echo "unload to ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || ' DELIMITER ''' || pSeparador || ''' SELECT * FROM cb_repos_cat'
                   || '" > ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'reporte_os.sql';
            System cCadena;
            let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'reporte_os.sql';
            System cCadena;
            let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'reporte_os.sql';
            System cCadena;
            

            --LET cMensaje = TRIM(vNomArch);

            LET vNomArch2 = TRIM(vNomArch2) || 
							NVL( YEAR(dFechaBorra) || 
							LPAD(MONTH(dFechaBorra),2,'0') || 
							LPAD(DAY(dFechaBorra),2,'0') , '') ||
							'.txt';

            LET vsql = '';  --SE BORRA ARCHIVO MAYOR A 7 DIAS 
            LET vsql = "rm -rf "||TRIM(vPathOri)||""||vNomArch2;
            SYSTEM vsql;

CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03');
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;