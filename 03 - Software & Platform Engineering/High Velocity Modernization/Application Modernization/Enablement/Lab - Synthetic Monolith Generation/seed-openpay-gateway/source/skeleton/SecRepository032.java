package com.openpay.api.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : security
//  LAYER     : REPO                 ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 1    LOC approx: 213
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecRequest;
import com.openpay.dto.SecResponse;

@Repository
public class SecRepository032 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
