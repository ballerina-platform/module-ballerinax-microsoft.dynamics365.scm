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

// Integration tests. A mock D365 SCM service (modules/mock.server) is started
// before the suite, a Client is pointed at it, every remote function is
// exercised, and shape/value assertions are made against the stub data
// shipped in modules/mock.server/data.bal.

import ballerina/http;
import ballerina/test;
import ballerinax/microsoft.dynamics365.scm.mock.server;

const int MOCK_PORT = 9091;
const string MOCK_URL = "http://localhost:9091/data";

http:Listener mockListener = check new (MOCK_PORT);
Client scmClient = check new (
    config = {
        auth: {token: "demo-bearer-token"}
    },
    serviceUrl = MOCK_URL
);

@test:BeforeSuite
function startMockServer() returns error? {
    mockListener = check server:startMock({port: MOCK_PORT, contextBase: MOCK_URL + "/"});
}

@test:AfterSuite
function stopMockServer() returns error? {
    check mockListener.gracefulStop();
}

// ---- Warehouses ----------------------------------------------------------

@test:Config
function testListWarehousesDefaultCompany() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses();
    Warehouse[] rows = <Warehouse[]>response.value;
    test:assertTrue(rows.length() >= 3, "expected at least 3 USMF warehouses");
    foreach Warehouse w in rows {
        test:assertEquals(w.dataAreaId, "USMF");
    }
}

@test:Config
function testListWarehousesCrossCompanyAndCount() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses(queries = {crossCompany: true, count: true});
    int? count = <int?>response["@odata.count"];
    test:assertTrue(count is int && count >= 5, "cross-company should return all 5 seeded warehouses with count");
}

@test:Config
function testListWarehousesFilterType() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses(
        queries = {filter: "WarehouseTypeId eq 'Transit'"}
    );
    Warehouse[] rows = <Warehouse[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertEquals(rows[0].WarehouseTypeId, "Transit");
}

@test:Config
function testGetWarehouse() returns error? {
    Warehouse w = check scmClient->getWarehouse(dataAreaId = "USMF", warehouseId = "11");
    test:assertEquals(w.WarehouseName, "West Seattle Distribution Center");
    test:assertEquals(w.SiteId, "1");
}

@test:Config
function testGetWarehouseSelect() returns error? {
    Warehouse w = check scmClient->getWarehouse(
        dataAreaId = "USMF",
        warehouseId = "11",
        queries = {selectFields: "WarehouseId,WarehouseName"}
    );
    test:assertEquals(w.WarehouseId, "11");
    test:assertEquals(w.WarehouseName, "West Seattle Distribution Center");
    test:assertTrue(w.SiteId is (), "$select should have dropped unprojected fields");
}

@test:Config
function testCreateWarehouse() returns error? {
    Warehouse draft = {
        dataAreaId: "USMF",
        WarehouseId: "99",
        WarehouseName: "Integration Test Warehouse",
        SiteId: "1",
        WarehouseTypeId: "Default",
        IsInventoryCountingEnabled: "Yes",
        IsWMSManaged: "No"
    };
    Warehouse created = check scmClient->createWarehouse(payload = draft);
    test:assertEquals(created.WarehouseId, "99");
    test:assertTrue(created["@odata.etag"] is string);
}

@test:Config
function testUpdateWarehouse() returns error? {
    Warehouse patch = {IsWMSManaged: "Yes", PrimaryAddressCity: "Portland"};
    Warehouse updated = check scmClient->updateWarehouse(
        dataAreaId = "USMF",
        warehouseId = "13",
        payload = patch
    );
    test:assertEquals(updated.IsWMSManaged, "Yes");
    test:assertEquals(updated.PrimaryAddressCity, "Portland");
    test:assertEquals(updated.WarehouseName, "Atlanta Regional Hub", "PATCH should preserve untouched fields");
}

// ---- Warehouse locations --------------------------------------------------

@test:Config
function testListWarehouseLocations() returns error? {
    WarehouseLocationsCollection response = check scmClient->listWarehouseLocations(
        queries = {filter: "WarehouseId eq '11'"}
    );
    WarehouseLocation[] rows = <WarehouseLocation[]>response.value;
    test:assertTrue(rows.length() >= 3);
    foreach WarehouseLocation l in rows {
        test:assertEquals(l.WarehouseId, "11");
    }
}

// ---- Sites ---------------------------------------------------------------

@test:Config
function testListSites() returns error? {
    SitesCollection response = check scmClient->listSites(queries = {crossCompany: true});
    Site[] rows = <Site[]>response.value;
    test:assertTrue(rows.length() >= 4);
}

// ---- Item groups ---------------------------------------------------------

@test:Config
function testListItemGroups() returns error? {
    ItemGroupsCollection response = check scmClient->listItemGroups();
    ItemGroup[] rows = <ItemGroup[]>response.value;
    test:assertTrue(rows.length() >= 4);
}

