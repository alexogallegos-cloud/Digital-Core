package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 4    FAN-OUT : 5    LOC approx: 313
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService020 {

    // Collaborators (match the graph call edges):
    private final InfRepository016 infRepository016;
    private final InfRepository039 infRepository039;
    private final InfService006 infService006;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
