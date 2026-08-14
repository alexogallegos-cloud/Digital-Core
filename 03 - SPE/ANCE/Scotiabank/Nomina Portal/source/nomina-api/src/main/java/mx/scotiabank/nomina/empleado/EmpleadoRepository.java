package mx.scotiabank.nomina.empleado;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Todas las consultas se acotan por {@code idEmpresa} (aislamiento multi-tenant).
 */
public interface EmpleadoRepository extends JpaRepository<Empleado, UUID> {

    Optional<Empleado> findByIdEmpleadoAndIdEmpresa(UUID idEmpleado, UUID idEmpresa);

    boolean existsByIdEmpresaAndNumeroEmpleado(UUID idEmpresa, String numeroEmpleado);

    @Query("""
            select e from Empleado e
            where e.idEmpresa = :idEmpresa
              and (:estadoCuenta is null or e.estadoCuenta = :estadoCuenta)
              and (:q is null
                   or lower(e.nombres) like lower(concat('%', :q, '%'))
                   or lower(e.primerApellido) like lower(concat('%', :q, '%'))
                   or e.rfc like concat('%', :q, '%')
                   or e.numeroEmpleado like concat('%', :q, '%'))
            order by e.primerApellido, e.nombres
            """)
    List<Empleado> search(@Param("idEmpresa") UUID idEmpresa,
                          @Param("estadoCuenta") EstadoCuentaEmpleado estadoCuenta,
                          @Param("q") String q,
                          Pageable pageable);

    /**
     * Conteo agrupado por estado de cuenta (dashboard §8). Excluye ELIMINADA
     * (baja lógica). {@code desde} opcional acota por fecha de ingreso (filtro
     * "Intervalo de tiempo" — null = todo el histórico).
     */
    @Query("""
            select e.estadoCuenta, count(e)
            from Empleado e
            where e.idEmpresa = :idEmpresa and e.estadoCuenta <> :excluir
              and (:desde is null or e.fechaIngreso >= :desde)
            group by e.estadoCuenta
            """)
    List<Object[]> conteoPorEstado(@Param("idEmpresa") UUID idEmpresa,
                                   @Param("excluir") EstadoCuentaEmpleado excluir,
                                   @Param("desde") LocalDate desde);

    /** Empleados activos de la empresa (para reporte CSV). Excluye ELIMINADA. */
    List<Empleado> findByIdEmpresaAndEstadoCuentaNotOrderByPrimerApellidoAsc(
            UUID idEmpresa, EstadoCuentaEmpleado excluir);
}
