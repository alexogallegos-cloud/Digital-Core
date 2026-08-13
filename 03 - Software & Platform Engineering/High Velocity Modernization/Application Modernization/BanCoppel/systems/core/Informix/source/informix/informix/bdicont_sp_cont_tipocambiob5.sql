CREATE PROCEDURE "informix".sp_cont_tipocambiob5(pBandera CHAR(2),pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1) ,pClaveTpCambio CHAR(3), 
                                                 pRegistros INTEGER, pRecuperacion INTEGER, pRowId INTEGER, pCveMercado CHAR(1), pDivisa CHAR(2),
                                                 pFechaTpC DATE, pPrecioCpa DECIMAL(14,6), pPrecioVta DECIMAL(14,6), pPrecioVtaA DECIMAL(14,6), pTipoCpaMnDiv DECIMAL(14,6),
                                                 pTipoVtaMnDiv DECIMAL(14,6), pVariacionVta DECIMAL(9,7), pVariacion_cpa DECIMAL(9,7), pTipo_cpa_mn_dll DECIMAL(14,6),
                                                 pTipo_cpa_div_dll DECIMAL(14,6),pTipo_cpa_mn_div DECIMAL(14,6),pPc_abajo DECIMAL(14,6), pPc_arriba DECIMAL(14,6),
                                                 pPrecio_compra DECIMAL(14,6),pPv_abajo DECIMAL(14,6),pVariacion_vta DECIMAL(9,7),pTipo_vta_div_dll DECIMAL(14,6),
		                                         pTipo_vta_mn_dll DECIMAL(14,6),pTipo_vta_mn_div DECIMAL(14,6),pPrecio_venta DECIMAL(14,6),pPv_arriba DECIMAL(14,6),
                                                 pFecha_tpcambio DATE,pClase_tpcambio CHAR(1), pIdOperacion CHAR(1), pFecha DATE)
		RETURNING CHAR(5) AS codret,
			      CHAR(3) AS clave,
			      CHAR(30) AS descripcion,
			      CHAR(2) AS divisa,
                  DATE AS fecha_hoy,
			      DATE AS fecha_ant,
			      DATE AS prox_fecha,
                  INTEGER AS rowid,
				  CHAR(3) AS veIntl,
				  CHAR(1) AS clase_tpcambio,
				  DATE AS fecha_tpcambio,
				  DECIMAL(14,6) AS precio_compra,
				  DECIMAL(14,6) AS precio_venta,
				  DECIMAL(14,6) AS dtipo_cpa_div_dll,
				  DECIMAL(14,6) AS dtipo_cpa_mn_div,
                  DECIMAL(14,6) AS dtipo_cpa_mn_dll,
				  DECIMAL(14,6) AS dtipo_vta_div_dll,
				  DECIMAL(14,6) AS tipo_vta_mn_div,
                  INTEGER AS totalRegistros,
                  CHAR(3) AS cEmpresa,
				  DECIMAL(9,7) AS dvariacion_cpa,
				  DECIMAL(14,6) AS dpc_abajo,
				  DECIMAL(14,6) AS dpc_arriba,
				  DECIMAL(14,6) AS dpv_abajo,
				  DECIMAL(9,7) AS dvariacion_vta,
				  DECIMAL(14,6) AS dtipo_vta_mn_dll,			  
				  DECIMAL(14,6) AS dpv_arriba,
                  CHAR(30) AS departamento,
				  CHAR(45) AS nombre,
				  CHAR(50) AS sistema,
                  CHAR(30) AS cEmpres,
				  CHAR(30) AS cdesc_clase_tc,
                  CHAR(1) AS ejecuta_proceso;
                  
