// In-memory stub data used by the mock server.
// Shapes match the schemas declared in docs/spec/openapi.json.
// Records are hand-authored to look realistic for UI-editor demos.

final readonly & json[] warehouses = [
    {
        "@odata.etag": "W/\"JzEsMTExMDAwMTswOzA7TDswJyk=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "WarehouseName": "West Seattle Distribution Center",
        "SiteId": "1",
        "WarehouseTypeId": "Default",
        "PrimaryAddressStreet": "3400 Harbor Ave SW",
        "PrimaryAddressCity": "Seattle",
        "PrimaryAddressState": "WA",
        "PrimaryAddressZipCode": "98126",
        "PrimaryAddressCountryRegionId": "USA",
        "IsInventoryCountingEnabled": "Yes",
        "IsWMSManaged": "Yes"
    },
    {
        "@odata.etag": "W/\"JzEsMTExMDAwMjswOzA7TDswJyk=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "12",
        "WarehouseName": "Chicago Cross-Dock",
        "SiteId": "2",
        "WarehouseTypeId": "Transit",
        "PrimaryAddressStreet": "4400 W 45th St",
        "PrimaryAddressCity": "Chicago",
        "PrimaryAddressState": "IL",
        "PrimaryAddressZipCode": "60632",
        "PrimaryAddressCountryRegionId": "USA",
        "IsInventoryCountingEnabled": "No",
        "IsWMSManaged": "Yes"
    },
    {
        "@odata.etag": "W/\"JzEsMTExMDAwMzswOzA7TDswJyk=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "13",
        "WarehouseName": "Atlanta Regional Hub",
        "SiteId": "3",
        "WarehouseTypeId": "Default",
        "PrimaryAddressStreet": "100 Industrial Blvd",
        "PrimaryAddressCity": "Atlanta",
        "PrimaryAddressState": "GA",
        "PrimaryAddressZipCode": "30336",
        "PrimaryAddressCountryRegionId": "USA",
        "IsInventoryCountingEnabled": "Yes",
        "IsWMSManaged": "No"
    },
    {
        "@odata.etag": "W/\"JzEsMTExMDAwNDswOzA7TDswJyk=\"",
        "dataAreaId": "GBSI",
        "WarehouseId": "UK-01",
        "WarehouseName": "London Fulfilment",
        "SiteId": "UK-1",
        "WarehouseTypeId": "Default",
        "PrimaryAddressStreet": "Unit 4, Lakeside Industrial Estate",
        "PrimaryAddressCity": "Colnbrook",
        "PrimaryAddressState": "",
        "PrimaryAddressZipCode": "SL3 0EG",
        "PrimaryAddressCountryRegionId": "GBR",
        "IsInventoryCountingEnabled": "Yes",
        "IsWMSManaged": "Yes"
    },
    {
        "@odata.etag": "W/\"JzEsMTExMDAwNTswOzA7TDswJyk=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "14",
        "WarehouseName": "Quarantine - Surplus & Returns",
        "SiteId": "1",
        "WarehouseTypeId": "Quarantine",
        "PrimaryAddressStreet": "3400 Harbor Ave SW",
        "PrimaryAddressCity": "Seattle",
        "PrimaryAddressState": "WA",
        "PrimaryAddressZipCode": "98126",
        "PrimaryAddressCountryRegionId": "USA",
        "IsInventoryCountingEnabled": "Yes",
        "IsWMSManaged": "No"
    }
];