// ---- Units of measure (global; no cross-company) -------------------------

@test:Config
function testListUnitsOfMeasure() returns error? {
    UnitsOfMeasureCollection response = check scmClient->listUnitsOfMeasure();
    UnitOfMeasure[] rows = <UnitOfMeasure[]>response.value;
    test:assertTrue(rows.length() >= 5, "units of measure are global reference data");
    foreach UnitOfMeasure u in rows {
        test:assertTrue(u.Symbol is string);
    }
}

@test:Config
function testListUnitsOfMeasureFilterMetric() returns error? {
    UnitsOfMeasureCollection response = check scmClient->listUnitsOfMeasure(
        queries = {filter: "SystemOfUnits eq 'Metric'"}
    );
    UnitOfMeasure[] rows = <UnitOfMeasure[]>response.value;
    test:assertTrue(rows.length() >= 2);
    foreach UnitOfMeasure u in rows {
        test:assertEquals(u.SystemOfUnits, "Metric");
    }
}

// ---- Bills of materials --------------------------------------------------

@test:Config
function testListBomsFilterApproved() returns error? {
    BillsOfMaterialsCollection response = check scmClient->listBillsOfMaterials(
        queries = {filter: "IsApproved eq 'Yes'"}
    );
    BillOfMaterials[] rows = <BillOfMaterials[]>response.value;
    test:assertTrue(rows.length() >= 2);
    foreach BillOfMaterials b in rows {
        test:assertEquals(b.IsApproved, "Yes");
    }
}

@test:Config
function testGetBillOfMaterials() returns error? {
    BillOfMaterials b = check scmClient->getBillOfMaterials(
        dataAreaId = "USMF",
        billOfMaterialsId = "BOM-HUB-001"
    );
    test:assertEquals(b.BillOfMaterialsName, "Surface Pro Hub - Standard");
    test:assertEquals(b.IsApproved, "Yes");
}

@test:Config
function testCreateBom() returns error? {
    BillOfMaterials draft = {
        dataAreaId: "USMF",
        BillOfMaterialsId: "BOM-TEST-001",
        BillOfMaterialsName: "Test BOM via Ballerina",
        SiteId: "1",
        ItemGroupId: "ELEC",
        IsApproved: "No",
        ActivationDate: "2026-06-01"
    };
    BillOfMaterials created = check scmClient->createBillOfMaterials(payload = draft);
    test:assertEquals(created.BillOfMaterialsId, "BOM-TEST-001");
}

@test:Config
function testListBomLines() returns error? {
    BillOfMaterialLinesCollection response = check scmClient->listBillOfMaterialLines(
        queries = {filter: "BillOfMaterialsId eq 'BOM-HUB-001'"}
    );
    BillOfMaterialLine[] rows = <BillOfMaterialLine[]>response.value;
    test:assertTrue(rows.length() >= 3);
    foreach BillOfMaterialLine l in rows {
        test:assertEquals(l.BillOfMaterialsId, "BOM-HUB-001");
    }
}

// ---- Production orders ---------------------------------------------------

@test:Config
function testListProductionOrdersPaging() returns error? {
    ProductionOrderHeadersCollection page1 = check scmClient->listProductionOrders(
        queries = {top: 2, skip: 0, count: true, crossCompany: true}
    );
    ProductionOrderHeader[] rows1 = <ProductionOrderHeader[]>page1.value;
    test:assertEquals(rows1.length(), 2);
    int? total = <int?>page1["@odata.count"];
    test:assertTrue(total is int && total >= 5);

    ProductionOrderHeadersCollection page2 = check scmClient->listProductionOrders(
        queries = {top: 2, skip: 2, crossCompany: true}
    );
    ProductionOrderHeader[] rows2 = <ProductionOrderHeader[]>page2.value;
    test:assertTrue(rows2.length() > 0);
    test:assertNotEquals(rows1[0].ProductionOrderNumber, rows2[0].ProductionOrderNumber);
}

@test:Config
function testGetProductionOrder() returns error? {
    ProductionOrderHeader p = check scmClient->getProductionOrder(
        dataAreaId = "USMF",
        productionOrderNumber = "PRD-2026-0001"
    );
    test:assertEquals(p.ItemNumber, "ITM-1001");
    test:assertEquals(p.ProductionStatus, "Released");
}

@test:Config
function testCreateProductionOrder() returns error? {
    ProductionOrderHeader draft = {
        dataAreaId: "USMF",
        ProductionOrderNumber: "PRD-DEMO-001",
        ItemNumber: "ITM-1002",
        ProductionQuantity: 50.0,
        UnitSymbol: "ea",
        SiteId: "1",
        WarehouseId: "11",
        ProductionStatus: "Created"
    };
    ProductionOrderHeader created = check scmClient->createProductionOrder(payload = draft);
    test:assertEquals(created.ProductionOrderNumber, "PRD-DEMO-001");
}

