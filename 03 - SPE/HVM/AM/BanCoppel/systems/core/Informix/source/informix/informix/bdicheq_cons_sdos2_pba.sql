CREATE PROCEDURE "informix".cons_sdos2_pba( pempresa CHAR(3), pcuenta CHAR(20), pnum_tarjeta CHAR(16) )
returning CHAR(5),     --- CODIGO DE RETORNO
          CHAR(20),    --- CUENTA
          CHAR(20),    --- NO. CLIENTE
          CHAR(26),    --- APELL PATERNO
          CHAR(26),    --- APELL MATERNO
          CHAR(26),    --- NOMBRE 1
          CHAR(26),    --- NOMBRE 2
          CHAR(60),    --- RAZON SOCIAL
          CHAR(1),     --- STATUS CUENTA
          MONEY(14,2), --- SALDO DISPONIBLE
          MONEY(14,2), --- SALDO RETENIDO
          MONEY(14,2), --- SALDO CCC
          MONEY(14,2), --- SALDO CCC DISP
          MONEY(14,2), --- SALDO CUENTA
          CHAR(1),     --- TIPO DE LINEA
          CHAR(40),    --- DESCRIPCION 1
          CHAR(40),    --- DESCRIPCION 2
          MONEY(14,2), --- SALDO T1
          MONEY(14,2), --- SALDO CONGELADO
          MONEY(14,2), --- SALDO SBC
          CHAR(8),     --- USUARIO BLOQUEO
          DATE,        --- FECHA BLOQUEO
          CHAR(16),    --- NO. TARJETA
          CHAR(18),    --- CUENTA CLABE
          DATE;        --- FECHA EXP TARJETA
    
    DEFINE vcod_ret          CHAR(5);
    DEFINE vcod_ret2         CHAR(5);
    DEFINE vcod_ret3         CHAR(50);
    DEFINE sql_err           INTEGER;
    DEFINE isam_err          INTEGER;
    DEFINE desc_err          CHAR(50);
    DEFINE vcuenta           CHAR(20);
    DEFINE vedo_cta          CHAR(1);
    DEFINE vsdo_cta          MONEY(14,2);
    DEFINE vsdo_ret          MONEY(14,2);
    DEFINE vsdo_cong         MONEY(14,2);
    DEFINE vsdo_ccc          MONEY(14,2);
    DEFINE vimp_chq_sbc      MONEY(14,2);
    DEFINE vtipo_linea       CHAR(1);
    DEFINE vsdo_disp         MONEY(14,2);
    DEFINE vnro_cte          CHAR(20);
    DEFINE vnumero           CHAR(20);
    DEFINE vnum_cte          CHAR(20);
    DEFINE vimp_sbg_ccc      MONEY(14,2);
    DEFINE vsdo_disp_ccc     MONEY(14,2);
    DEFINE vsdo_t1           MONEY(14,2);
    DEFINE vimp_chq_sbg      MONEY(14,2);
    DEFINE vapell_pat        CHAR(26);
    DEFINE vapell_mat        CHAR(26);
    DEFINE vnombre1          CHAR(26);
    DEFINE vnombre2          CHAR(26);
    DEFINE vrazon_soc        CHAR(60);
    DEFINE vdivisa           CHAR(2);
    DEFINE vmoneda           CHAR(30);
    DEFINE vproducto         CHAR(4);
    DEFINE vprodnom          CHAR(35);
    DEFINE vplaza            CHAR(3);
    DEFINE vlong_cta         CHAR(2);
    DEFINE longitud          SMALLINT;
    DEFINE vdescrip1         CHAR(40);
    DEFINE vdescrip2         CHAR(40);
    DEFINE vfecbloq          DATE;
    DEFINE vusubloq          CHAR(8);
    DEFINE vrowid            INTEGER;
    DEFINE vnum_tarjeta      CHAR(16);
    DEFINE vcta_clabe        CHAR(18);
    DEFINE vmarca_ret        CHAR(1);
    DEFINE vstatus_tar       CHAR(1);
    DEFINE vmotivo           CHAR(2);
    DEFINE sFecExp           DATE;
    DEFINE vind_dispon       CHAR(1);
    DEFINE vind_cierre       CHAR(1);
	DEFINE vtpo_persona      CHAR(2);
    DEFINE vesfisica         CHAR(1);
    DEFINE vdescripcion      CHAR(60);
	DEFINE cCodStatusTarjeta CHAR(3);
    
    LET vcod_ret          = "000";
    LET vcod_ret2         = "";
    LET vcod_ret3         = "";
    LET sql_err           = 0;
    LET isam_err          = 0;
    LET desc_err          = "";
    LET vcuenta           = pcuenta;
    LET vnum_cte          = "";
    LET vapell_pat        = " ";
    LET vapell_mat        = " ";
    LET vnombre1          = " ";
    LET vnombre2          = " ";
    LET vrazon_soc        = " ";
    LET vedo_cta          = "";
    LET vsdo_disp         = 0 ;
    LET vsdo_ret          = 0 ;
    LET vsdo_ccc          = 0 ;
    LET vsdo_disp_ccc     = 0 ;
    LET vsdo_cta          = 0 ;
    LET vtipo_linea       = " ";
    LET vdescrip1         = "";
    LET vdescrip2         = "";
    LET vsdo_t1           = 0 ;
    LET vsdo_cong         = 0 ;
    LET vimp_chq_sbc      = 0;
    LET vimp_sbg_ccc      =  0 ;
    LET vmoneda           = " ";
    LET vdivisa           = " ";
    LET vproducto         = " ";
    LET vprodnom          = " ";
    LET vsdo_cong         = 0;
    LET vfecbloq          = "";
    LET vusubloq          = " ";
    LET vnum_tarjeta      = pnum_tarjeta;
    LET vcta_clabe        = "";
    LET vimp_chq_sbg      = 0;
    LET vstatus_tar       = "";
	LET vmotivo           = "";
	LET sFecExp           = "";
	LET vind_dispon       = '0';
	LET vind_cierre       = '0';
	LET vtpo_persona      = '';
	LET vesfisica         = '';
	LET vdescripcion      = '';
	LET cCodStatusTarjeta = '';
	
	BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cons_sdos2.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcod_ret = sql_err;
            LET vcod_ret2 = isam_err;
            LET vcod_ret3 = desc_err;
            LET vmoneda = " " ;
            LET vprodnom = " ";
            RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                   vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cons_sdos2.out";	
	--- TRACE ON;
    
    SELECT ind_disponible, ind_cierre
      INTO vind_dispon, vind_cierre
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pempresa;
    
    IF ( vind_dispon = '0' OR vind_cierre = '0' ) THEN
        LET vcod_ret = "004";
        LET vmoneda  = " ";
        LET vprodnom = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF;
    
    IF pcuenta = "00000000000" AND pnum_tarjeta = "0000000000000000" THEN
        LET vcod_ret = "110";
        LET vmoneda = " ";
        LET vprodnom = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF
    
    IF pcuenta = "00000000000" THEN
        IF pnum_tarjeta <> "0000000000000000" THEN
            SELECT codstatustarjeta 
              INTO cCodStatusTarjeta 
              FROM intercard:"informix".tarjeta 
             WHERE numtarjeta = pnum_tarjeta;
            
            IF cCodStatusTarjeta = 'BLO' THEN
                LET vcod_ret = "122";
                RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                       vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
            ELSE
                SELECT cuenta, numcte, status_tar, expiracion, prodtarjeta
                  INTO pcuenta, vnum_cte, vstatus_tar, sFecExp, vproducto
                  FROM bdicheq:"informix".sc_tarjeta
                 WHERE empresa = pempresa 
                   AND num_tarjeta = pnum_tarjeta;
                
                LET sFecExp = DATE(mdy(MONTH(sFecExp), '01', YEAR(sFecExp)));
                
                IF vstatus_tar != "A" THEN
                    LET vcod_ret = "122";
                    RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                           vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
                END IF
                
                IF vproducto = "8000" THEN 
                    -- // Validación para una transacción no permitida con producto 8000
                    LET vcod_ret = "855";
                    LET vproducto = "";
                    RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                           vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
                END IF
            END IF
        END IF
    END IF
    
    IF vnum_cte != "" THEN
        SELECT cuenta, mc.plaza, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, sdo_retenido, sdo_cong, sdo_actual, 
               mc.producto, pr.nombre, pr.divisa, di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg
          INTO vcuenta, vplaza, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta, 
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg
          FROM bdicheq:"informix".sc_maechq mc,
               bdicheq:"informix".sc_producto pr,
               bdinteg:"informix".si_divisas di
         WHERE mc.empresa = pempresa 
           AND cuenta = pcuenta
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
           AND di.empresa = pr.empresa 
           AND di.divisa = pr.divisa;
    ELSE
        SELECT cuenta, mc.plaza, num_cte, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, sdo_retenido, sdo_cong, sdo_actual, 
               mc.producto, pr.nombre, pr.divisa, di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg
          INTO vcuenta, vplaza, vnum_cte, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta, 
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg
          FROM bdicheq:"informix".sc_maechq mc,
               bdicheq:"informix".sc_producto pr,
               bdinteg:"informix".si_divisas di
         WHERE mc.empresa = pempresa 
           AND cuenta = pcuenta
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
           AND di.empresa = pr.empresa 
           AND di.divisa = pr.divisa;
    END IF
    
    IF vcuenta is null THEN
        LET vcod_ret = "100";
        LET vmoneda = " ";
        LET vprodnom = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF
    
    IF vmarca_ret <> "1" OR vmarca_ret IS NULl THEN
        LET vedo_cta = "0";
    END IF
    
    SELECT numcte, apell_paterno, NVL(apell_materno,""), nombre1, NVL(nombre2,""), razon_social, tpo_persona
      INTO vnumero, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vtpo_persona
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = vnum_cte;
    
    SELECT es_fisica 
      INTO vesfisica 
      FROM bdinteg:"informix".si_tipper
     WHERE tpo_persona = vtpo_persona;
        
    IF vesfisica <> "S" THEN
        SELECT descripcion 
          INTO vdescripcion 
          FROM bdinteg:"informix".si_ctepm, 
               bdinteg:si_sufijos 
         WHERE numcte = vnum_cte
           AND codigo = sufijo;
        
        LET vrazon_soc = TRIM(vrazon_soc)||" "||TRIM(vdescripcion);			   
    ELSE
        LET vrazon_soc = " ";
    END IF;
    
    IF vapell_pat is null THEN
        LET vapell_pat = " ";
    END IF;
    
    IF vapell_mat is null THEN
        LET vapell_mat = " ";
    END IF;
    
    IF vnombre1 is null THEN
        LET vnombre1 = " ";
    END IF;
    
    IF vnombre2 is null THEN
        LET vnombre2 = " ";
    END IF;
    
    IF vrazon_soc is null THEN
        LET vrazon_soc = " ";
    END IF;
    
    IF vnumero is null THEN
        LET vnumero = "0";
    END IF
    
    IF vnumero != vnum_cte THEN
        LET vcod_ret = "104";
        LET vmoneda = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF
    
    IF vsdo_ret < 0 THEN
        LET vsdo_ret = vsdo_ret * -1;
    END IF
    
    IF vsdo_cong < 0 THEN
        LET vsdo_cong = vsdo_cong * -1;
    END IF
    
    IF vimp_chq_sbg < 0 THEN
        LET vimp_chq_sbg = vimp_chq_sbg * -1;
    END IF
    
    LET vsdo_disp = vsdo_cta - vsdo_ret - vsdo_cong - vimp_chq_sbg;
    LET vsdo_ret = vsdo_ret + vimp_chq_sbc;
    LET vsdo_disp_ccc = vsdo_ccc - vimp_sbg_ccc;
    
    IF vedo_cta IN("3", "4", "5", "8") THEN
        LET vedo_cta = "1";
    END IF
    
    LET vdescrip2 = vdivisa||" "||vmoneda;
    LET vdescrip1 = vproducto||" "||vprodnom;
    LET vsdo_ccc  = vsdo_ccc - vsdo_disp_ccc;
    
    RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
           vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    
    END;
    