final readonly & json[] warehouseLocations = [
    {
        "@odata.etag": "W/\"Jzs7MDszMTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "LocationId": "FLOOR",
        "LocationProfileId": "FLOOR",
        "ZoneId": "BULK",
        "AisleNumber": "",
        "RackNumber": "",
        "ShelfNumber": "",
        "BinNumber": "",
        "IsInboundPutawayLocation": "Yes",
        "IsOutboundPickingLocation": "Yes"
    },
    {
        "@odata.etag": "W/\"Jzs7MDszMTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "LocationId": "A-01-01-01",
        "LocationProfileId": "PICK",
        "ZoneId": "PICK",
        "AisleNumber": "A",
        "RackNumber": "01",
        "ShelfNumber": "01",
        "BinNumber": "01",
        "IsInboundPutawayLocation": "No",
        "IsOutboundPickingLocation": "Yes"
    },
    {
        "@odata.etag": "W/\"Jzs7MDszMTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11",
        "LocationId": "RECV",
        "LocationProfileId": "RECV",
        "ZoneId": "INBOUND",
        "AisleNumber": "",
        "RackNumber": "",
        "ShelfNumber": "",
        "BinNumber": "",
        "IsInboundPutawayLocation": "Yes",
        "IsOutboundPickingLocation": "No"
    },
    {
        "@odata.etag": "W/\"Jzs7MDszMTEwMDA0Oyc=\"",
        "dataAreaId": "USMF",
        "WarehouseId": "12",
        "LocationId": "DOCK-1",
        "LocationProfileId": "STAGE",
        "ZoneId": "STAGING",
        "AisleNumber": "",
        "RackNumber": "",
        "ShelfNumber": "",
        "BinNumber": "",
        "IsInboundPutawayLocation": "Yes",
        "IsOutboundPickingLocation": "Yes"
    },
    {
        "@odata.etag": "W/\"Jzs7MDszMTEwMDA1Oyc=\"",
        "dataAreaId": "GBSI",
        "WarehouseId": "UK-01",
        "LocationId": "MEZZ-02",
        "LocationProfileId": "PICK",
        "ZoneId": "PICK",
        "AisleNumber": "M",
        "RackNumber": "02",
        "ShelfNumber": "A",
        "BinNumber": "03",
        "IsInboundPutawayLocation": "No",
        "IsOutboundPickingLocation": "Yes"
    }
];

final readonly & json[] sites = [
    {
        "@odata.etag": "W/\"Jzs7MDsyMTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "SiteId": "1",
        "SiteName": "Seattle HQ",
        "TimeZoneId": "Pacific Standard Time",
        "DefaultWarehouseId": "11",
        "PrimaryAddressCountryRegionId": "USA",
        "PrimaryAddressCity": "Seattle",
        "IsActive": "Yes"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsyMTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "SiteId": "2",
        "SiteName": "Chicago Logistics",
        "TimeZoneId": "Central Standard Time",
        "DefaultWarehouseId": "12",
        "PrimaryAddressCountryRegionId": "USA",
        "PrimaryAddressCity": "Chicago",
        "IsActive": "Yes"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsyMTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "SiteId": "3",
        "SiteName": "Atlanta Regional",
        "TimeZoneId": "Eastern Standard Time",
        "DefaultWarehouseId": "13",
        "PrimaryAddressCountryRegionId": "USA",
        "PrimaryAddressCity": "Atlanta",
        "IsActive": "Yes"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsyMTEwMDA0Oyc=\"",
        "dataAreaId": "GBSI",
        "SiteId": "UK-1",
        "SiteName": "UK Operations",
        "TimeZoneId": "GMT Standard Time",
        "DefaultWarehouseId": "UK-01",
        "PrimaryAddressCountryRegionId": "GBR",
        "PrimaryAddressCity": "Colnbrook",
        "IsActive": "Yes"
    }
];

final readonly & json[] itemGroups = [
    {
        "@odata.etag": "W/\"Jzs7MDs0MTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "ItemGroupId": "ELEC",
        "ItemGroupName": "Electronics",
        "InventoryAccount": "140100",
        "CostOfGoodsSoldAccount": "500100",
        "RevenueAccount": "401100"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs0MTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "ItemGroupId": "FURN",
        "ItemGroupName": "Furniture",
        "InventoryAccount": "140200",
        "CostOfGoodsSoldAccount": "500200",
        "RevenueAccount": "401200"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs0MTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "ItemGroupId": "SVC",
        "ItemGroupName": "Professional Services",
        "InventoryAccount": "",
        "CostOfGoodsSoldAccount": "500500",
        "RevenueAccount": "401500"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs0MTEwMDA0Oyc=\"",
        "dataAreaId": "USMF",
        "ItemGroupId": "RAW",
        "ItemGroupName": "Raw Materials",
        "InventoryAccount": "140300",
        "CostOfGoodsSoldAccount": "500300",
        "RevenueAccount": "401300"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs0MTEwMDA1Oyc=\"",
        "dataAreaId": "GBSI",
        "ItemGroupId": "ELEC",
        "ItemGroupName": "Electronics - UK",
        "InventoryAccount": "UK-140100",
        "CostOfGoodsSoldAccount": "UK-500100",
        "RevenueAccount": "UK-401100"
    }
];

