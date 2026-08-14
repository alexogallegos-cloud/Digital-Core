package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 2    FAN-OUT : 6    LOC approx: 476
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService139 {

    // Collaborators (match the graph call edges):
    private final ChnService144 chnService144;
    private final InfRepository048 infRepository048;
    private final InfService167 infService167;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final RskService158 rskService158;
    private final ValidationUtils validationUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
