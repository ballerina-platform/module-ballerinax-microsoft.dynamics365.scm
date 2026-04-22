// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Mock server for Microsoft Dynamics 365 Supply Chain Management.
//
// Hand-written because `bal openapi --mode service` can't handle OData's
// composite-key path syntax (e.g. `/Warehouses(dataAreaId='USMF',WarehouseId='11')`).
// A single catch-all resource dispatches on the first path segment, parses the
// OData key expression if present, and returns hardcoded data from data.bal.
//
// POST / PATCH echo the payload back. DELETE returns 204. There is no mutation,
// so the server is safely concurrent and restart-clean.

import ballerina/http;
import ballerina/lang.regexp;

public type MockServerConfig record {|
    # Port the mock server will listen on.
    int port = 9091;
    # Legal entity returned when the caller does not set `cross-company=true`.
    string defaultCompany = "USMF";
    # Base of the generated `@odata.context` URL.
    string contextBase = "http://localhost:9091/data/";
|};

# Start the mock on the given port. Returns the listener so the caller can stop it from tests.
public isolated function startMock(MockServerConfig config = {}) returns http:Listener|error {
    http:Listener ln = check new (config.port);
    MockService svc = new (config);
    check ln.attach(svc, "/data");
    check ln.'start();
    return ln;
}

isolated service class MockService {
    *http:Service;
    private final MockServerConfig & readonly config;

    isolated function init(MockServerConfig config) {
        self.config = config.cloneReadOnly();
    }

    isolated resource function 'default [string... segments](http:Request req) returns http:Response|error {
        http:Response response = new;

        if segments.length() == 0 {
            response.statusCode = 200;
            response.setJsonPayload({
                "@odata.context": self.config.contextBase + "$metadata",
                "value": []
            });
            return response;
        }

        string firstSeg = segments[0];
        if firstSeg == "$metadata" {
            response.statusCode = 200;
            response.setTextPayload("<edmx:Edmx/>", "application/xml");
            return response;
        }

        [string, map<string>] parsed = parseEntitySetAndKey(firstSeg);
        string entitySet = parsed[0];
        map<string> key = parsed[1];
        map<string[]> queryParams = req.getQueryParams();
        ODataQueries q = parseQueries(queryParams);

        string method = req.method;
        if key.length() == 0 {
            return handleCollection(method, entitySet, q, self.config, req);
        }
        return handleEntity(method, entitySet, key, q, self.config, req);
    }
}

isolated function parseEntitySetAndKey(string segment) returns [string, map<string>] {
    int? openParen = segment.indexOf("(");
    if openParen is () {
        return [segment, {}];
    }
    string entitySet = segment.substring(0, openParen);
    int closeIdx = segment.endsWith(")") ? segment.length() - 1 : segment.length();
    string keyExpr = segment.substring(openParen + 1, closeIdx);

    map<string> key = {};
    regexp:RegExp kvRe = re `(\w+)\s*=\s*'([^']*)'`;
    regexp:Groups[] allGroups = kvRe.findAllGroups(keyExpr);
    foreach regexp:Groups groups in allGroups {
        if groups.length() >= 3 {
            regexp:Span? nameSpan = groups[1];
            regexp:Span? valueSpan = groups[2];
            if nameSpan is regexp:Span && valueSpan is regexp:Span {
                key[nameSpan.substring()] = valueSpan.substring();
            }
        }
    }
    return [entitySet, key];
}

isolated function handleCollection(string method, string entitySet, ODataQueries q,
        MockServerConfig config, http:Request req) returns http:Response|error {
    if method == "GET" {
        json[]? data = dataFor(entitySet);
        if data is () {
            return notFound(entitySet);
        }
        map<json> envelope = buildCollection(config.contextBase, entitySet, data, q, config.defaultCompany);
        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload(envelope);
        return response;
    }
    if method == "POST" {
        json payload = check req.getJsonPayload();
        http:Response response = new;
        response.statusCode = 201;
        response.setJsonPayload(stampEtag(payload));
        return response;
    }
    return methodNotAllowed(method, entitySet);
}