// Global reference data - no dataAreaId.
final readonly & json[] unitsOfMeasure = [
    {
        "@odata.etag": "W/\"Jzs7MDs1MTEwMDAxOyc=\"",
        "Symbol": "ea",
        "Description": "Each",
        "UnitClass": "Quantity",
        "DecimalPrecision": 0,
        "SystemOfUnits": "None"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs1MTEwMDAyOyc=\"",
        "Symbol": "kg",
        "Description": "Kilogram",
        "UnitClass": "Mass",
        "DecimalPrecision": 3,
        "SystemOfUnits": "Metric"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs1MTEwMDAzOyc=\"",
        "Symbol": "lb",
        "Description": "Pound",
        "UnitClass": "Mass",
        "DecimalPrecision": 2,
        "SystemOfUnits": "Imperial"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs1MTEwMDA0Oyc=\"",
        "Symbol": "m",
        "Description": "Meter",
        "UnitClass": "Length",
        "DecimalPrecision": 2,
        "SystemOfUnits": "Metric"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs1MTEwMDA1Oyc=\"",
        "Symbol": "hr",
        "Description": "Hour",
        "UnitClass": "Time",
        "DecimalPrecision": 2,
        "SystemOfUnits": "None"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs1MTEwMDA2Oyc=\"",
        "Symbol": "pallet",
        "Description": "Pallet",
        "UnitClass": "Quantity",
        "DecimalPrecision": 0,
        "SystemOfUnits": "None"
    }
];

final readonly & json[] billsOfMaterials = [
    {
        "@odata.etag": "W/\"Jzs7MDs2MTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-HUB-001",
        "BillOfMaterialsName": "Surface Pro Hub - Standard",
        "SiteId": "1",
        "ItemGroupId": "ELEC",
        "ApprovedByPersonnelNumber": "000201",
        "IsApproved": "Yes",
        "ActivationDate": "2026-01-01",
        "ExpirationDate": "2027-12-31"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs2MTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-KB-001",
        "BillOfMaterialsName": "Ergonomic Keyboard - v2",
        "SiteId": "1",
        "ItemGroupId": "ELEC",
        "ApprovedByPersonnelNumber": "000201",
        "IsApproved": "Yes",
        "ActivationDate": "2026-02-15",
        "ExpirationDate": "2028-02-14"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs2MTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-CHAIR-001",
        "BillOfMaterialsName": "Office Chair Mesh - Assembly",
        "SiteId": "3",
        "ItemGroupId": "FURN",
        "ApprovedByPersonnelNumber": "000305",
        "IsApproved": "Yes",
        "ActivationDate": "2025-10-01",
        "ExpirationDate": "2027-09-30"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs2MTEwMDA0Oyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-HUB-002",
        "BillOfMaterialsName": "Surface Pro Hub - Draft (unapproved)",
        "SiteId": "1",
        "ItemGroupId": "ELEC",
        "ApprovedByPersonnelNumber": "",
        "IsApproved": "No",
        "ActivationDate": "2026-06-01",
        "ExpirationDate": "2028-05-31"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs2MTEwMDA1Oyc=\"",
        "dataAreaId": "GBSI",
        "BillOfMaterialsId": "BOM-MON-UK-001",
        "BillOfMaterialsName": "Portable Monitor 15 - UK build",
        "SiteId": "UK-1",
        "ItemGroupId": "ELEC",
        "ApprovedByPersonnelNumber": "UK-0402",
        "IsApproved": "Yes",
        "ActivationDate": "2026-03-01",
        "ExpirationDate": "2028-02-29"
    }
];

final readonly & json[] bomLines = [
    {
        "@odata.etag": "W/\"Jzs7MDs3MTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-HUB-001",
        "LineNumber": 1.0,
        "ItemNumber": "RAW-PCB-USB",
        "Quantity": 1.0,
        "UnitSymbol": "ea",
        "ConsumptionFormulaId": "Standard",
        "ScrapVariablePercentage": 2.0,
        "ScrapConstantQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs3MTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-HUB-001",
        "LineNumber": 2.0,
        "ItemNumber": "RAW-CASE-ALU",
        "Quantity": 1.0,
        "UnitSymbol": "ea",
        "ConsumptionFormulaId": "Standard",
        "ScrapVariablePercentage": 1.0,
        "ScrapConstantQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs3MTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-HUB-001",
        "LineNumber": 3.0,
        "ItemNumber": "RAW-CABLE-USB-C",
        "Quantity": 0.5,
        "UnitSymbol": "m",
        "ConsumptionFormulaId": "Standard",
        "ScrapVariablePercentage": 3.0,
        "ScrapConstantQuantity": 0.05
    },
    {
        "@odata.etag": "W/\"Jzs7MDs3MTEwMDA0Oyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-KB-001",
        "LineNumber": 1.0,
        "ItemNumber": "RAW-PCB-KB",
        "Quantity": 1.0,
        "UnitSymbol": "ea",
        "ConsumptionFormulaId": "Standard",
        "ScrapVariablePercentage": 2.0,
        "ScrapConstantQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs3MTEwMDA1Oyc=\"",
        "dataAreaId": "USMF",
        "BillOfMaterialsId": "BOM-CHAIR-001",
        "LineNumber": 1.0,
        "ItemNumber": "RAW-FRAME-ALU",
        "Quantity": 1.0,
        "UnitSymbol": "ea",
        "ConsumptionFormulaId": "Standard",
        "ScrapVariablePercentage": 0.5,
        "ScrapConstantQuantity": 0.0
    }
];