--DECLARACIÃN DE VARIABLES
    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;

	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(3);
	DEFINE cDescripcion CHAR(30);
	DEFINE cDivisa CHAR(2);

    DEFINE dFechaHoy DATE;
	DEFINE dFechaAnt DATE; 
	DEFINE dProxFecha DATE; 

    DEFINE iRowid            INTEGER;
	DEFINE cCveIntl          CHAR(3);
    DEFINE dFecha_tpcambio   DATE;
    DEFINE cClase_tpcambio   CHAR(1);
    DEFINE dPrecio_compra    DECIMAL(14,6);
    DEFINE dPrecio_venta     DECIMAL(14,6);
    DEFINE dTipo_cpa_div_dll DECIMAL(14,6);
    DEFINE dTipo_cpa_mn_div  DECIMAL(14,6);
    DEFINE dTipo_vta_div_dll DECIMAL(14,6);
    DEFINE dTipo_vta_mn_div  DECIMAL(14,6);
    DEFINE iTotalRegistros   INTEGER; 

    DEFINE dPc_arriba       DECIMAL(14,6);
    DEFINE dPc_abajo        DECIMAL(14,6);
    DEFINE dPv_abajo        DECIMAL(14,6);
    DEFINE dPv_arriba       DECIMAL(14,6);
    DEFINE dVariacion_cpa   DECIMAL(9,7);
    DEFINE dVariacion_vta   DECIMAL(9,7);
    DEFINE dTipo_cpa_mn_dll DECIMAL(14,6);
    DEFINE dTipo_vta_mn_dll DECIMAL(14,6);

    DEFINE cDepto 	CHAR(30);
	DEFINE cNombre 	CHAR(45);
	DEFINE cSistema CHAR(50);
	DEFINE cEmpres 	CHAR(30);

	DEFINE cDesc_clase_tc    CHAR(30);
    DEFINE cEjecutaProceso   CHAR(1);
	
--INICIALIZACIÃN DE VARIABLES
    LET cCodRet = '00000';
	LET iSqlErr = 0;

	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET cDivisa = '';

    LET dFechaHoy = '';
	LET dFechaAnt = '';
	LET dProxFecha = '';

    LET iRowid = 0;
	LET cCveIntl = '';
	LET dFecha_tpcambio = NULL;
	LET cClase_tpcambio = '';
	LET dPrecio_compra = 0.000000;
	LET dPrecio_venta = 0.000000;
	LET dTipo_cpa_div_dll = 0.000000;
	LET dTipo_cpa_mn_div = 0.000000;
	LET dTipo_vta_div_dll = 0.000000;
	LET dTipo_vta_mn_div = 0.000000;
    LET iTotalRegistros = 0;

	
    LET dPc_arriba = 0.000000;
	LET dPc_abajo = 0.000000;
	LET dPv_abajo = 0.000000;
	LET dPv_arriba = 0.000000;
	LET dVariacion_cpa = 0.0000000;
	LET dVariacion_vta = 0.0000000;
	LET dTipo_cpa_mn_dll = 0.000000;
	LET dTipo_vta_mn_dll = 0.000000;

    LET cDepto 		= '';
	LET cNombre 	= '';
	LET cSistema 	= '';
	LET cEmpres    = '';
	LET cDesc_clase_tc    = '';
    LET cEjecutaProceso = '';


    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;
            
		END EXCEPTION;

                 
        --SET DEBUG FILE TO '/tmp/mfinis/sp_cont_tipocambiob5.out';
		--TRACE ON;
        
        --ValidaciÃ³n
        IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;
		END IF;

        SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;

        IF pBandera = '1' THEN
        FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_catalogodivisa(pUsuario, pIdFuncion)
            INTO cCodRet, cClave, cDescripcion, cDivisa
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso WITH RESUME;
        END FOREACH

        END IF

         IF pBandera = '2' THEN
         FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_catalogomercado(pUsuario, pIdFuncion)
            INTO cCodRet, cClave, cDescripcion
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso WITH RESUME;
        END FOREACH
        END IF

        IF pBandera = '3' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario , pIdFuncion , pIdConsulta )
            INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;
        END IF

        IF pBandera = '4' THEN
        FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consultatabulartiposcambio(pUsuario , pIdFuncion, UPPER(pClaveTpCambio), pRegistros , pRecuperacion )
            INTO cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				   dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso WITH RESUME;
        END FOREACH

        END IF

        IF pBandera = '5' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consultatabulartiposcambio_totales(pUsuario , pIdFuncion, pClaveTpCambio)
            INTO cCodRet, iTotalRegistros;
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;

        END IF

         IF pBandera = '6' THEN
        FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consultatiposcambio(pUsuario, pIdFuncion, pIdConsulta , pRowId , pCveMercado, pDivisa,
                pFechaTpC, pPrecioCpa, pPrecioVta, pPrecioVtaA, pTipoCpaMnDiv, pTipoVtaMnDiv ,pVariacionVta, pRegistros, pRecuperacion)
            INTO cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
			    dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso WITH RESUME;
            END FOREACH
        END IF

         IF pBandera = '7' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_insertatipocambio(pUsuario , pIdFuncion , pDivisa ,pVariacion_cpa ,
                pTipo_cpa_mn_dll,pTipo_cpa_div_dll ,pTipo_cpa_mn_div ,pPc_abajo , pPc_arriba ,pPrecio_compra ,
                pPv_abajo,pVariacionVta ,pTipo_vta_div_dll,pTipo_vta_mn_dll ,pTipo_vta_mn_div ,pPrecio_venta ,
                pPv_arriba ,pFecha_tpcambio, pClase_tpcambio)
            INTO cCodRet;
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;
        END IF
        IF pBandera = '8' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_operaciones_encabezadotipocambio(pUsuario , pIdFuncion)
            INTO cCodRet, cDepto, cNombre, cSistema, cEmpres;
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;

        END IF

         IF pBandera = '9' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_operacionestipocambio_actualiza_mercado(pUsuario, pIdFuncion , pIdOperacion )
            INTO cCodRet;
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;

        END IF
         IF pBandera = '10' THEN
         FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_reportetipocambio(pUsuario, pIdFuncion, pRegistros, pRecuperacion )
            INTO cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			     dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			     cDescripcion,cDesc_clase_tc
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso WITH RESUME;
        END FOREACH
        END IF

         IF pBandera = '11' THEN
         FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_respaldohistoricotpcambio(pUsuario, pIdFuncion, pIdConsulta , pFecha)
            INTO cCodRet
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso WITH RESUME;
        END FOREACH
        END IF

        IF pBandera = '12' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_validaejecucion(pUsuario, pIdFuncion , pIdConsulta , pFecha)
            INTO cCodRet, cCveIntl;
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;
        END IF

	
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
            RETURN cCodRet, cClave, cDescripcion, cDivisa, dFechaHoy, dFechaAnt, dProxFecha,
                   iRowid,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dtipo_cpa_mn_dll,dTipo_vta_div_dll,
                   dTipo_vta_mn_div,iTotalRegistros,cEmpresa,dVariacion_cpa,dPc_abajo,dPc_arriba,dPv_abajo,dVariacion_vta,
                   dTipo_vta_mn_dll,dPv_arriba,cDepto, cNombre, cSistema, cEmpres,cDesc_clase_tc, cEjecutaProceso;
        END IF

    END;

