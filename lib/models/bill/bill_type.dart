enum SheetType {
  none,
  taxInvoice,
  billOfSupply,
  creditNote,
  debitNote,
  proformaInvoice,
  
}

List<String> getLabelList(SheetType type) {
  switch (type) {
    case SheetType.taxInvoice:
      return [];
    case SheetType.billOfSupply:
      return [];
    default:
    return [];
  }
}