final readonly & json[] productionOrders = [
    {
        "@odata.etag": "W/\"Jzs7MDs4MTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "ProductionOrderNumber": "PRD-2026-0001",
        "ItemNumber": "ITM-1001",
        "ProductionQuantity": 250.0,
        "UnitSymbol": "ea",
        "SiteId": "1",
        "WarehouseId": "11",
        "ProductionStatus": "Released",
        "ScheduledStartDate": "2026-05-02",
        "ScheduledEndDate": "2026-05-06",
        "BillOfMaterialsId": "BOM-HUB-001",
        "RouteId": "RT-HUB-001",
        "ResponsibleWorkerPersonnelNumber": "000405"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs4MTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "ProductionOrderNumber": "PRD-2026-0002",
        "ItemNumber": "ITM-1002",
        "ProductionQuantity": 120.0,
        "UnitSymbol": "ea",
        "SiteId": "1",
        "WarehouseId": "11",
        "ProductionStatus": "StartedUp",
        "ScheduledStartDate": "2026-04-28",
        "ScheduledEndDate": "2026-05-01",
        "BillOfMaterialsId": "BOM-KB-001",
        "RouteId": "RT-KB-001",
        "ResponsibleWorkerPersonnelNumber": "000405"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs4MTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "ProductionOrderNumber": "PRD-2026-0003",
        "ItemNumber": "ITM-2001",
        "ProductionQuantity": 60.0,
        "UnitSymbol": "ea",
        "SiteId": "3",
        "WarehouseId": "13",
        "ProductionStatus": "Scheduled",
        "ScheduledStartDate": "2026-05-10",
        "ScheduledEndDate": "2026-05-17",
        "BillOfMaterialsId": "BOM-CHAIR-001",
        "RouteId": "RT-CHAIR-001",
        "ResponsibleWorkerPersonnelNumber": "000510"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs4MTEwMDA0Oyc=\"",
        "dataAreaId": "USMF",
        "ProductionOrderNumber": "PRD-2026-0004",
        "ItemNumber": "ITM-1001",
        "ProductionQuantity": 500.0,
        "UnitSymbol": "ea",
        "SiteId": "1",
        "WarehouseId": "11",
        "ProductionStatus": "ReportedAsFinished",
        "ScheduledStartDate": "2026-04-15",
        "ScheduledEndDate": "2026-04-22",
        "BillOfMaterialsId": "BOM-HUB-001",
        "RouteId": "RT-HUB-001",
        "ResponsibleWorkerPersonnelNumber": "000405"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs4MTEwMDA1Oyc=\"",
        "dataAreaId": "GBSI",
        "ProductionOrderNumber": "PRD-UK-2026-001",
        "ItemNumber": "ITM-UK-1001",
        "ProductionQuantity": 80.0,
        "UnitSymbol": "ea",
        "SiteId": "UK-1",
        "WarehouseId": "UK-01",
        "ProductionStatus": "Released",
        "ScheduledStartDate": "2026-05-05",
        "ScheduledEndDate": "2026-05-12",
        "BillOfMaterialsId": "BOM-MON-UK-001",
        "RouteId": "RT-MON-UK-001",
        "ResponsibleWorkerPersonnelNumber": "UK-0601"
    }
];

