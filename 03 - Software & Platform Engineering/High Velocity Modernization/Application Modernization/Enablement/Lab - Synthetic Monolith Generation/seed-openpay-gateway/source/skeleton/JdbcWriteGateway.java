package com.openpay.shared.shared;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : shared (WAR)      DOMAIN : shared
//  LAYER     : UTIL                 ACCESS : update (writes)
//  FAN-IN    : 239    FAN-OUT : 0    LOC approx: 172
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;

(static helper)
public class JdbcWriteGateway {

    // Collaborators (match the graph call edges):
    // (no collaborators)

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
