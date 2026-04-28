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

// In-memory stub data for a representative slice of the connector surface.
// Other entity sets respond with an empty collection; more can be stubbed
// from the published metadata as demos require.

final readonly & json[] releasedProducts = [
    {
        "@odata.etag": "W/\"Jzs7MDs7MCcp\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "ProductName": "Surface Pro Hub",
        "ProductDescription": "USB-C docking hub with HDMI, DisplayPort, and Ethernet",
        "ItemModelGroupId": "FIFO",
        "SalesUnitSymbol": "ea"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7MScp\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1002",
        "ProductName": "Surface Travel Mouse",
        "ProductDescription": "Bluetooth ergonomic travel mouse",
        "ItemModelGroupId": "FIFO",
        "SalesUnitSymbol": "ea"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7MicpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-2001",
        "ProductName": "Adventure Works Helmet",
        "ProductDescription": "All-mountain bike helmet, MIPS",
        "ItemModelGroupId": "Std",
        "SalesUnitSymbol": "ea"
    }
];

final readonly & json[] warehouses = [
    {
        "@odata.etag": "W/\"Jzs7MDs7NCcpCw==\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "WarehouseName": "Site 1 - Main",
        "InventorySiteId": "1"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NScpCw==\"",
        "dataAreaId": "USMF",
        "WarehouseId": "12",
        "WarehouseName": "Site 1 - Returns",
        "InventorySiteId": "1"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NicpCw==\"",
        "dataAreaId": "USMF",
        "WarehouseId": "13",
        "WarehouseName": "Site 3 - Overflow",
        "InventorySiteId": "3"
    }
];

final readonly & json[] warehouseLocations = [
    {
        "@odata.etag": "W/\"Jzs7MDs7V0wwMScp\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "WarehouseLocationId": "A-01-01",
        "WarehouseAisleId": "A",
        "WarehouseZoneId": "PICK"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7V0wwMicp\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "WarehouseLocationId": "B-02-04",
        "WarehouseAisleId": "B",
        "WarehouseZoneId": "BULK"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7V0wwMycp\"",
        "dataAreaId": "USMF",
        "WarehouseId": "13",
        "WarehouseLocationId": "OVF-01",
        "WarehouseAisleId": "X",
        "WarehouseZoneId": "OVERFLOW"
    }
];

final readonly & json[] warehousesOnHand = [
    {
        "@odata.etag": "W/\"Jzs7MDs7NycpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "InventorySiteId": "1",
        "InventoryWarehouseId": "11",
        "AvailableOnHandQuantity": 425.0,
        "ReservedOnHandQuantity": 25.0,
        "AvailableOrderedQuantity": 500.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7OCcpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "InventorySiteId": "3",
        "InventoryWarehouseId": "13",
        "AvailableOnHandQuantity": 180.0,
        "ReservedOnHandQuantity": 0.0,
        "AvailableOrderedQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7OScpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1002",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "InventorySiteId": "1",
        "InventoryWarehouseId": "11",
        "AvailableOnHandQuantity": 88.0,
        "ReservedOnHandQuantity": 12.0,
        "AvailableOrderedQuantity": 60.0
    }
];

final readonly & json[] warehousesOnHandV2 = [
    {
        "@odata.etag": "W/\"Jzs7MDs7VjJBJyk=\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "ProductName": "Surface Pro Hub",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "ProductVersionId": "",
        "InventorySiteId": "1",
        "InventoryWarehouseId": "11",
        "OnHandQuantity": 450.0,
        "AvailableOnHandQuantity": 425.0,
        "ReservedOnHandQuantity": 25.0,
        "TotalAvailableQuantity": 925.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7VjJCJyk=\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-2001",
        "ProductName": "Adventure Works Helmet",
        "ProductColorId": "Black",
        "ProductConfigurationId": "",
        "ProductSizeId": "M",
        "ProductStyleId": "",
        "ProductVersionId": "",
        "InventorySiteId": "1",
        "InventoryWarehouseId": "11",
        "OnHandQuantity": 220.0,
        "AvailableOnHandQuantity": 200.0,
        "ReservedOnHandQuantity": 20.0,
        "TotalAvailableQuantity": 200.0
    }
];