final readonly & json[] transferOrders = [
    {
        "@odata.etag": "W/\"Jzs7MDs5MTEwMDAxOyc=\"",
        "dataAreaId": "USMF",
        "TransferOrderNumber": "TO-2026-0101",
        "ShippingWarehouseId": "11",
        "ShippingSiteId": "1",
        "ReceivingWarehouseId": "13",
        "ReceivingSiteId": "3",
        "ShippingDate": "2026-05-03",
        "ReceivingDate": "2026-05-07",
        "TransferStatus": "Shipped",
        "DeliveryModeCode": "Truck",
        "CurrencyCode": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs5MTEwMDAyOyc=\"",
        "dataAreaId": "USMF",
        "TransferOrderNumber": "TO-2026-0102",
        "ShippingWarehouseId": "12",
        "ShippingSiteId": "2",
        "ReceivingWarehouseId": "11",
        "ReceivingSiteId": "1",
        "ShippingDate": "2026-05-06",
        "ReceivingDate": "2026-05-08",
        "TransferStatus": "Created",
        "DeliveryModeCode": "Air",
        "CurrencyCode": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs5MTEwMDAzOyc=\"",
        "dataAreaId": "USMF",
        "TransferOrderNumber": "TO-2026-0103",
        "ShippingWarehouseId": "13",
        "ShippingSiteId": "3",
        "ReceivingWarehouseId": "12",
        "ReceivingSiteId": "2",
        "ShippingDate": "2026-04-22",
        "ReceivingDate": "2026-04-25",
        "TransferStatus": "Received",
        "DeliveryModeCode": "Truck",
        "CurrencyCode": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs5MTEwMDA0Oyc=\"",
        "dataAreaId": "GBSI",
        "TransferOrderNumber": "TO-UK-2026-05",
        "ShippingWarehouseId": "UK-01",
        "ShippingSiteId": "UK-1",
        "ReceivingWarehouseId": "UK-01",
        "ReceivingSiteId": "UK-1",
        "ShippingDate": "2026-05-01",
        "ReceivingDate": "2026-05-02",
        "TransferStatus": "Shipped",
        "DeliveryModeCode": "Ground",
        "CurrencyCode": "GBP"
    }
];

final readonly & json[] inventoryOnHand = [
    {
        "@odata.etag": "W/\"Jzs7MDsxMDExMDAwMTsnKQ==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "SiteId": "1",
        "WarehouseId": "11",
        "LocationId": "A-01-01-01",
        "BatchNumber": "",
        "SerialNumber": "",
        "InventoryStatusId": "Available",
        "UnitSymbol": "ea",
        "PhysicalInventoryQuantity": 450.0,
        "PhysicalReservedQuantity": 25.0,
        "AvailablePhysicalQuantity": 425.0,
        "OrderedInventoryQuantity": 500.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMDExMDAwMjsnKQ==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "SiteId": "3",
        "WarehouseId": "13",
        "LocationId": "FLOOR",
        "BatchNumber": "",
        "SerialNumber": "",
        "InventoryStatusId": "Available",
        "UnitSymbol": "ea",
        "PhysicalInventoryQuantity": 180.0,
        "PhysicalReservedQuantity": 0.0,
        "AvailablePhysicalQuantity": 180.0,
        "OrderedInventoryQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMDExMDAwMzsnKQ==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1002",
        "SiteId": "1",
        "WarehouseId": "11",
        "LocationId": "A-01-01-01",
        "BatchNumber": "",
        "SerialNumber": "SN-KB-2026-00045",
        "InventoryStatusId": "Available",
        "UnitSymbol": "ea",
        "PhysicalInventoryQuantity": 1.0,
        "PhysicalReservedQuantity": 0.0,
        "AvailablePhysicalQuantity": 1.0,
        "OrderedInventoryQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMDExMDAwNDsnKQ==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-2001",
        "SiteId": "3",
        "WarehouseId": "13",
        "LocationId": "FLOOR",
        "BatchNumber": "",
        "SerialNumber": "",
        "InventoryStatusId": "Available",
        "UnitSymbol": "ea",
        "PhysicalInventoryQuantity": 88.0,
        "PhysicalReservedQuantity": 12.0,
        "AvailablePhysicalQuantity": 76.0,
        "OrderedInventoryQuantity": 60.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMDExMDAwNTsnKQ==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "SiteId": "1",
        "WarehouseId": "14",
        "LocationId": "FLOOR",
        "BatchNumber": "",
        "SerialNumber": "",
        "InventoryStatusId": "Blocked",
        "UnitSymbol": "ea",
        "PhysicalInventoryQuantity": 18.0,
        "PhysicalReservedQuantity": 0.0,
        "AvailablePhysicalQuantity": 0.0,
        "OrderedInventoryQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMDExMDAwNjsnKQ==\"",
        "dataAreaId": "GBSI",
        "ItemNumber": "ITM-UK-1001",
        "SiteId": "UK-1",
        "WarehouseId": "UK-01",
        "LocationId": "MEZZ-02",
        "BatchNumber": "",
        "SerialNumber": "",
        "InventoryStatusId": "Available",
        "UnitSymbol": "ea",
        "PhysicalInventoryQuantity": 65.0,
        "PhysicalReservedQuantity": 5.0,
        "AvailablePhysicalQuantity": 60.0,
        "OrderedInventoryQuantity": 40.0
    }
];