END PROCEDURE

DOCUMENT
'FOLIO.........: 1455 - TransferOFI',
'AUTOR.........: 95734511 - José Magdiel Martínez López',
'FECHA.........: 05/06/2014	DSB05062014',
'MODIFICACIÓN..: Se añadio validación para la busqueda por numero de tarjeta, se verifica si el producto es 8000-Transfer.',
'SUSTENTO......: Se definio en el contrato 1455-RQI Transfer-Contrato.pdf',
'SOLICITA......: Berenice Mendez',
'BD............: BDICHEQ',
'----------------------------------------------------',
'Folio: 1730 - OperacionesMayoresConNIP',
'Autor: 95142134 Mario Gallardo',
'Fecha: 02/06/2015',
'Modificación: Se modifica procedimiento para verificar si la tarjeta se encuentra inactiba en la base de datos intercard',
'Sustento: RQM 06 221 Operaciones Mayores con NIP y autorizadas por cajero o gerente.pdf',
'Solicita: Rodolfo Gómez',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_genera_archivosbatch_pba(pempresa CHAR(3), pFechaAct DATE) 
RETURNING CHAR(6);		

DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE vClave,varea, vrumbo, vcasapropia,vsexo,vestadocivil,vescolaridad,vtiposueldo,vsituacionespecial,vclaveautrechaza,vaceptadosupervisadorechazado,vclientenuevo,vcreditojoven,vpuesto,cSexoConyuge,vrumbotrabajoconyuge,vclaveconyugefamilia,cSexoReferencia,  vclavereferencia1 , cSexoReferencia2 ,  vclavereferencia2 , vmarcadatosin , vflagentregotarjeta , vflagnoreconocehuella , vtipo , vTipoOrigen , cBuroPilotoTestig , cModeloCel , cflaguht , cUnidadHabit  CHAR(1);
DEFINE vcaja,vflaguhc,vuhcmanzana,vuhcotros, vuhcandador,vuhcetapa,vuhclote,vuhcedificio,vuhcentrada, vnumerodependientes,vpersonastrabajan, vlimitecredito,vcausasituacionespecial, vopcionpuesto,vflaguhy, vuhymanzana, vuhyotros, vuhyandador, vuhyetapa, vuhylote, vuhyedificio, vuhyentrada, vclaveproducto, vSistsegsocial, vTiposueldoext, vNumempleados, vSubopcionpuesto, vPuestoext, vOpcionpuestoext, vNumempleadosext, vSubopcionpuestoext, sPropNegocio, sParCelulares, sParAltoRiesgo, sParPrestamo, vtiporeposicion, vtiendafolio, vnegocio, vsubnegocio, vtiendafolioanterior, sFlagTestParametrico, sFlagCapCobranza, iFlagLineaCredEsp, sFlagCapHuella,icontador SMALLINT;
DEFINE vcliente_ref,vlugartrabajo,vclienteconyuge,vlugartrabajoconyuge,vclientereferencia, vnumcte , vclientereferencia2, cClienteConyugebcpl, cClienteReferencia1bcpl , cClienteReferencia2bcpl , vfolio , vnumerosolicituddecredito, cNumSolRef CHAR(20);
DEFINE vnombre1,vnombre2,vapell_paterno,vapell_materno, vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,vnombreunoreferencia,  vnombredosreferencia, vapellidopaternoreferencia, vapellidomaternoreferencia,vnombreunoreferencia2, vnombredosreferencia2, vapellidopaternoreferencia2, vapellidomaternoreferencia2,cApellCasada CHAR(26);
DEFINE vciudad,vcolonia,vcalle,iNumerocasa,vpersonasvivenendomicilio,vextensiontrabajo,vciudadconyuge, vcoloniaconyuge, vcalletrabajoconyuge, iNumerocasaconyuge, vflagactualizacion, vreferencia2, vreferencia3, vefectuo, vreposicion, vempleadoautorizo, vfolioanterior, iEmpleadoSubCob, iEmpleadoGteAutori, iMontoIngMensual,  iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, vEdad, iSqlErr, iValor, iPuntuacion, iSecuencia,inumSecuencia, iElemento, vciudadbanco, vcoloniabanco, iContConsBuro, iCuentaRegistros, iRowId,vfoliotienda,iRefSecusConyugue,iRefSecuencias1,iRefSecuencias2, iGrupo,icontador2,iSegundaref,iIsamErr INTEGER;
DEFINE iIngreso,vingresomensual DECIMAL(18,2);
DEFINE vdeptointerior,vdeptoointeriorconyuge, vfolioaut,cNumInterior, cFolioSucursal CHAR(4);
DEFINE vcomplemento,vcomplementotrabajo,vcomplementoconyuge CHAR(80);
DEFINE ventrecalles, ventrecallesconyuge, cErrorInfo,cDescError  CHAR(40);
DEFINE vtelefono, vtelefonocelular,vtelefonotrabajo,vtelefonotrabajoconyuge,vtelefonocelularconyuge, vtelefonoreferencia2 INT8;
DEFINE dFechaConsBuro,vfechanacimiento,vfechaaltacliente,vfechamovto, vFecha_Hoy,dFechaAlta,dFechaRespuesta,dFechaEntrada,dFechaSalida DATE;
DEFINE vniptitular,vniptitularm, vnipadicional  CHAR(7);
DEFINE vcveburo,cMarcarConsultado,cFlagConsBuro,vTipo_Dir,cMarcaHit, vclaveidentificacion,cStatus2,cStatus CHAR(2);
DEFINE cfechanac, cfechadesdecuandovive, cfechaantiguedtrab,cfechaaltacte,vfolioconcir,cFechaConsBuro,cFecha_hoy CHAR(10);
DEFINE vcurp,vclaveelector CHAR(18);
DEFINE videntificacion CHAR(8);
DEFINE vrfc CHAR(13);
DEFINE vfolioconsulta CHAR(9);
DEFINE cfechamovto CHAR (19);
DEFINE vTipoProducto CHAR(5);
DEFINE cNacionalidad,cPais,cEstado,cDelegMunicip CHAR(3);
DEFINE cNoIMSS CHAR(12);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE cDescripElemento CHAR(50);
DEFINE vNombre CHAR(104);
DEFINE vsSQL,vVarSeccion2,vVarSeccion1 LVARCHAR (32000);
DEFINE vCodRetorno Char(6);
DEFINE  cVarConyuge,cArmadoCadena,cVarReferencia1,cVarReferencia2,cVarDireccion2,cVarDireccion1,vVarOSCALLE,vVarOSCALLE2,vVarSeccion3,vVarSeccion4 LVARCHAR(1024);

