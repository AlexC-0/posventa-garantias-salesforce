/** Integridad referencial P04. No evalúa cobertura ni implementa permisos de negocio. */
public without sharing class P04Integridad {
    public static final Id PRODUCTO = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get('P04_Producto').getRecordTypeId();
    public static final Id CASO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('P04_Posventa').getRecordTypeId();

    public static void actualizarCasos(List<Case> rows, Map<Id, Case> anteriores) {
        for (Case row : rows) {
            if (anteriores.get(row.Id).RecordTypeId == CASO && row.RecordTypeId != CASO) {
                row.addError('P04: no se puede retirar un caso del ámbito de posventa.');
            }
        }
    }

    public static void actualizarProductos(List<Asset> rows, Map<Id, Asset> anteriores) {
        Set<Id> cambiados = new Set<Id>();
        for (Asset row : rows) {
            Asset old = anteriores.get(row.Id);
            if (old.RecordTypeId == PRODUCTO && row.RecordTypeId != PRODUCTO) {
                row.addError('P04: no se puede retirar un producto del ámbito de posventa.');
            }
            if (row.AccountId != old.AccountId || row.PurchaseDate != old.PurchaseDate) {
                cambiados.add(row.Id);
            }
        }
        if (cambiados.isEmpty()) return;
        Map<Id, Date> primeras = new Map<Id, Date>();
        for (AggregateResult r : [
            SELECT AssetId producto, MIN(P04_FechaIncidencia__c) primera
            FROM Case WHERE RecordTypeId = :CASO AND AssetId IN :cambiados WITH SYSTEM_MODE GROUP BY AssetId
        ]) {
            primeras.put((Id)r.get('producto'), (Date)r.get('primera'));
        }
        for (Asset row : rows) {
            if (!primeras.containsKey(row.Id)) continue;
            if (row.AccountId != anteriores.get(row.Id).AccountId) {
                row.addError('P04: un producto con casos no puede cambiar de cliente.');
            }
            Date primera = primeras.get(row.Id);
            if (row.PurchaseDate != null && primera != null && row.PurchaseDate > primera) {
                row.addError('P04: la compra no puede ser posterior a una incidencia existente.');
            }
        }
    }

    private static Set<Id> contactosReferenciados(Set<Id> ids) {
        Set<Id> usados = new Set<Id>();
        if (ids.isEmpty()) return usados;
        for (AggregateResult r : [
            SELECT ContactId contacto FROM Asset
            WHERE RecordTypeId = :PRODUCTO AND ContactId IN :ids WITH SYSTEM_MODE GROUP BY ContactId
        ]) usados.add((Id)r.get('contacto'));
        for (AggregateResult r : [
            SELECT ContactId contacto FROM Case
            WHERE RecordTypeId = :CASO AND ContactId IN :ids WITH SYSTEM_MODE GROUP BY ContactId
        ]) usados.add((Id)r.get('contacto'));
        return usados;
    }

    public static void actualizarContactos(List<Contact> rows, Map<Id, Contact> anteriores) {
        Set<Id> cambiados = new Set<Id>();
        for (Contact row : rows) {
            if (row.AccountId != anteriores.get(row.Id).AccountId) cambiados.add(row.Id);
        }
        Set<Id> usados = contactosReferenciados(cambiados);
        for (Contact row : rows) {
            if (usados.contains(row.Id)) {
                row.addError('P04: un contacto utilizado en posventa no puede cambiar de cliente.');
            }
        }
    }

    public static void borrarContactos(List<Contact> rows) {
        Set<Id> usados = contactosReferenciados(new Map<Id, Contact>(rows).keySet());
        for (Contact row : rows) {
            if (usados.contains(row.Id)) row.addError('P04: el contacto tiene referencias de posventa.');
        }
    }

    public static void borrarProductos(List<Asset> rows) {
        Set<Id> ids = new Map<Id, Asset>(rows).keySet();
        Set<Id> usados = new Set<Id>();
        for (AggregateResult r : [
            SELECT AssetId producto FROM Case
            WHERE RecordTypeId = :CASO AND AssetId IN :ids WITH SYSTEM_MODE GROUP BY AssetId
        ]) usados.add((Id)r.get('producto'));
        for (Asset row : rows) {
            if (usados.contains(row.Id)) row.addError('P04: el producto tiene casos de posventa.');
        }
    }

    public static void borrarCuentas(List<Account> rows) {
        Set<Id> ids = new Map<Id, Account>(rows).keySet();
        Set<Id> usados = new Set<Id>();
        for (AggregateResult r : [
            SELECT AccountId cliente FROM Asset
            WHERE RecordTypeId = :PRODUCTO AND AccountId IN :ids WITH SYSTEM_MODE GROUP BY AccountId
        ]) usados.add((Id)r.get('cliente'));
        for (AggregateResult r : [
            SELECT AccountId cliente FROM Case
            WHERE RecordTypeId = :CASO AND AccountId IN :ids WITH SYSTEM_MODE GROUP BY AccountId
        ]) usados.add((Id)r.get('cliente'));
        for (Account row : rows) {
            if (usados.contains(row.Id)) row.addError('P04: el cliente tiene referencias de posventa.');
        }
    }
}