// Sets Account Type picklist for Pronto demo accounts (Merchant list + formula Account_Type_Description__c).
// Record type is applied on insert via data/pronto-export/import-overrides.json for new tree imports.
Map<String, String> nameToType = new Map<String, String>{
    'Artisan Plates & Co.' => 'Restaurant Group',
    'Basil & Thyme Cafe' => 'Independent Vendor',
    'Epicurean Edge Grill' => 'Independent Vendor',
    'BiteFusion Kitchen' => 'Restaurant Group',
    'Harvest Table Kitchens' => 'Restaurant Group',
    'MetroMunch Marketplace' => 'Restaurant Group',
    'GreenFork Bistro' => 'Independent Vendor',
    'Savory Street Co.' => 'Independent Vendor',
    'FlavorTrail Deli' => 'Independent Vendor',
    'Urban Eats Collective' => 'Restaurant Group'
};
List<Account> accs = [SELECT Id, Name FROM Account WHERE Name IN :nameToType.keySet()];
for (Account a : accs) {
    a.Type = nameToType.get(a.Name);
}
update accs;
System.debug('Updated Type on ' + accs.size() + ' accounts');
