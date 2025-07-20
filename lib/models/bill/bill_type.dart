

import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';

enum SheetType {
  none,
  taxInvoice,
  billOfSupply,
  creditNote,
  debitNote,
  proformaInvoice,
  
}

List<RequiredText> getLabelList(SheetType type, List<RequiredText>? labelList) {
   List<RequiredText> defaultList;
  switch (type) {
    case SheetType.taxInvoice:
      defaultList =  [
        //23
        RequiredText(name: 'title', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'invoiceNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'invoiceDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerGSTIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerPAN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'recipientName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientGSTIN/UIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'placeOfSupply', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'state/PlaceCode', sheetTextType: SheetTextType.integer.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'reverseChargeFlag', sheetTextType: SheetTextType.bool.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'e-WayBillNo', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'placeOfDelivery', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'totalPayable', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'paymentTerms', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'itemSheet', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'profits', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: true),
        
        //signature
        //39 -23 = 16
      ];
    case SheetType.billOfSupply:
      defaultList =  [
        RequiredText(name: 'title', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'invoiceNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'invoiceDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerGSTIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerPAN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'recipientName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'placeOfSupply', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'e-WayBillNo', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'totalPayable', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'placeOfDelivery', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'itemSheet', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'profits', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: true),
        
        //signature 12
      ];
    case SheetType.creditNote:
      defaultList =  [
        RequiredText(name: 'title', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false), // "Credit Note"
        RequiredText(name: 'creditNoteNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'creditNoteDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'originalInvoiceNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'originalInvoiceDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'reasonForIssue', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'sellerName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerGSTIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'recipientName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientGSTIN/UIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),

        RequiredText(name: 'placeOfSupply', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'state/PlaceCode', sheetTextType: SheetTextType.integer.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'e-WayBillNo', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'totalPayable', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'paymentTerms', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'itemSheet', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        
      //signature
      ];
    case SheetType.debitNote:
      defaultList =  [
        RequiredText(name: 'title', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false), // "Debit Note"
        RequiredText(name: 'debitNoteNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'debitNoteDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'originalInvoiceNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'originalInvoiceDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'reasonForIssue', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'sellerName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerGSTIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),

        RequiredText(name: 'recipientName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientGSTIN/UIN', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),

        RequiredText(name: 'placeOfSupply', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'state/PlaceCode', sheetTextType: SheetTextType.integer.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'e-WayBillNo', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'totalPayable', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'paymentTerms', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'itemSheet', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'profits', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: true),
        
        //signature
      ];
    case SheetType.proformaInvoice:
      defaultList = [
        RequiredText(name: 'title', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'proformaNumber', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'proformaDate', sheetTextType: SheetTextType.date.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'sellerAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientName', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'recipientAddress', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'totalPayable', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'paymentTerms', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: true),
        RequiredText(name: 'itemSheet', sheetTextType: SheetTextType.string.index, indexPath: IndexPath(index: -951), isOptional: false),
        RequiredText(name: 'profits', sheetTextType: SheetTextType.number.index, indexPath: IndexPath(index: -951), isOptional: true),
        
        // simpler and cleaner, excludes tax fields
      ];
      break;

    default:
      return [];
  }
  // Return defaultList if labelList is null
  if (labelList == null) return defaultList;

  // Create a map of labelList by name for fast lookup
  final labelMap = {
    for (final item in labelList) item.name: item
  };

  // Replace fields from defaultList if found in labelMap and indexPath is not -951
  return defaultList.map((defaultItem) {
    final override = labelMap[defaultItem.name];
    if (override != null && override.indexPath.index != -951) {
      return override;
    }
    return defaultItem;
  }).toList();
}


