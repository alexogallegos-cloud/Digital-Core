package com.openpay.api.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : security
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 67
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecEntity;
import com.openpay.dto.SecRequest;
import com.openpay.dto.SecResponse;

@RestController
public class SecController037 {

    // Collaborators (match the graph call edges):
    private final SecService181 secService181;
    private final SecService238 secService238;
    private final SecService248 secService248;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