final readonly & json[] salesOrderHeadersV2 = [
    {
        "@odata.etag": "W/\"Jzs7MDs7QScpCw==\"",
        "dataAreaId": "USMF",
        "SalesOrderNumber": "SO-100045",
        "OrderingCustomerAccountNumber": "US-001",
        "RequestedShippingDate": "2026-05-02",
        "DeliveryModeCode": "Ground"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7QicpCw==\"",
        "dataAreaId": "USMF",
        "SalesOrderNumber": "SO-100046",
        "OrderingCustomerAccountNumber": "US-002",
        "RequestedShippingDate": "2026-05-03",
        "DeliveryModeCode": "Air"
    }
];

final readonly & json[] salesOrderLines = [
    {
        "@odata.etag": "W/\"Jzs7MDs7U0wwMScp\"",
        "dataAreaId": "USMF",
        "InventoryLotId": "LOT-100045-1",
        "SalesOrderNumber": "SO-100045",
        "LineNumber": 1.0,
        "ItemNumber": "ITM-1001",
        "OrderedSalesQuantity": 10.0,
        "SalesUnitSymbol": "ea",
        "LineAmount": 1990.00
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7U0wwMicp\"",
        "dataAreaId": "USMF",
        "InventoryLotId": "LOT-100045-2",
        "SalesOrderNumber": "SO-100045",
        "LineNumber": 2.0,
        "ItemNumber": "ITM-1002",
        "OrderedSalesQuantity": 4.0,
        "SalesUnitSymbol": "ea",
        "LineAmount": 156.00
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7U0wwMycp\"",
        "dataAreaId": "USMF",
        "InventoryLotId": "LOT-100046-1",
        "SalesOrderNumber": "SO-100046",
        "LineNumber": 1.0,
        "ItemNumber": "ITM-2001",
        "OrderedSalesQuantity": 25.0,
        "SalesUnitSymbol": "ea",
        "LineAmount": 4375.00
    }
];

final readonly & json[] purchaseOrderHeadersV2 = [
    {
        "@odata.etag": "W/\"Jzs7MDs7UE8wMScp\"",
        "dataAreaId": "USMF",
        "PurchaseOrderNumber": "PO-200017",
        "OrderVendorAccountNumber": "V-001",
        "RequestedDeliveryDate": "2026-05-10",
        "DeliveryModeId": "Ground"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7UE8wMicp\"",
        "dataAreaId": "USMF",
        "PurchaseOrderNumber": "PO-200018",
        "OrderVendorAccountNumber": "V-002",
        "RequestedDeliveryDate": "2026-05-12",
        "DeliveryModeId": "Air"
    }
];

final readonly & json[] transferOrderHeaders = [
    {
        "@odata.etag": "W/\"Jzs7MDs7VE8wMScp\"",
        "dataAreaId": "USMF",
        "TransferOrderNumber": "TO-300041",
        "ShippingWarehouseId": "11",
        "RequestedReceiptDate": "2026-05-05",
        "TransferOrderStatus": "Created"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7VE8wMicp\"",
        "dataAreaId": "USMF",
        "TransferOrderNumber": "TO-300042",
        "ShippingWarehouseId": "13",
        "RequestedReceiptDate": "2026-05-08",
        "TransferOrderStatus": "Shipped"
    }
];

final readonly & json[] productionOrderHeaders = [
    {
        "@odata.etag": "W/\"Jzs7MDs7UFAwMScp\"",
        "dataAreaId": "USMF",
        "ProductionOrderNumber": "PROD-500011",
        "ItemNumber": "ITM-2001",
        "ScheduledQuantity": 100.0,
        "ProductionOrderStatus": "Released",
        "ScheduledStartDate": "2026-05-04"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7UFAwMicp\"",
        "dataAreaId": "USMF",
        "ProductionOrderNumber": "PROD-500012",
        "ItemNumber": "ITM-1001",
        "ScheduledQuantity": 250.0,
        "ProductionOrderStatus": "Created",
        "ScheduledStartDate": "2026-05-06"
    }
];