final readonly & json[] inventoryJournals = [
    {
        "@odata.etag": "W/\"Jzs7MDsxMTExMDAwMScp\"",
        "dataAreaId": "USMF",
        "JournalNumber": "INV-0001",
        "JournalName": "Counting",
        "Description": "April cycle count - warehouse 11",
        "JournalType": "Counting",
        "IsPosted": "Yes",
        "PostingDate": "2026-04-30",
        "SiteId": "1",
        "WarehouseId": "11"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMTExMDAwMicp\"",
        "dataAreaId": "USMF",
        "JournalNumber": "INV-0002",
        "JournalName": "Movement",
        "Description": "Rework move - Hub components",
        "JournalType": "Movement",
        "IsPosted": "No",
        "PostingDate": null,
        "SiteId": "1",
        "WarehouseId": "11"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMTExMDAwMycp\"",
        "dataAreaId": "USMF",
        "JournalNumber": "INV-0003",
        "JournalName": "Transfer",
        "Description": "Bulk transfer Seattle - Atlanta",
        "JournalType": "Transfer",
        "IsPosted": "Yes",
        "PostingDate": "2026-05-03",
        "SiteId": "1",
        "WarehouseId": "11"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMTExMDAwNCcp\"",
        "dataAreaId": "GBSI",
        "JournalNumber": "INV-UK-0001",
        "JournalName": "Counting",
        "Description": "UK quarterly cycle count",
        "JournalType": "Counting",
        "IsPosted": "Yes",
        "PostingDate": "2026-03-31",
        "SiteId": "UK-1",
        "WarehouseId": "UK-01"
    }
];

final readonly & json[] salesShipments = [
    {
        "@odata.etag": "W/\"Jzs7MDsxMjExMDAwMScp\"",
        "dataAreaId": "USMF",
        "PackingSlipId": "PS-2026-00045",
        "SalesOrderNumber": "SO-100045",
        "OrderingCustomerAccountNumber": "US-001",
        "InvoiceCustomerAccountNumber": "US-001",
        "PackingSlipDate": "2026-05-12",
        "ShippingDate": "2026-05-12",
        "DeliveryModeCode": "Ground",
        "DeliveryTermsCode": "FOB",
        "ShippingWarehouseId": "11",
        "CurrencyCode": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMjExMDAwMicp\"",
        "dataAreaId": "USMF",
        "PackingSlipId": "PS-2026-00046",
        "SalesOrderNumber": "SO-100046",
        "OrderingCustomerAccountNumber": "US-002",
        "InvoiceCustomerAccountNumber": "US-002",
        "PackingSlipDate": "2026-04-22",
        "ShippingDate": "2026-04-22",
        "DeliveryModeCode": "Air",
        "DeliveryTermsCode": "CIP",
        "ShippingWarehouseId": "11",
        "CurrencyCode": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMjExMDAwMycp\"",
        "dataAreaId": "USMF",
        "PackingSlipId": "PS-2026-00047",
        "SalesOrderNumber": "SO-100047",
        "OrderingCustomerAccountNumber": "US-003",
        "InvoiceCustomerAccountNumber": "US-003",
        "PackingSlipDate": "2026-06-01",
        "ShippingDate": "2026-06-01",
        "DeliveryModeCode": "Ground",
        "DeliveryTermsCode": "FOB",
        "ShippingWarehouseId": "13",
        "CurrencyCode": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDsxMjExMDAwNCcp\"",
        "dataAreaId": "GBSI",
        "PackingSlipId": "PS-UK-2026-12",
        "SalesOrderNumber": "SO-UK-10012",
        "OrderingCustomerAccountNumber": "UK-001",
        "InvoiceCustomerAccountNumber": "UK-001",
        "PackingSlipDate": "2026-03-30",
        "ShippingDate": "2026-03-30",
        "DeliveryModeCode": "Ground",
        "DeliveryTermsCode": "DAP",
        "ShippingWarehouseId": "UK-01",
        "CurrencyCode": "GBP"
    }
];