END PROCEDURE

DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 08/05/2023',
'MODULO: Contabilidad',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL Maestro que se encarga de las funcionalidades de los tipos de cambio.',
'AUTOR: Veronica Sanchez',
'FECHA: 30/11/2023',
'DESCRIPCION: Se realiza actualizaciÃ³n a retorno a bandera 12.',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_si_ejecutb4( 
										  pibandera	 	 INTEGER
										, pscve_usuario	 CHAR(10)
										, pspascode		 CHAR(10)
										  )
RETURNING VARCHAR(6)    as Cod_ret
        , VARCHAR(80)   as Men_ret
        , VARCHAR(3)    as vempresa
        , VARCHAR(8)    as vejecutivo
        , VARCHAR(45)   as vnombre
        , VARCHAR(4)    as vsucursal
        , VARCHAR(3)    as vpuesto
        , VARCHAR(3)    as vdepartamento
        , VARCHAR(80)   as vpASsword
        , VARCHAR(80)   as vpAS_cod
        , VARCHAR(20)   as vnombramiento
        , DECIMAL(16,2) as vlimaut_mn
        , DECIMAL(16,2) as vlimaut_dls
        , DATE		    as vvigencia
        , INTEGER	    as vperfil
        , VARCHAR(80)   as vASistente
        , VARCHAR(30)   as vuser_insert
        , DATE 		    as vfecha_insert
		;

	-- Variables de Errores de sistema 
	DEFINE  SQL_ERR             INTEGER;
	DEFINE  ISAM_ERR            INTEGER;
	DEFINE  ERROR_INFO          varchar(80);
	DEFINE  P_COD_RET           VARCHAR(6);
	DEFINE  P_COD_RET2          VARCHAR(6);
	define  P_MENSAJE           varchar(80);
	
	-- Variables locales
	define vsCodRet  			char(5);
	define vsMensaje_Respuesta  char(80);
	define vsempresa			char(3);
	define vsejecutivo          char(8);
	define vsnombre             char(45);
	define vssucursal           char(4);
	define vspuesto             char(3);
	define vsdepartamento       char(3);
	define vspASsword           char(80);
	define vspAS_cod            char(80);
	define vsnombramiento       char(20);
	define vslimaut_mn          DECIMAL(16,2);
	define vslimaut_dls         DECIMAL(16,2);
	define vsvigencia           date;
	define vsperfil             INTEGER;
	define vsASistente          char(80);
	define vsuser_insert        char(45);
	define vsfecha_insert       DATE;
	
	-- InicializaciÃÂ³n de Variables de ciclo
	let	vsCodRet 			 = '00000';
	let	vsMensaje_Respuesta  = 'PROCESO TERMINADO SATISFACTORIAMENTE';
	let vsempresa			 = '';		
	let vsejecutivo          = '';
	let vsnombre             = '';
	let vssucursal           = '';
	let vspuesto             = '';
	let vsdepartamento       = '';
	let vspASsword           = '';
	let vspAS_cod            = '';
	let vsnombramiento       = '';
	let vslimaut_mn          = NULL;
	let vslimaut_dls         = NULL;
	let vsvigencia           = NULL;
	let vsperfil             = NULL;
	let vsASistente          = '';
	let vsuser_insert        = '';
	let vsfecha_insert       = NULL;
	
	BEGIN
	
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		--SET DEBUG FILE TO '/informix/JCQB/sp_analisiscuentas.err';
		--TRACE ON;
		LET P_COD_RET  = SQL_ERR;
		LET P_COD_RET2 = ISAM_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		RETURN P_COD_RET, P_MENSAJE, null, null, null, null     
								   , null, null, null, null      
								   , null, null, null, null     
								   , null, null, null, null;

	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/JCQB/sp_analisiscuentas.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF pibandera = 1 THEN
		FOREACH
			SELECT empresa
				 , ejecutivo
				 , nombre
				 , sucursal
				 , puesto
				 , departamento
				 , password
				 , pass_cod
				 , nombramiento
				 , limaut_mn
				 , limaut_dls
				 , vigencia
				 , perfil
				 , ASistente
				 , user_insert
				 , fecha_insert
			  INTO vsempresa		
				 , vsejecutivo    
				 , vsnombre       
				 , vssucursal     
				 , vspuesto       
				 , vsdepartamento 
				 , vspASsword     
				 , vspAS_cod      
				 , vsnombramiento 
				 , vslimaut_mn    
				 , vslimaut_dls   
				 , vsvigencia     
				 , vsperfil       
				 , vsASistente    
				 , vsuser_insert  
				 , vsfecha_insert 			 
			  FROM bdinteg:"informix".si_ejecut 
			 WHERE ejecutivo = pscve_usuario
			   AND pASs_cod = pspascode
	  
			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, NVL(vsnombre,'') , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
														WITH RESUME;
			
		END FOREACH;
	ELIF pibandera = 2 THEN

		FOREACH
			SELECT sucursal 
			  INTO vssucursal
			  FROM bdinteg:"informix".si_ejecut 
			 WHERE empresa   = '001' 
			   AND ejecutivo = pscve_usuario

			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
														WITH RESUME;
			   
		END FOREACH;

	ELIF pibandera = 3 THEN

		FOREACH
			SELECT a.perfil
				 , b.sucursal
			  INTO vsperfil
				 , vssucursal
			  FROM bdinteg:si_perfil_ejecut a
				 , bdinteg:"informix".si_ejecut b 
			 WHERE a.perfil    = '703' 
			   AND a.cod_emp   = '001' 
			   AND a.ejecutivo = b.ejecutivo
			   AND a.ejecutivo = pscve_usuario 

			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
														WITH RESUME;			   
		
		END FOREACH;
	ELIF pibandera = 4 THEN

			SELECT nombre 
			  INTO vsnombre
			  FROM bdinteg:"informix".si_ejecut 
			 WHERE empresa   = '001' 
			   AND ejecutivo = pscve_usuario;

			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert;

	ELSE
		let	vsCodRet 			 = '00001';
		let	vsMensaje_Respuesta  = 'NO EXISTE LA OPCION';
		let vsempresa			 = '';		
		let vsejecutivo          = '';
		let vsnombre             = '';
		let vssucursal           = '';
		let vspuesto             = '';
		let vsdepartamento       = '';
		let vspASsword           = '';
		let vspAS_cod            = '';
		let vsnombramiento       = '';
		let vslimaut_mn          = NULL;
		let vslimaut_dls         = NULL;
		let vsvigencia           = NULL;
		let vsperfil             = NULL;
		let vsASistente          = '';
		let vsuser_insert        = '';
		let vsfecha_insert       = NULL;
	
			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert;
	
	END IF;
	
	END 
	
END PROCEDURE;