isolated function handleEntity(string method, string entitySet, map<string> key, ODataQueries q,
        MockServerConfig config, http:Request req) returns http:Response|error {
    json[]? data = dataFor(entitySet);
    if data is () {
        return notFound(entitySet);
    }

    if method == "GET" {
        json? found = findByKey(data, key);
        if found is () {
            return notFoundKey(entitySet, key);
        }
        string? selectExpr = q.selectFields;
        if selectExpr is string {
            string[] fields = re `,`.split(selectExpr);
            found = projectRow(found, fields);
        }
        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload(found);
        return response;
    }
    if method == "PATCH" {
        json? existing = findByKey(data, key);
        if existing is () {
            return notFoundKey(entitySet, key);
        }
        json payload = check req.getJsonPayload();
        json merged = payload;
        if existing is map<json> && payload is map<json> {
            map<json> combined = {};
            foreach [string, json] [ek, ev] in existing.entries() {
                combined[ek] = ev;
            }
            foreach [string, json] [pk, pv] in payload.entries() {
                combined[pk] = pv;
            }
            merged = combined;
        }
        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload(stampEtag(merged));
        return response;
    }
    if method == "DELETE" {
        json? existing = findByKey(data, key);
        if existing is () {
            return notFoundKey(entitySet, key);
        }
        http:Response response = new;
        response.statusCode = 204;
        return response;
    }
    return methodNotAllowed(method, entitySet);
}

isolated function dataFor(string entitySet) returns json[]? {
    match entitySet {
        "Warehouses" => {
            return warehouses;
        }
        "WarehouseLocations" => {
            return warehouseLocations;
        }
        "Sites" => {
            return sites;
        }
        "ItemGroups" => {
            return itemGroups;
        }
        "UnitsOfMeasure" => {
            return unitsOfMeasure;
        }
        "BillsOfMaterials" => {
            return billsOfMaterials;
        }
        "BillOfMaterialLines" => {
            return bomLines;
        }
        "ProductionOrderHeaders" => {
            return productionOrders;
        }
        "TransferOrderHeaders" => {
            return transferOrders;
        }
        "InventoryOnHand" => {
            return inventoryOnHand;
        }
        "InventoryJournalHeaders" => {
            return inventoryJournals;
        }
        "SalesShipmentHeaders" => {
            return salesShipments;
        }
    }
    return ();
}

isolated function findByKey(json[] data, map<string> key) returns json? {
    foreach json row in data {
        if !(row is map<json>) {
            continue;
        }
        boolean matches = true;
        foreach [string, string] [k, v] in key.entries() {
            json? rowVal = row[k];
            if !(rowVal is string) || rowVal != v {
                matches = false;
                break;
            }
        }
        if matches {
            return row;
        }
    }
    return ();
}

isolated function stampEtag(json payload) returns json {
    if !(payload is map<json>) {
        return payload;
    }
    map<json> stamped = {};
    foreach [string, json] [k, v] in payload.entries() {
        stamped[k] = v;
    }
    stamped["@odata.etag"] = "W/\"Jzs7MDsxLTExMTExMTEwOyc=\"";
    return stamped;
}

isolated function notFound(string entitySet) returns http:Response {
    http:Response r = new;
    r.statusCode = 404;
    r.setJsonPayload({
        "error": {
            "code": "Resource_EntityNotFound",
            "message": string `No entity set with name '${entitySet}' is exposed by this mock.`
        }
    });
    return r;
}

isolated function notFoundKey(string entitySet, map<string> key) returns http:Response {
    http:Response r = new;
    r.statusCode = 404;
    r.setJsonPayload({
        "error": {
            "code": "Resource_EntityNotFound",
            "message": string `No ${entitySet} record matched key ${key.toString()}.`
        }
    });
    return r;
}

isolated function methodNotAllowed(string method, string entitySet) returns http:Response {
    http:Response r = new;
    r.statusCode = 405;
    r.setJsonPayload({
        "error": {
            "code": "Request_BadRequest",
            "message": string `${method} is not supported on ${entitySet} by this mock.`
        }
    });
    return r;
}
