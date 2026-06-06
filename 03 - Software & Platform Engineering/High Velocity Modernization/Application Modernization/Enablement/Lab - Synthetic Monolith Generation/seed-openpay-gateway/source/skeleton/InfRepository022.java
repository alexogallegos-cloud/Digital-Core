package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : REPO                 ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 1    LOC approx: 212
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Repository
public class InfRepository022 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
