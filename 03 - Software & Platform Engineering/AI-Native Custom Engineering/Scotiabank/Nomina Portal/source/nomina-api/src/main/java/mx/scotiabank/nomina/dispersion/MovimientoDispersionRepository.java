package mx.scotiabank.nomina.dispersion;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MovimientoDispersionRepository extends JpaRepository<MovimientoDispersion, UUID> {
    List<MovimientoDispersion> findByIdDispersion(UUID idDispersion);
}
