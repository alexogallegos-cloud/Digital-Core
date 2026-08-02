package mx.scotiabank.nomina.nomina;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NominaRepository extends JpaRepository<Nomina, UUID> {
    Optional<Nomina> findByIdNominaAndIdEmpresa(UUID idNomina, UUID idEmpresa);

    /** Conteo agrupado por estado de nómina (dashboard §8). */
    @Query("""
            select n.estado, count(n)
            from Nomina n
            where n.idEmpresa = :idEmpresa
            group by n.estado
            """)
    List<Object[]> conteoPorEstado(@Param("idEmpresa") UUID idEmpresa);

    long countByIdEmpresa(UUID idEmpresa);

    /** Nóminas de la empresa (para reporte CSV). */
    List<Nomina> findByIdEmpresaOrderByPeriodoInicioDesc(UUID idEmpresa);
}