--DECLARACION DE VARIABLES
--------------------------
LET cVarConyuge  ="";
LET cArmadoCadena ="";
LET vVarOSCALLE ="";
LET vVarOSCALLE2 ="";
LET vVarSeccion3 ="";
LET cVarReferencia1 ="";
LET cVarReferencia2 ="";
LET cVarDireccion2 ="";
LET cVarDireccion1 ="";
LET iRefSecusConyugue=0;
LET iRefSecuencias1 =0;
LET iRefSecuencias2 =0;
LET vClave = '';
LET vcaja = 100;
LET varea = 'N';
LET vcliente_ref = '0';
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = '';
LET vclaveelector = '';
LET vclaveidentificacion = '';
LET videntificacion = '';
LET vciudad = 0;
LET vcolonia = 0;
LET vcalle = 0;
LET iNumerocasa = 0;
LET vdeptointerior = '';
LET vrumbo = '';
LET vcomplemento = '';
LET ventrecalles = '';
LET vflaguhc = 0;
LET vuhcmanzana = 0;
LET vuhcotros = 0;
LET vuhcandador = 0;
LET vuhcetapa = 0; 
LET vuhclote  = 0;
LET vuhcedificio = 0;
LET vuhcentrada = 0;
LET vtelefono = 0;
LET vtelefonocelular = 0;
LET vcasapropia = '';
LET vniptitular = '';
LET vnipadicional = '';
LET vsexo = '';
LET vestadocivil = '';
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0;
LET vescolaridad = '';
LET vtiposueldo = '';
LET vnumerodependientes = 0;
LET vpersonastrabajan = 0;
LET vlimitecredito = 0;
LET vingresomensual = 0;
LET vsituacionespecial = '';
LET vcausasituacionespecial = 0;
LET vclaveautrechaza = '2';
LET vaceptadosupervisadorechazado = 'P';
LET vclientenuevo = 'N';
LET vcreditojoven = '';
LET vlugartrabajo = '';
LET vcomplementotrabajo = '';
LET vtelefonotrabajo = 0;
LET vextensiontrabajo = 0;
LET vpuesto = '0';
LET vopcionpuesto = 0;
LET cfechaantiguedtrab = '1900/01/01';
LET vclienteconyuge = '0';
LET vnombreunoconyuge = '';
LET vnombredosconyuge = '';
LET vapellidopaternoconyuge = '';
LET vapellidomaternoconyuge = '';
LET cSexoConyuge = '';
LET vlugartrabajoconyuge = '';
LET vciudadconyuge = 0;
LET vcoloniaconyuge = 0;
LET vcalletrabajoconyuge = 0;
LET iNumerocasaconyuge = 0;
LET vdeptoointeriorconyuge = '';
LET vrumbotrabajoconyuge = '';
LET vcomplementoconyuge = '';
LET ventrecallesconyuge = '';
LET vflaguhy = 0;
LET vuhymanzana = 0;
LET vuhyotros = 0;
LET vuhyandador  = 0;
LET vuhyetapa = 0;
LET vuhylote = 0;
LET vuhyedificio = 0;
LET vuhyentrada = 0;
LET vtelefonotrabajoconyuge = 0;
LET vtelefonocelularconyuge = 0;
LET vclaveconyugefamilia = 'E';
LET vclientereferencia = '0';
LET vnombreunoreferencia = '';
LET vnombredosreferencia = '';
LET vapellidopaternoreferencia = '';
LET vapellidomaternoreferencia = '';
LET cSexoReferencia = '';
LET vclavereferencia1 = '';
LET vclientereferencia2 = '0';
LET vnombreunoreferencia2 = '';
LET vnombredosreferencia2 = '';
LET vapellidopaternoreferencia2 = '';
LET vapellidomaternoreferencia2 = '';
LET cSexoReferencia2 = '';
LET vtelefonoreferencia2 = 0;
LET vclavereferencia2 = '';
LET vreferencia2 = 0;
LET vreferencia3 = 0;
LET vmarcadatosin = '';
LET vtiporeposicion = 0;
LET vreposicion = 0;
LET vflagentregotarjeta = '';
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0';
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = '';
LET vfoliotienda = 0;
LET vrfc = ''; 
LET vcveburo = '';
LET vfolioaut = '';
LET vfolioconsulta = '';
LET vfolioconcir = '';
LET vnegocio = 0;
LET vsubnegocio = 0;
LET vempleadoautorizo = 0;
LET vtipo = '';
LET cfechamovto = '1900/01/01';
LET dFechaRespuesta=DATE(1);
LET dFechaEntrada = DATE(1);
LET dFechaSalida = DATE(1);
LET vnumerosolicituddecredito = '';
LET vnumcte = '';
LET vtiendafolioanterior = 0;
LET vfolioanterior = 0;
LET vclaveproducto = 6500;
LET vflagactualizacion = 0;
LET vSistsegsocial = 0;
LET vTiposueldoext = 0;
LET vNumempleados = 0;
LET vSubopcionpuesto = 99;
LET vPuestoext = 0;
LET vOpcionpuestoext = 0;
LET vNumempleadosext = 0;
LET vSubopcionpuestoext = 0;
LET vTipoOrigen = 'G';
LET vTipoProducto = '01000';
LET iEmpleadoSubCob = 0;
LET sFlagCapHuella = 1;
LET cMarcarConsultado = '';
LET sFlagTestParametrico = 0;
LET sFlagCapCobranza = 0;
LET iEmpleadoGteAutori = 0;
LET cFlagConsBuro = '';
LET cBuroPilotoTestig = '';
LET cNacionalidad = '';
LET cNoFm3 = '';
LET cEmail = '';
LET cApellCasada = '';
LET cPais = '';
LET cNoIMSS = '';
LET cEstado = '';
LET cDelegMunicip = '';
LET cNumInterior = '';
LET sPropNegocio = 0;
LET sParCelulares = 0; 
LET sParAltoRiesgo = 0;
LET sParPrestamo = 0;
LET cModeloCel = '1';
LET dFechaConsBuro = DATE(1);
LET cFechaConsBuro = '';
LET iMontoIngMensual = 0; 
LET iCapSistematicabono = 0;
LET iTopeAbonoCoppel = 0;
LET iLineaCrediTope = 0;
LET iCapMaximaAbono = 0;
LET iCapRealAbono = 0;
LET iLineaCredReal = 0;
LET iCompromisosSic = 0;
LET iFlagLineaCredEsp = 0;
LET cClienteConyugebcpl = '';
LET cClienteReferencia1bcpl = '';
LET cClienteReferencia2bcpl = '';
LET cFolioSucursal = '0';
LET vHora = '';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
LET cUnidadHabit = '';
LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
LET vEdad = 0;
LET vsSQL = "";
LET vVarSeccion2 = "";
LET vVarSeccion1 = "";
LET vVarOSCALLE = "";
LET vVarSeccion4 = "";
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET iValor = 0;
LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET iSecuencia = 0;
LET inumSecuencia= 0;
LET cMarcaHit = '';
LET iElemento = 0;
LET vciudadbanco = 0;
LET vcoloniabanco = 0;
LET iContConsBuro = 0;
LET cDescripElemento = '';
LET iCuentaRegistros = 0;
LET cStatus = '';
LET cStatus2 = '';
LET iRowId = 0;
LET icontador = 0;
LET icontador2 = 0;
LET iSegundaref = 0;
LET cNumSolRef='';
LET cErrorInfo='';
LET iIsamErr='';
LET cDescError='';