// ---- Transfer orders -----------------------------------------------------

@test:Config
function testListTransferOrdersOrderByShipDate() returns error? {
    TransferOrderHeadersCollection response = check scmClient->listTransferOrders(
        queries = {orderBy: "ShippingDate desc"}
    );
    TransferOrderHeader[] rows = <TransferOrderHeader[]>response.value;
    test:assertTrue(rows.length() >= 2);
    // desc means first >= second
    if rows.length() >= 2 {
        string first = <string>rows[0].ShippingDate;
        string second = <string>rows[1].ShippingDate;
        test:assertTrue(first >= second, "results should be sorted by ShippingDate descending");
    }
}

@test:Config
function testGetTransferOrder() returns error? {
    TransferOrderHeader t = check scmClient->getTransferOrder(
        dataAreaId = "USMF",
        transferOrderNumber = "TO-2026-0101"
    );
    test:assertEquals(t.ShippingWarehouseId, "11");
    test:assertEquals(t.TransferStatus, "Shipped");
}

// ---- Inventory on-hand ---------------------------------------------------

@test:Config
function testListInventoryOnHandForItem() returns error? {
    InventoryOnHandCollection response = check scmClient->listInventoryOnHand(
        queries = {
            filter: "ItemNumber eq 'ITM-1001'",
            crossCompany: true
        }
    );
    InventoryOnHand[] rows = <InventoryOnHand[]>response.value;
    test:assertTrue(rows.length() >= 2);
    foreach InventoryOnHand r in rows {
        test:assertEquals(r.ItemNumber, "ITM-1001");
    }
}

// ---- Inventory journals --------------------------------------------------

@test:Config
function testListInventoryJournalsPostedOnly() returns error? {
    InventoryJournalHeadersCollection response = check scmClient->listInventoryJournalHeaders(
        queries = {filter: "IsPosted eq 'Yes'"}
    );
    InventoryJournalHeader[] rows = <InventoryJournalHeader[]>response.value;
    test:assertTrue(rows.length() >= 2);
    foreach InventoryJournalHeader j in rows {
        test:assertEquals(j.IsPosted, "Yes");
    }
}

// ---- Sales shipments -----------------------------------------------------

@test:Config
function testListSalesShipments() returns error? {
    SalesShipmentHeadersCollection response = check scmClient->listSalesShipments(
        queries = {orderBy: "PackingSlipDate desc"}
    );
    SalesShipmentHeader[] rows = <SalesShipmentHeader[]>response.value;
    test:assertTrue(rows.length() >= 2);
}

@test:Config
function testFilterByNumericEqMatchesDecimalSeed() returns error? {
    // Seeded InventoryOnHand row for ITM-1001 at warehouse 11 has
    // AvailablePhysicalQuantity = 425.0 (decimal). Filter `eq 425` was
    // previously lost because int-RHS and decimal-LHS never matched.
    InventoryOnHandCollection response = check scmClient->listInventoryOnHand(
        queries = {filter: "AvailablePhysicalQuantity eq 425"}
    );
    InventoryOnHand[] rows = <InventoryOnHand[]>response.value;
    test:assertEquals(rows.length(), 1, "numeric equality should match the seeded decimal row");
    test:assertEquals(rows[0].ItemNumber, "ITM-1001");
}

@test:Config
function testOrderByNumericDescSortsNumerically() returns error? {
    InventoryOnHandCollection response = check scmClient->listInventoryOnHand(
        queries = {
            orderBy: "AvailablePhysicalQuantity desc",
            crossCompany: true
        }
    );
    InventoryOnHand[] rows = <InventoryOnHand[]>response.value;
    test:assertTrue(rows.length() >= 3);
    decimal first = rows[0].AvailablePhysicalQuantity ?: 0d;
    decimal second = rows[1].AvailablePhysicalQuantity ?: 0d;
    test:assertTrue(first >= second, "numeric desc should put the larger available quantity first");
}

@test:Config
function testUpdateWarehouseMissingKeyReturns404() returns error? {
    Warehouse patch = {WarehouseName: "ghost"};
    Warehouse|error result = scmClient->updateWarehouse(
        dataAreaId = "USMF",
        warehouseId = "DOES-NOT-EXIST",
        payload = patch
    );
    test:assertTrue(result is error, "PATCH on missing key should surface an error from the 404");
}

@test:Config
function testNegativeTopDoesNotPanic() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses(
        queries = {top: -1}
    );
    Warehouse[] rows = <Warehouse[]>response.value;
    test:assertTrue(rows.length() > 0, "negative $top should be ignored, not panic");
}
