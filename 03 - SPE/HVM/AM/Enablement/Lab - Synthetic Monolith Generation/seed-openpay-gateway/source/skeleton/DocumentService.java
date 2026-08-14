package com.openpay.dashboard.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 28    FAN-OUT : 4    LOC approx: 317
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class DocumentService {

    // Collaborators (match the graph call edges):
    private final InfRepository039 infRepository039;
    private final InfRepository048 infRepository048;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