BEGIN
	ON EXCEPTION
		SET iSqlErr,iIsamErr,cErrorInfo
		SET DEBUG FILE TO '/RESPALDOSNEW/sp_generaarchivosbatch.out';
		TRACE ON;
            	LET vnumerosolicituddecredito = vnumerosolicituddecredito;
		IF iSqlErr <> 0 THEN
			LET vCodRetorno = iSqlErr;
			LET cDescError= cErrorInfo;
			RETURN vCodRetorno;
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;
	--Set debug file to '/informix/Malena/pruebas_batch.out';
	--trace on;	
	IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		SELECT fecha_hoy INTO vFecha_Hoy FROM "informix".si_fechas;
		IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
			LET vCodRetorno = '000002';
			LET iCuentaRegistros = 2;
		ELSE
		
		UPDATE STATISTICS MEDIUM FOR TABLE si_archivoscopdiario;
		 --Se revisa que la tabla diario no haya quedado con datos de anteriores ejecuciones por causa de algun error en ejecución.
		 IF EXISTS (SELECT 1 FROM "informix".si_archivoscopdiario) THEN 
			DELETE FROM "informix".si_archivoscopdiario;
		 END IF;
		
		SELECT secuencia_max INTO inumSecuencia
		FROM "informix".si_archivosecuenciamax;
		
		LET inumSecuencia = inumSecuencia + 1;
		/*
		IF EXISTS (SELECT 1{+INDEX(si_archivoscoppelhistorial idx_si_archivoscoppelhistorial)} FROM "informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
			IF EXISTS (SELECT 1 FROM "informix".si_archivoscopdiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
				LET inumSecuencia = (SELECT  MAX(secuencia) + 1  FROM "informix".si_archivoscopdiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
			ELSE
				LET inumSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1 {+INDEX(si_archivoscoppelhistorial idx_si_archivoscoppelhistorial)}  FROM "informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
			END IF;
		END IF;*/
		
		
			FOREACH WITH HOLD

				SELECT DISTINCT sss.num_solicitud, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,ssa.status_solicitud, ssos.status, ssos.secuenciaos, ssos.fecha_respuesta 
				INTO vnumerosolicituddecredito, vnumcte, vfechaaltacliente, cFolioSucursal, dFechaAlta,cStatus, vaceptadosupervisadorechazado, vfolio, dFechaRespuesta
				FROM bdisolic:"informix".ss_autorizacion ssa,
				bdisolic:"informix".ss_solicitudes sss
				LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os ssos ON (ssos.empresa = '001' AND ssos.status <> 'P' AND ssos.fecha_respuesta = pFechaAct AND ssos.num_solicitud = sss.num_solicitud)
				WHERE sss.empresa = ssa.empresa
				AND sss.num_solicitud = ssa.num_solicitud			
				AND sss.sucursal=sss.sucursal
				AND ssa.ROWID IN(SELECT MIN(ROWID) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=ssa.num_solicitud AND status_solicitud NOT IN ('PC','AN','CC','OS','CE','CM','MC') AND fecha_entrada =pFechaAct)	
				AND ssa.status_solicitud NOT IN('PC','AN')    
				AND sss.num_producto = '6500'
				AND sss.fecha_insert=sss.fecha_insert
				AND ssa.fecha_entrada =  pFechaAct
						
				LET vsSQL = "";						
				LET vcliente_ref = "0";
				LET cVarReferencia1="";
				LET cVarReferencia2="";
				LET cVarDireccion1="";
				LET cVarDireccion2="";			
				LET vclienteconyuge ='0';
				LET vnombreunoconyuge='';
				LET vnombredosconyuge='';
				LET vapellidopaternoconyuge='';
				LET vapellidomaternoconyuge='';
				LET vclaveconyugefamilia='';
				LET cSexoConyuge='';
				LET iRefSecuencias1 =0;
				LET iRefSecuencias2 =0;
				LET vclientereferencia='0';
				LET vnombreunoreferencia='';
				LET vnombredosreferencia='';
				LET vapellidopaternoreferencia='';
				LET vapellidomaternoreferencia='';
				LET vclavereferencia1='';
				LET cSexoReferencia='';		
				LET icontador = 0;
				LET vlugartrabajo = '';
				LET vlugartrabajoconyuge = '';
				LET cVarConyuge = '';
				LET inumSecuencia = inumSecuencia + 1;
				LET vtelefonotrabajoconyuge =0;
				LET vtelefonocelularconyuge =0;
				LET vtelefonoreferencia2 =0;
				LET iSecuencia=0;
						
						
				IF (cStatus NOT IN ("RT","OS","AT","AP") AND dFechaAlta <> pFechaAct) and  dFechaRespuesta <> pFechaAct THEN
					CONTINUE FOREACH;
				END IF;				
				LET vclave = "";
				IF  dFechaAlta <> vfechaaltacliente THEN --SIGNIFICA QUE SE ORIGINO EN OTRA FECHA, Y NO ES EL PROCESO DE ALTA DE SOLICITUD
					--VALIDAR QUE SI ESTO SE CUMPLE LOS STATUS VALIDOS SON UNICAMENTE AT,RT,AP.
					IF cStatus NOT IN ("RT","AT","AP") AND NVL(vfolio,0) = 0  THEN
						CONTINUE FOREACH;
					END IF;
					 IF cStatus = "RT" OR cStatus = "AT" THEN
						LET vClave = 'M';												
						--LET vclaveautrechaza = '2'; --DEFAULT BLANCO
						LET vaceptadosupervisadorechazado = DECODE (cStatus,"RT","H","AT","A");					
						--LET vclientenuevo = 'N'; --DEFAULT BLANCO				
					ELIF cStatus = "AP"  THEN
						LET vClave = 'A';					
						--LET vclaveautrechaza = '2';
						LET vaceptadosupervisadorechazado = '';
						--LET vclientenuevo = 'N';										
						--INI Clientes Aperturados
						SELECT a.numcte, a.numcte_ref INTO vnumcte, vcliente_ref
						FROM "informix".si_cliente a, "informix".si_adiccoppel b
						WHERE a.numcte = vnumcte AND a.empresa = pempresa AND b.empresa = pempresa AND a.numcte_ref = b.numctecoppel AND a.numcte = b.numcte;
						IF NVL(vnumcte, '') = '' THEN					
							LET vCodRetorno = '000000';
							LET iCuentaRegistros = 2;
							CONTINUE FOREACH;
						ELSE 
							SELECT fechaasignacion INTO vfechaaltacliente FROM bditarjcop:"informix".tarjetasnumtarcop WHERE empresa=pempresa AND cvesucursal=cvesucursal AND numtarjeta = vcliente_ref;
						END IF; 
						--FIN Clientes Aperturados					
					ELSE					
						-----INI JMAH OS CALLE				
							LET vtiendafolio = cFolioSucursal;
						--INI JMAH SE CONSULTA SI SE GENERO UNA OS CALLE PARA LA SOLICITUD EN QUESTION
										
						IF NVL(vfolio,0) =  0 THEN
							LET vfechaaltacliente =dFechaAlta;
							LET vaceptadosupervisadorechazado = 'P';
							LET vfolio = 0;
						END IF;
						--INC 27 017 MEAA			
						IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito) > 1 THEN
							FOREACH
								SELECT FIRST 1 secuenciaos
								INTO vfolioanterior 
								FROM bdisolic:"informix".ss_solicitud_os
								WHERE num_solicitud = vnumerosolicituddecredito AND secuenciaos < vfolio ORDER BY secuenciaos DESC
							END FOREACH						
							LET vtiendafolioanterior = vtiendafolio;						
						END IF;														
						IF vaceptadosupervisadorechazado = 'R' THEN
							LET vaceptadosupervisadorechazado = 'H';
						END IF;			
						LET vClave = 'M';												
						--LET vclaveautrechaza = '2'; --DEFAULT BLANCO
						LET vaceptadosupervisadorechazado = "";					
						--LET vclientenuevo = 'N';						
						-----FIN JMAH OS CALLE						
					END IF;		
				ELSE
					--LET vclaveautrechaza 			= '2';
					LET vaceptadosupervisadorechazado 	= 'P';
					--LET vclientenuevo 				= 'N';
				END IF;
				
				IF vnumerosolicituddecredito <> '' OR vnumcte <> '' THEN 					
				--------procesamiento de información ---SE OBTIENEN DATOS PERSONALES DEL CLIENTE
					
					EXECUTE PROCEDURE "informix".consedadcte(pempresa, vnumcte) INTO vCodRetorno, vNombre, vEdad;
					
					SELECT nombre1, nombre2, apell_paterno, apell_materno, numcte, 
					CASE WHEN "informix".sp_EsNumerico(ejecut_autoriza) = 'V' THEN ejecut_autoriza::INTEGER ELSE 0 END, rfc, fecha_insert, 
					CASE WHEN "informix".sp_EsNumerico(ejecut_autoriza) = 'V' THEN ejecut_autoriza::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(string2)= 'V' THEN string2::INTEGER ELSE 0 END, apell_casada
					INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuo, vrfc, 
					vfechamovto, vefectuo, vpersonasvivenendomicilio, cApellCasada
					FROM "informix".si_cliente cte
					WHERE empresa = pempresa AND numcte = vnumcte;
					
					SELECT estado_civil, curp, numidentifi, codidentifi, habita_en, sexo, fecha_nac, escolaridad,
					nacionalidad, no_fm3, no_imss
					INTO vestadocivil, vcurp, vclaveelector, vclaveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad,
					cNacionalidad, cNoFm3, cNoIMSS
					FROM "informix".si_ctepf iden
					WHERE numcte = vnumcte;		
					
					-- SE ANEXA CONSULTA PARA OBTENER EL CORREO PROPORCIONADO POR EL CLIENTE
					SELECT NVL(correo_elec,'') INTO cEmail 
					FROM bdinteg:"informix".si_correos 
					WHERE numcte = vnumcte AND status_correo = 'A';	
					IF cEmail IS NULL THEN 
						LET cEmail='';
					END IF;
				--INI si_direcciones_actual --JMAH	-CONSULTA LA INFORMACION DE LA DIRECCION DEL CLIENTE					
				FOREACH WITH HOLD

					SELECT CASE WHEN "informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INTEGER ELSE 1 END,
					dir.numerointcalle,dir.puntocardinal,NVL(TRIM(REPLACE(REPLACE(dir.observaciones,'|',' '),'//','/')),''),NVL(TRIM(REPLACE(REPLACE(dir.entre_calles,'|',' '),'//','/')),''), 
					DECODE (dir.unidadhabitac,"S","1","0"), 
					CASE WHEN "informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.lote ) = 'V' THEN dir.lote::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(NVL(tel1.telefono,0)) = 'V' THEN tel1.telefono::INT8 ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(NVL(tel2.telefono,0)) = 'V' THEN tel2.telefono::INT8 ELSE 0 END, dir.tipo_dir, 
					dir.numerointcalle,	dir.pais, dir.estado, 
					CASE WHEN "informix".sp_EsNumerico(NVL(tel3.telefono,0)) = 'V' THEN tel3.telefono::INT8 ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(NVL(tel3.extension,0)) = 'V' THEN tel3.extension::INTEGER ELSE 0 END
					INTO  vciudadbanco, vcoloniabanco, vcalle, iNumerocasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana,	vuhcotros,vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, cPais, cEstado,
					vtelefonotrabajo,vextensiontrabajo
					FROM "informix".si_direcciones_actual dir
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
                    LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )								
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
					WHERE dir.numcte = vnumcte AND dir.tipo_dir IN ('1' ,'2')
					AND dir.secuencia = (SELECT MAX(dir2.secuencia) FROM "informix".si_direcciones_actual dir2 WHERE dir2.numcte = vnumcte AND dir2.tipo_dir = dir.tipo_dir)
					ORDER BY dir.tipo_dir DESC			
					
					-- SE OBTIENE EL NOMBRE DE LA CIUDAD Y COLONIA
					SELECT {+INDEX("informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
					INTO vciudad, vcolonia
					FROM "informix".si_catzonas
					WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
					--SI NO EXISTEN LA CIUDAD Y COLONIA, SE TOMARA DE LA SUCURSAL
					SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
					IF NVL(vciudad, 0) = 0 THEN
						SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
						IF NVL(vciudad, 0) = 0 THEN						
								SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM "informix".si_catzonas where numerociudadcoppel <> 0;
						END IF;
					END IF;
					IF NVL(vcolonia, 0) = 0 THEN											
						SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
						IF NVL(vcolonia, 0) = 0 THEN
							SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM "informix".si_catzonas where numerocoloniacoppel <> 0;
						END IF;
					END IF;		
					
					IF iNumerocasa = 0 AND vTipo_Dir ='2' THEN
						LET iNumerocasa =1;							
					ELIF iNumerocasa = 0 AND vTipo_Dir ='1' THEN
						LET iNumerocasa = 1;
					END IF;		
					IF NVL(vcomplemento, '') = '' THEN LET vcomplemento = 'E'; END IF;
					
					LET cArmadoCadena = "";
					LET cArmadoCadena = NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||TRIM(NVL(vrumbo, ''));
					LET cArmadoCadena = TRIM(cArmadoCadena) ||"|"||TRIM(NVL(vcomplemento, ' '))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, '0')||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0);
					
					IF vTipo_Dir= '2' THEN
						LET cVarDireccion2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajo, 0)||"|"||NVL(vextensiontrabajo, 0);								
					ELSE
						LET cVarDireccion1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0);
					END IF;
				END FOREACH;
 				IF DBINFO("sqlca.sqlerrd2") =	0 THEN	
					LET cArmadoCadena = NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||TRIM(NVL(vrumbo, ''));
					LET cArmadoCadena = TRIM(cArmadoCadena) ||"|"||TRIM(NVL(vcomplemento, ''))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, '0')||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0);										
					LET cVarDireccion2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajo, 0)||"|"||NVL(vextensiontrabajo, 0);		
					LET cVarDireccion1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0);					
			
				ELSE 
					IF DBINFO("sqlca.sqlerrd2") =	1 THEN
					LET cArmadoCadena = NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||TRIM(NVL(vrumbo, ''));
					LET cArmadoCadena = TRIM(cArmadoCadena) ||"|"||TRIM(NVL(vcomplemento, ''))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, '0')||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0);
						IF vTipo_Dir <> '2' THEN
							LET cVarDireccion2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajo, 0)||"|"||NVL(vextensiontrabajo, 0);		
						ELSE
							LET cVarDireccion1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0);
						END IF;						
					END IF;
				END IF 
				LET cArmadoCadena = "";
				--FIN si_direcciones_actual --JMAH
				--SE INICIA OBTENCION DEL INGRESO DEL CLIENTE
					SELECT ing.nombre_empresa, 
					CASE WHEN "informix".sp_EsNumerico(ing.claveopcionpuesto) = 'V' THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(ing.clavesubopcionpuesto) = 'V' THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END --ing.ingreso_mensual
					INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto 
					FROM "informix".si_ingresos ing
					WHERE ing.numcte = vnumcte
					AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM "informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');
					
					IF NVL(vopcionpuesto, '') = '' THEN LET vopcionpuesto = '0'; END IF;
					IF NVL(vSubopcionpuesto, '') = '' THEN LET vSubopcionpuesto = '99'; END IF;
					SELECT tp_ingreso INTO vtiposueldo FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = vnumerosolicituddecredito;
				--FIN DE OBTENCION DE INGRESOS DEL CLIENTE			
				
				--SE CAMBIA EL FORMATO DE LA FECHA NACIMIENTO, EL ALTA DEL CLIENTE Y OBTENCION DE FECHA DE MOVIMIENTOS
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
					LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					IF pFechaAct <> vFecha_Hoy THEN
						LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;					
					--SE OBTIENE IDENTIFICA QUE TIPO DE CREDITOJOVEN ES DEPENDIENDO DE LA EDAD
					--LET vcreditojoven = '';
					/*IF vsexo = 'M' THEN
						IF vEdad >= 16 AND vEdad <= 20 THEN 
							LET vcreditojoven = 'J';
						END IF;
					ELSE
						IF  vsexo = 'F' THEN
							IF vEdad >= 16 AND vEdad <= 17 THEN 
								LET vcreditojoven = 'J';
							END IF;
						END IF;
					END IF;*/
					--SE PONEN VALORES POR DEFAULT
					IF NVL(vcomplementotrabajo, '') = '' THEN
						LET vcomplementotrabajo = 'E';
					END IF;									
					
					LET cClienteConyugebcpl = '0';
					LET cClienteReferencia1bcpl = '0';
					LET cClienteReferencia2bcpl = '0';
					
					--SE OBTIENE NUMERO DE SOLICITUD DE BANCO PARA OBTENER SUS REFERENCIAS EN CASO DE QUE A LA SOLICITUD COPPEL NO SE LE HAYAN HEREDADO POR HABER SIDO RECHAZADA ANTES.
					SELECT num_solicitud
					 INTO cNumSolRef
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa = pempresa
					AND numcte  =vnumcte
					AND fecha_insert = dFechaAlta
					AND num_producto = '6001'
					AND status_solicitud NOT IN ('AN','PC')
                    AND ROWID IN (SELECT MAX(ROWID)
                                    FROM bdisolic:"informix".ss_solicitudes
                                    WHERE empresa = pempresa
                                    AND numcte  = vnumcte
                                    AND fecha_insert = dFechaAlta
                                    AND num_producto = '6001'
                                    AND status_solicitud NOT IN ('AN','PC'));
					  
					  IF NVL(cNumSolRef,'') = '' THEN
							LET cNumSolRef=vnumerosolicituddecredito;
					  END IF;
					
					--INI referencias --JMAH --EN CASO DE ESTAR CASADO CONSULTO AL CONYUGUE
					IF 	vestadocivil = 'C' THEN 
						LET vclaveconyugefamilia = 'E';						
						SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'), nombre1, nombre2, apell_paterno, apell_materno, parentesco, sexo, 
						CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN secuencia::INTEGER ELSE 0 END
						INTO cClienteConyugebcpl,vclienteconyuge,vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,
						vclaveconyugefamilia,cSexoConyuge,iRefSecusConyugue
						FROM "informix".si_refclientes cte2
						WHERE empresa = pempresa AND numcte = vnumcte 
						AND secuencia = (SELECT NVL(MAX(secuencia),0) FROM "informix".si_refclientes WHERE numcte = vnumcte AND parentesco = 'E' AND num_solicitud = cNumSolRef) 
						AND parentesco = 'E' AND num_solicitud = cNumSolRef;	
						
						IF NVL(vclienteconyuge,'') = '' THEN LET vclienteconyuge = '0'; END IF;
						IF NVL(cClienteConyugebcpl,'')='' THEN LET cClienteConyugebcpl='0'; END IF;
						
						SELECT nombre_empresa 
						INTO vlugartrabajoconyuge 
						FROM bdinteg:"informix".si_ingresos 
						WHERE numcte = vclienteconyuge AND empresa = pempresa AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vclienteconyuge AND empresa = pempresa); 
							IF DBINFO("sqlca.sqlerrd2") =	0 THEN														
								LET vlugartrabajoconyuge = '';					
							END IF;
							LET cVarConyuge =TRIM(NVL(vlugartrabajoconyuge, ''));
							--LET cClienteConyugebcpl = vclienteconyuge;					
					END IF;		
					
					IF 	vestadocivil <> 'C' THEN--EN CASO DE ESTAR  SOLTERO CONSULTO LA PENULTIMA REFERENCIA 
						LET vclaveconyugefamilia = '';
						LET icontador2= 0;
						FOREACH WITH HOLD
							SELECT secuencia
								INTO iSegundaref
							FROM "informix".si_refclientes
							WHERE numcte = vnumcte AND parentesco <> 'E'
							AND num_solicitud = cNumSolRef	
							ORDER BY secuencia DESC
							LET icontador2=icontador2 + 1;
								IF icontador2 =2 THEN
									EXIT FOREACH;
								END IF;
						END FOREACH;
										
						SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'),nombre1,nombre2,apell_paterno,apell_materno,parentesco,sexo,
						CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN secuencia::INTEGER ELSE 0 END
						INTO cClienteReferencia1bcpl,vclientereferencia,vnombreunoreferencia,vnombredosreferencia,vapellidopaternoreferencia,vapellidomaternoreferencia,
						vclavereferencia1,cSexoReferencia,iRefSecuencias1
						FROM "informix".si_refclientes cte2
						WHERE empresa = pempresa AND numcte = vnumcte
						AND secuencia = iSegundaref
						AND parentesco <> 'E' AND num_solicitud = cNumSolRef;
						
						IF NVL(vclientereferencia,'') = '' THEN LET vclientereferencia='0'; END IF;
						IF NVL(cClienteReferencia1bcpl,'') = '' THEN LET cClienteReferencia1bcpl = '0'; END IF;						
					END IF;				
					
						--ULTIMA REFERENCIA CAPTURADA
						SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'),nombre1,nombre2,apell_paterno,apell_materno,parentesco,sexo,
						CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN secuencia::INTEGER ELSE 0 END
						INTO cClienteReferencia2bcpl,vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
						vclavereferencia2,cSexoReferencia2,iRefSecuencias2
						FROM "informix".si_refclientes cte2					     
						WHERE empresa = '001' AND numcte = vnumcte
						AND secuencia = (SELECT NVL(MAX(secuencia), 0) FROM "informix".si_refclientes WHERE numcte = vnumcte AND parentesco <> 'E' AND num_solicitud = cNumSolRef)
						AND parentesco <> 'E' AND num_solicitud = cNumSolRef;	
						
					IF NVL(vclientereferencia2, '') = '' THEN LET vclientereferencia2 = '0'; END IF;
					IF NVL(cClienteReferencia2bcpl, '') = '' THEN LET cClienteReferencia2bcpl = '0'; END IF;
					--SI EL CLIENTE ES CASADO SE OBTIENE INFORMACION DE LA ULTIMA REFERENCIA DESPUES DEL CONYUGUE Y LOS CAMPOS DE REFERENCIA 2 QUEDAN VACÍOS						
					IF 	vestadocivil = 'C' THEN
						LET vclientereferencia= vclientereferencia2;
						LET cClienteReferencia1bcpl = cClienteReferencia2bcpl;
						LET vnombreunoreferencia=vnombreunoreferencia2;
						LET vnombredosreferencia=vnombredosreferencia2;
						LET vapellidopaternoreferencia=vapellidopaternoreferencia2;
						LET vapellidomaternoreferencia=vapellidomaternoreferencia2;
						LET vclavereferencia1=vclavereferencia2;
						LET cSexoReferencia=cSexoReferencia2;
						LET iRefSecuencias1=iRefSecusConyugue;						
						LET vclientereferencia2 = '0';
						LET vnombreunoreferencia2 = '';
						LET vnombredosreferencia2 = '';
						LET vapellidopaternoreferencia2 = '';
						LET vapellidomaternoreferencia2 = '';
						LET cSexoReferencia2 = '';
						LET vclavereferencia2 = '';
						LET cClienteReferencia2bcpl='0';
					END IF;				
					--LET cClienteReferencia2bcpl = vclientereferencia2;
					--SE OBTIENE LAS DIRECCIONES DE LAS REFERENCIAS									
					FOREACH WITH HOLD
							SELECT CASE WHEN "informix".sp_EsNumerico(numerociudad) = 'V' THEN numerociudad::INTEGER ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(numerocolonia) = 'V' THEN numerocolonia::INTEGER ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(numerocalle) = 'V' THEN numerocalle::INTEGER ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(numeroextcalle) = 'V' THEN numeroextcalle::INTEGER ELSE 1 END, 
							numerointcalle,puntocardinal,NVL(TRIM(REPLACE(REPLACE(observaciones,'|',' '),'//','/')),''),NVL(TRIM(REPLACE(REPLACE(entre_calles,'|',' '),'//','/')),''),unidadhabitac,
							CASE WHEN "informix".sp_EsNumerico(manzana) = 'V' THEN manzana::SMALLINT ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(otros) = 'V' THEN otros::SMALLINT ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(andador) = 'V' THEN andador::SMALLINT ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(etapa) = 'V' THEN etapa::SMALLINT ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(lote ) = 'V' THEN lote::SMALLINT ELSE 0 END, 
							CASE WHEN "informix".sp_EsNumerico(edificio) = 'V' THEN edificio::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(entrada) = 'V' THEN entrada::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(telefono3) = 'V' THEN telefono3::INT8 ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(telefono2) = 'V' THEN telefono2::INT8 ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(telefono1) = 'V' THEN telefono1::INT8 ELSE 0 END,
							secuencia
							INTO vciudadbanco,vcoloniabanco,vcalletrabajoconyuge,iNumerocasaconyuge,vdeptoointeriorconyuge,vrumbotrabajoconyuge,
							vcomplementoconyuge,ventrecallesconyuge,cflaguht,vuhymanzana,vuhyotros,vuhyandador,vuhyetapa,vuhylote,vuhyedificio,
							vuhyentrada,vtelefonotrabajoconyuge,vtelefonocelularconyuge,vtelefonoreferencia2,iSecuencia
							FROM "informix".si_refdirecciones dir2
							WHERE numcte = vnumcte AND secuencia IN(iRefSecuencias1,iRefSecuencias2)			
							
							--SE OBTIENE EL NOMBRE DE COLONIA Y CIUDAD
							SELECT {+INDEX("informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
							INTO vciudadconyuge, vcoloniaconyuge
							FROM "informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
							--EN CASO DE NO EXISTIR COLONIA Y CIUDAD SE OBTIENEN MEDIANTE LA SUCURSAL
							SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
							IF NVL(vciudadconyuge, 0) = 0 THEN								
								SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
								IF NVL(vciudadconyuge, 0) = 0 THEN	
									SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas where numerociudadcoppel <> 0;
								END IF;
							END IF;
							IF NVL(vcoloniaconyuge, 0) = 0 THEN
								SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
								IF NVL(vcoloniaconyuge, 0) = 0 THEN
									SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerocoloniacoppel <> 0;
								END IF;
							END IF;
							
							IF cflaguht = 'S' THEN
								LET vflaguhy = 1;
							ELSE
								LET vflaguhy = 0;
							END IF;
							IF iNumerocasaconyuge = 0 THEN
								LET iNumerocasaconyuge = 1;
							END IF;
							IF NVL(vcomplementoconyuge, '') = '' THEN
								LET vcomplementoconyuge = 'E';
							END IF;
							LET icontador = icontador+1;
							--SE REALIZA EL ARMADO DE LA CADENA CORRESPONDIENTE A LA INFORMACION DEL CONYUGUE Y LAS REFERENCIAS
							LET cArmadoCadena= NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|"||NVL(vcalletrabajoconyuge, 0)||"|"||NVL(iNumerocasaconyuge, 0)||"|"||TRIM(NVL(vdeptoointeriorconyuge, ''))||"|"||TRIM(NVL(vrumbotrabajoconyuge, ''))||"|"||TRIM(NVL(vcomplementoconyuge, ''))||"|"||TRIM(NVL(ventrecallesconyuge,''));
							LET cArmadoCadena = TRIM(cArmadoCadena)||"|"||NVL(vflaguhy, 0)||"|"||NVL(vuhymanzana, 0)||"|"||NVL(vuhyotros, 0)||"|"||NVL(vuhyandador, 0)||"|"||NVL(vuhyetapa, 0)||"|"||NVL(vuhylote, 0)||"|"||NVL(vuhyedificio, 0)||"|"||NVL(vuhyentrada, 0);
							
							IF iSecuencia = iRefSecuencias1 AND vestadocivil = 'C' THEN												
								LET cVarReferencia2	= "0|0|0|0|||||0|0|0|0|0|0|0|0|0|0|";							
								LET cVarConyuge = TRIM(cVarConyuge)||"|"||TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajoconyuge, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclaveconyugefamilia, ''));
							
							ELIF iSecuencia = iRefSecuencias1 AND vestadocivil <> 'C' THEN	
								LET cVarReferencia1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia1, ''));	
								LET cVarConyuge = "|0|0|0|0|||||0|0|0|0|0|0|0|0|0|0|";								
							ELIF iSecuencia = iRefSecuencias2 THEN
								IF vestadocivil <> 'C' THEN
									LET cVarReferencia2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia2, ''));								
								ELSE
									LET cVarReferencia1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia1, ''));	
								END IF;
							END IF;												
					END FOREACH;
					--EN CASO DE NO INGRESAR AL CICLO ANTERIOR SE ANEXAN VALORES POR DEFAULT PARA LAS DIRECCIONES DE LA O LAS REFERENCIAS QUE NO CUENTAN CON UNA DIRECCION
					IF icontador <=1 THEN																		
						SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;								
								IF NVL(vciudadconyuge, 0) = 0 THEN	
									SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas WHERE numerociudadcoppel <>0;
								END IF;
						SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
								IF NVL(vcoloniaconyuge, 0) = 0 THEN
									SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerocoloniacoppel <>0;
								END IF;	
						LET cVarReferencia2	=  NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|0|0|||E||0|0|0|0|0|0|0|0|0|0|";
						LET cVarReferencia2	=	TRIM(cVarReferencia2)||TRIM(NVL(vclavereferencia2, ''));										
						IF icontador <1 THEN
							IF vestadocivil = 'C' THEN												
								LET cVarReferencia1	= "0|0|0|0|||||0|0|0|0|0|0|0|0|0|0|";
								LET cVarConyuge = TRIM(cVarConyuge)||"|"||NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|0|0|||E||0|0|0|0|0|0|0|0"||"|"||NVL(vtelefonotrabajoconyuge, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclaveconyugefamilia, ''));							
							ELIF vestadocivil <> 'C' THEN	
								LET cVarReferencia1 = NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|0|0|||E||0|0|0|0|0|0|0|0|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia1, ''));	
								LET cVarConyuge = "|0|0|0|0|||||0|0|0|0|0|0|0|0|0|0|";	
							END IF;
						END IF;
					END IF;
					
					--detalle scoring --JMAH -- SE OBTIENE LA RESPUESTA AL PARAMETRICO QUE SE LE REALIZO AL CLIENTE 
					FOREACH WITH HOLD
					SELECT ele.rango_minimo,det.grupo,ele.descripcion
					INTO  iElemento,iGrupo,cDescripElemento
					FROM bdisolic:"informix".ss_detalle_scoring det
					INNER JOIN bdisolic:"informix".ss_scoring_element ele ON ( ele.elemento = det.elemento AND activa = 1 AND det.grupo = ele.grupo)
					WHERE num_solicitud = vnumerosolicituddecredito
					AND det.grupo  IN(11,39,6,8,21) AND det.seccion = 2 AND det.tpo_persona = '01' 	
					
					IF iGrupo = 11 THEN
					 LET vnumerodependientes = iElemento;
					ELIF iGrupo = 39 THEN
					 LET vpersonastrabajan = iElemento;
					ELIF iGrupo = 6 THEN
					  LET cfechadesdecuandovive = YEAR(vfechaaltacliente)-iElemento; 
					  LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||'/01/01';
					ELIF iGrupo = 8 THEN
						IF iElemento = -1 THEN
							SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
							WHERE grupo = 7 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;							
							
							IF iElemento = 15 THEN --Estudiante
								LET cfechaantiguedtrab = vfechanacimiento;
								LET cVarDireccion2= "0|0|0|0|||||0|0|0|0|0|0|0|0|0|0";
								LET vlugartrabajo = ""; --INC 27 017 MEAA
							ELIF iElemento = 12 THEN --Ama de Casa
								LET cfechaantiguedtrab =  cfechadesdecuandovive;
								LET cVarDireccion2= "0|0|0|0|||||0|0|0|0|0|0|0|0|0|0";
								LET vlugartrabajo = "";  --INC 27 017 MEAA
							ELIF iElemento = 6 OR iElemento = 17 THEN --Desempelado, Jubilado o Pensionado
								LET cfechaantiguedtrab = vfechaaltacliente; 	
								LET cVarDireccion2= "0|0|0|0|||||0|0|0|0|0|0|0|0|0|0";
								LET vlugartrabajo = ""; --INC 27 017 MEAA
							END IF;
						ELSE
							LET cfechaantiguedtrab = YEAR(vfechaaltacliente)-iElemento;	
							LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
						END IF;
						
					ELIF iGrupo = 21 THEN
						IF TRIM(cDescripElemento) = "No Estudió" THEN
							LET vescolaridad = '1';						
						ELIF TRIM(cDescripElemento) = "Primaria" THEN
							LET  vescolaridad = '2';
						ELIF TRIM(cDescripElemento) = "Secundaria" THEN
							LET vescolaridad = '3';
						ELIF TRIM(cDescripElemento) = "Carrera Técnica" THEN
							LET vescolaridad = '4';
						ELIF TRIM(cDescripElemento) = "Preparatoria" THEN
							LET vescolaridad = '5';
						ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN
							LET vescolaridad = '6'; 
						END IF;
					END IF;
				END FOREACH;
				--FIN DE OBTENCION DE RESPUESTAS DEL PARAMETRICO
				--SE OBTIENE EL NUMERO DE FOLIO EN BASE A LA RESPUESTA DE LA OS.
					--IF cStatus ='OS' THEN 
					----INC 27 017 MEAA Se corrige la obtención el folio de la secuencia de la OS para que se obtenga el ultimo registro de OS cuando pase por el estatus de OS la solicitud
						SELECT secuenciaos
						INTO  vfolio
						FROM bdisolic:"informix".ss_solicitud_os
						WHERE empresa = pempresa AND status <> 'P' 
						AND fecha_respuesta IN (SELECT MAX(fecha_respuesta) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito)--= pFechaAct
						AND num_solicitud = vnumerosolicituddecredito;	
						IF NVL(vfolio, '') = '' THEN
							LET vfolio = '0';
						END IF;					
					--ELSE
					--	SELECT secuencia INTO vfolio FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND fechasolicitud = fechasolicitud
					--	AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito);
					--	IF NVL(vfolio, '') = '' THEN
					--		SELECT FIRST 1 secuenciaos
					--		INTO vfolioanterior 
					--		FROM bdisolic:"informix".ss_solicitud_os
					--		WHERE num_solicitud = vnumerosolicituddecredito AND secuenciaos < vfolio ORDER BY secuenciaos DESC
							
					--		LET vfolio = '0';
					--	END IF;
					--END IF;
					--SE OBTIENE LA RESPUESTA DE BURO
					SELECT NVL(institucion, ''), fecha_sic INTO cFlagConsBuro, dFechaConsBuro FROM bdisolic:"informix".ss_solicitudes_sic 
					WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito
					AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito);
					IF cFlagConsBuro = 'BC' OR cFlagConsBuro = 'CC' THEN
						LET cBuroPilotoTestig = 'P';
					ELSE
						LET cBuroPilotoTestig = 'T';
					END IF;
					IF NVL(dFechaConsBuro, '') <> '' THEN
						LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
					ELSE
						LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
					END IF;
					SELECT NVL(COUNT(*), 0) INTO iContConsBuro FROM bdisolic:"informix".ss_solicitudes_sic 
					WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito;
					IF iContConsBuro <> 0 THEN
						LET cMarcarConsultado = 'CO';
					ELSE
						LET cMarcarConsultado = 'NC';
					END IF;
					--SE OBTIENE LA INFORMACION CONSULTADA DEL CLIENTE EN COPPEL
					--jmah
					SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumerosolicituddecredito;
					SELECT CASE WHEN "informix".sp_EsNumerico(ingreso_mensual) = 'V' THEN ingreso_mensual::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(cap_sistematica_abono) = 'V' THEN cap_sistematica_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(tope_abonocoppel) = 'V' THEN tope_abonocoppel::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(lineacreditotope) = 'V' THEN lineacreditotope::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(capmaxima_abono) = 'V' THEN capmaxima_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(capreal_abono) = 'V' THEN capreal_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(lineacredito_real) = 'V' THEN lineacredito_real::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(compromisossic) = 'V' THEN compromisossic::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(flaglineacreditoesp) = 'V' THEN flaglineacreditoesp::INTEGER ELSE 0 END,
					limitecredito,
					situacion_especial, case when "informix".sp_EsNumerico(causa_sitesp) = 'V' then causa_sitesp::integer else 0 end
					INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iFlagLineaCredEsp,
					vlimitecredito,vsituacionespecial, vcausasituacionespecial
					FROM bdisolic:"informix".ss_nuevo_parametrico
					WHERE empresa = pempresa AND ROWID = iRowId;
					
					SELECT CASE WHEN "informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
					INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
					
					SELECT ingreso_mensual,evalua_cc ,tp_ingreso INTO iIngreso,cMarcaHit,vtiposueldo FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;
					LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
					IF TRIM(NVL(cMarcaHit, '')) = 'X' THEN
						LET cMarcaHit = 'HT';
					ELSE	
						LET cMarcaHit = 'NH';
					END IF;
					IF vingresomensual < 1 THEN
						LET vingresomensual = 1;
					END IF;	
					
					IF (SELECT NVL(COUNT(*), 0) FROM bdisolic:"informix".ss_os_solautdirecta WHERE num_solicitud = vnumerosolicituddecredito) >= 1 THEN
						LET vsituacionespecial = 'S';
						LET vcausasituacionespecial = 50;					
					END IF;
					-- SE OBTIENE LA MAXIMA SECUENCIA PARA FORMAR UNA NUEVA SECUENCIA A INSERTAR
					SELECT SUM(EVALUACION) INTO iPuntuacion FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion IN(1,2);									
					
					-- GENERACION DE LA TRAMA FINAL
					LET vsSQL = TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))||"|"||TRIM(NVL(vcurp, ''))||"|"||TRIM(NVL(vclaveelector, ''))||"|"||TRIM(NVL(vclaveidentificacion, ''))||"|"||TRIM(videntificacion);
					LET vsSQL = vsSQL ||"|"||TRIM(cVarDireccion1);
					LET vsSQL = vsSQL ||"|"||TRIM(NVL(vcasapropia, ''))||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(NVL(vsexo, ''))||"|"||TRIM(NVL(vestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)||"|"||TRIM(NVL(vescolaridad, ''))||"|"||TRIM(NVL(vtiposueldo, ''));
					LET vsSQL = vsSQL ||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)||"|"||NVL(vingresomensual, 0)||"|"||TRIM(NVL(vsituacionespecial, ''))||"|"||NVL(vcausasituacionespecial, 0);
					LET vVarSeccion1= TRIM(vsSQL);
					LET vVarOSCALLE = TRIM(vclaveautrechaza)||"|"||TRIM(vaceptadosupervisadorechazado)||"|"||TRIM(vclientenuevo);
					LET vsSQL = "";
					LET vsSQL= TRIM(NVL(vcreditojoven, ''))||"|"||TRIM(NVL(vlugartrabajo, ''));					
					LET vsSQL = vsSQL ||"|"||TRIM(cVarDireccion2);
					LET vsSQL = vsSQL||"|"||TRIM(NVL(vpuesto,''))||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||TRIM(NVL(vclienteconyuge,'0'))||"|"||TRIM(NVL(vnombreunoconyuge, ''))||"|"||TRIM(NVL(vnombredosconyuge, ''))||"|"||TRIM(NVL(vapellidopaternoconyuge, ''))||"|"||TRIM(NVL(vapellidomaternoconyuge, ''))||"|"||TRIM(NVL(cSexoConyuge, ''));							
					LET vsSQL = vsSQL ||"|"||TRIM(cVarConyuge);					
					LET vsSQL = vsSQL ||"|"||TRIM(NVL(vclientereferencia,'0'))||"|"||TRIM(NVL(vnombreunoreferencia, ''))||"|"||TRIM(NVL(vnombredosreferencia, ''))||"|"||TRIM(NVL(vapellidopaternoreferencia, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia, ''))||"|"||TRIM(NVL(cSexoReferencia, ''));
					LET vsSQL = vsSQL ||"|"||TRIM(cVarReferencia1);
					LET vsSQL = vsSQL||"|"||TRIM(NVL(vclientereferencia2,'0'))||"|"||TRIM(NVL(vnombreunoreferencia2, ''))||"|"||TRIM(NVL(vnombredosreferencia2, ''))||"|"||TRIM(NVL(vapellidopaternoreferencia2, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia2, ''))||"|" ||TRIM(NVL(cSexoReferencia2, ''));												
					LET vsSQL = vsSQL ||"|"||TRIM(cVarReferencia2);
					LET vsSQL = vsSQL	||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(vmarcadatosin)||"|"||vtiporeposicion||"|"||vreposicion||"|"||TRIM(vflagentregotarjeta)||"|"||NVL(vefectuo, 0)||"|"||TRIM(NVL(cFolioSucursal, '0'));  
					LET vVarSeccion2= TRIM(vsSQL);
					LET vsSQL = "";
					LET vsSQL = vsSQL ||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))||"|"||TRIM(vflagnoreconocehuella)||"|"||vfoliotienda||"|"||TRIM(NVL(vrfc, ''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)||"|"||TRIM(vfolioconcir)||"|"||vnegocio||"|"||vsubnegocio||"|"   
							||vempleadoautorizo||"|"||TRIM(vtipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||TRIM(NVL(vnumerosolicituddecredito, ''))||"|"||TRIM(NVL(vnumcte, ''));
					LET vVarSeccion3= TRIM(vsSQL);
					LET vVarOSCALLE2 = vtiendafolioanterior||"|"||vfolioanterior;
					LET vsSQL = "";
					LET vsSQL = vclaveproducto||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumempleados||"|"||vSubopcionpuesto||"|"||vPuestoext||"|"||vOpcionpuestoext||"|"
							||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"
							||iEmpleadoSubCob||"|"||sFlagCapHuella||"|"||cMarcarConsultado||"|"||sFlagTestParametrico||"|"||sFlagCapCobranza||"|"||iEmpleadoGteAutori||"|"||NVL(cFlagConsBuro,'')||"|"||cBuroPilotoTestig||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"
							||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(NVL(cDelegMunicip,''))||"|"||TRIM(NVL(cNumInterior,''))||"|"||sPropNegocio||"|"||sParCelulares||"|"||sParAltoRiesgo||"|"||sParPrestamo||"|"||cModeloCel||"|"
							||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"
							||TRIM(cClienteConyugebcpl)||"|"||TRIM(cClienteReferencia1bcpl)||"|"||TRIM(cClienteReferencia2bcpl);					
					LET vVarSeccion4 = TRIM(vsSQL);					
					LET vsSQL = "";
					LET vsSQL =   vclave||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(NVL(vVarSeccion1, ''))||"|"||TRIM(NVL(vVarOSCALLE, ''))||"|"||TRIM(NVL(vVarSeccion2, ''))||"|"||TRIM( NVL(vfolio,0) )||TRIM(NVL(vVarSeccion3, ''))||"|"||TRIM(NVL(vVarOSCALLE2, ''))||"|"||TRIM(NVL(vVarSeccion4, ''));
					
					--SE INSERTA LA TRAMA FINAL EN LA TABLA SI_ARCHIVOSCOPPELDIARIO, PERO PARA EFECTO DE PRUEBA SE INSERTARA EN LA TABLA si_archivoscopdiario
					--INSERT INTO "informix".si_archivoscoppeldiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
					--VALUES (pempresa, inumSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);  
					INSERT INTO "informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
					VALUES (pempresa, inumSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);  					
					LET iCuentaRegistros = 1;
					
					--------procesamiento de información-- SE OBTIENE EL SIGUIENTE ESTATUS DEL CLIENTE 
					
					FOREACH 

						SELECT  status_solicitud, fecha_entrada,fecha_salida
						INTO cStatus2, dFechaEntrada,dFechaSalida
						FROM bdisolic:"informix".ss_autorizacion 
						WHERE empresa=pempresa
						AND num_solicitud = vnumerosolicituddecredito
						AND status_solicitud IN('RT','OS','AT','AP')	
					
						IF 	(dFechaEntrada <> pFechaAct AND cStatus2 <>'OS') THEN
							CONTINUE FOREACH;
						ELIF (dFechaEntrada <> pFechaAct AND cStatus2 ='OS') AND cStatus = 'OA' THEN
						    CONTINUE FOREACH;
						ELIF (dFechaSalida <> pFechaAct AND cStatus2 ='OS') THEN
							CONTINUE FOREACH;	
						END IF;
							
						LET vnumerosolicituddecredito = vnumerosolicituddecredito;
						
						IF cStatus = cStatus2 AND dFechaAlta <> pFechaAct THEN						
							CONTINUE FOREACH;					
						END IF;
						
						LET inumSecuencia = inumSecuencia + 1;						
						LET vsSQL = "";						
						LET vcliente_ref = "0";
						--SE IDENTIFICA QUE ESTATUS SE OBTUVO PARA COLOCAR VALORES POR DEFAULT
						IF cStatus2 = "RT" OR cStatus2 = "AT" THEN
							LET vClave = 'M';												
							LET vclaveautrechaza = '2';
							LET vaceptadosupervisadorechazado = DECODE(cStatus2,"RT","H","AT","A");					
							LET vclientenuevo = 'N'; 
							LET vVarOSCALLE = vclaveautrechaza||"|"||vaceptadosupervisadorechazado||"|"||vclientenuevo;
						ELIF cStatus2 = "AP" THEN
							LET vClave = 'A';							
							LET vclaveautrechaza = '2';
							LET vaceptadosupervisadorechazado = '';
							LET vclientenuevo = 'N';
							LET vVarOSCALLE = vclaveautrechaza||"|"||vaceptadosupervisadorechazado||"|"||vclientenuevo;
							SELECT numctecoppel INTO  vcliente_ref FROM  "informix".si_adiccoppel WHERE empresa = pempresa AND numcte = vnumcte;
						ELSE
							-----INI JMAH OS CALLE				
							LET vtiendafolio = cFolioSucursal;
							
							--INI JMAH SE CONSULTA SI SE GENERO UNA OS CALLE PARA LA SOLICITUD EN QUESTION
							SELECT fecha_respuesta, status, secuenciaos
							INTO  vfechaaltacliente, vaceptadosupervisadorechazado, vfolio
							FROM bdisolic:"informix".ss_solicitud_os
							WHERE empresa = pempresa AND status <> 'P' AND fecha_respuesta = pFechaAct
							AND num_solicitud = vnumerosolicituddecredito;	
							
							IF vfechaaltacliente IS NULL THEN 
								CONTINUE FOREACH;
							END IF;
							
							IF NVL(vfolio,0) =  0 THEN
								LET vfechaaltacliente = dFechaAlta;
								LET vaceptadosupervisadorechazado = 'P';
								LET vfolio = 0;
							END IF;
							--SI EXISTE MAS DE UN REGISTRO EN LA SS_SOLICITUD_OS SE OBTIENE LA SECUENCIA MAYOR
							IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito) > 1 THEN
								FOREACH
									SELECT FIRST 1 secuenciaos
									INTO vfolioanterior 
									FROM bdisolic:"informix".ss_solicitud_os
									WHERE num_solicitud = vnumerosolicituddecredito AND secuenciaos < vfolio ORDER BY secuenciaos DESC
								END FOREACH						
								LET vtiendafolioanterior = vtiendafolio;						
							END IF;										
							IF vaceptadosupervisadorechazado = 'R' THEN
								LET vaceptadosupervisadorechazado = 'H';
							END IF;
							LET vclaveautrechaza = '2';							
							LET vclientenuevo = 'N';
							LET vVarOSCALLE = vclaveautrechaza||"|"||vaceptadosupervisadorechazado||"|"||vclientenuevo;
							LET vClave = 'M';
							-----FIN JMAH OS CALLE														
						END IF;						
						LET vVarOSCALLE2 = vtiendafolioanterior||"|"||vfolioanterior;												
						LET vsSQL =   vclave||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(NVL(vcliente_ref,'0'))||"|"||TRIM(NVL(vVarSeccion1, ''))||"|"||TRIM(NVL(vVarOSCALLE, ''))||"|"||TRIM(NVL(vVarSeccion2, ''))||"|"||TRIM( NVL(vfolio,0) )||TRIM(NVL(vVarSeccion3, ''))||"|"||TRIM(NVL(vVarOSCALLE2, ''))||"|"||TRIM(NVL(vVarSeccion4, ''));
					
						--SE INSERTA LA TRAMA FINAL EN LA TABLA SI_ARCHIVOSCOPPELDIARIO, PERO PARA EFECTO DE PRUEBA SE INSERTARA EN LA TABLA si_archivoscopdiario
						--INSERT INTO "informix".si_archivoscoppeldiario (empresa,secuencia, sucursal, trama,tipomovto, fecha_insert)
						--VALUES (pempresa, inumSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);
						
						INSERT INTO "informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama,tipomovto, fecha_insert)
						VALUES (pempresa, inumSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);						
						
						
					END FOREACH;

				ELSE
					LET vCodRetorno = '000003';
					LET iCuentaRegistros = 2;
				END IF;
				
			END FOREACH;
		END IF;
		IF inumSecuencia > 0 THEN
			UPDATE "informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia;
		END IF;		
	
	ELSE
		LET vCodRetorno = '000001';
		LET iCuentaRegistros = 2;
	END IF;
	IF iCuentaRegistros = 1 THEN
		LET vCodRetorno = '000000';
	ELIF iCuentaRegistros = 0 THEN
		LET vCodRetorno = '000005';
	END IF;
	RETURN vCodRetorno;
END;
--*************************************************************************
--| Procedimiento   : "informix".sp_genera_archivosbatch
--| Version         : 1.0
--| Creado por      : Jesus Manuel Aguilar, Maria Elena Angulo.
--| Fecha creacion  : Febrero de 2013
--| Descripcion 	: Reingeniería sobre la generación de las tramas correspondientes a los archivos batch.
--*************************************************************************
END PROCEDURE;