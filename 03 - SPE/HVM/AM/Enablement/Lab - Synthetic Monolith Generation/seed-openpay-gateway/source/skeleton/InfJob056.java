package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : JOB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 6    LOC approx: 278
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Scheduled
public class InfJob056 {

    // Collaborators (match the graph call edges):
    private final InfService020 infService020;
    private final InfService185 infService185;
    private final InfService211 infService211;
    private final InfService240 infService240;
    private final InfService257 infService257;
    private final InfService271 infService271;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
