page 10029 "Sales Order Invoice Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Sales Line";
    SourceTableView = WHERE("Document Type" = FILTER(Order),
                            "Qty. Shipped Not Invoiced" = FILTER(<> 0));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    Editable = false;
                    ToolTip = 'Specifies the type of the record on the document line. ';
                }
                field("No."; "No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of the record.';

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate;
                    end;
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the cross-reference number of the item specified on the line.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // Item Cross Ref - start
                        if Type = Type::Item then begin
                            SalesHeader.Get("Document Type", "Document No.");
                            ItemCrossReference.Reset();
                            ItemCrossReference.SetCurrentKey("Cross-Reference Type", "Cross-Reference Type No.");
                            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Customer);
                            ItemCrossReference.SetRange("Cross-Reference Type No.", SalesHeader."Sell-to Customer No.");
                            if PAGE.RunModal(PAGE::"Cross Reference List", ItemCrossReference) = ACTION::LookupOK then begin
                                Validate("Cross-Reference No.", ItemCrossReference."Cross-Reference No.");
                                InsertExtendedText(false);
                            end;
                        end;
                        // Item Cross Ref - end
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the variant number of the items sold.';
                    Visible = false;
                }
                field("Substitution Available"; "Substitution Available")
                {
                    Editable = false;
                    ToolTip = 'Specifies that a substitute is available for the item on the sales line.';
                    Visible = false;
                }
                field("Purchasing Code"; "Purchasing Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the purchasing code for the item.';
                    Visible = false;
                }
                field(Nonstock; Nonstock)
                {
                    Editable = false;
                    ToolTip = 'Specifies that the item on the sales line is a catalog item (an item not normally kept in inventory).';
                    Visible = false;
                }
                field(Description; Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies a description of the invoice line.';
                }
                field(Control26; "Drop Shipment")
                {
                    Editable = false;
                    ToolTip = 'Specifies whether to ship the items on the line directly to your customer.';
                    Visible = false;
                }
                field(Control106; "Special Order")
                {
                    Editable = false;
                    ToolTip = 'Specifies that the item on the sales line is a special-order item.';
                    Visible = false;
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the shipping agent''s package number.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the quantity of items on document line.';

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the item''s unit of measure. ';

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValida;
                    end;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    Editable = false;
                    ToolTip = 'Specifies the item''s unit of measure. ';
                    Visible = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the price for one unit of the item. ';
                }
                field("Tax Liable"; "Tax Liable")
                {
                    Editable = false;
                    ToolTip = 'Specifies that the bill-to customer is liable for sales tax.';
                    Visible = false;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = SalesTax;
                    ToolTip = 'Specifies the tax area that is used to calculate and post sales tax.';
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ToolTip = 'Specifies the tax group that is used to calculate and post sales tax.';
                }
                field("Line Amount"; "Line Amount")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the amount of the sales line, calculated as the quantity times the unit price minus any percentage value in the Line Discount % field. If the Prices Including VAT check box on the customer card is selected, the amount includes VAT.';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ToolTip = 'Specifies the sum of the amounts in the Amount Including VAT fields on the associated sales lines.';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the discount percentage that is granted to the amount on the line.';
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ToolTip = 'Specifies the amount of the discount that will be given on the invoice line.';
                    Visible = false;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ToolTip = 'Specifies if  the invoice line can be included in a possible invoice discount calculation. The value is copied from the Allow Invoice Disc. field on the sales line.';
                    Visible = false;
                }
                field("Inv. Discount Amount"; "Inv. Discount Amount")
                {
                    ToolTip = 'Specifies the invoice discount amount that is calculated on the line if you click Actions, point to Functions, and then click Calculate Invoice Discount.';
                    Visible = false;
                }
                field("Quantity Shipped"; "Quantity Shipped")
                {
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies how many of the units in the Quantity field have been posted as shipped.';
                }
                field("Qty. to Invoice"; "Qty. to Invoice")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies how many of the units in the Quantity field to post as invoiced. ';
                }
                field("Quantity Invoiced"; "Quantity Invoiced")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies how many of the units in the Quantity field have been posted as invoiced.';
                }
                field("Allow Item Charge Assignment"; "Allow Item Charge Assignment")
                {
                    ToolTip = 'Specifies that you can assign item charges to this line.';
                    Visible = false;
                }
                field("Qty. to Assign"; "Qty. to Assign")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies how many of the units in the Quantity field to assign.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        ShowItemChargeAssgnt;
                        UpdateForm(false);
                    end;
                }
                field("Qty. Assigned"; "Qty. Assigned")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies how many of the units in the Quantity field have been assigned.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        ShowItemChargeAssgnt;
                        CurrPage.Update(false);
                    end;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the date that the items on the line are in inventory and available to be picked. The shipment date is the date you expect to ship the items on the line.';
                }
                field("FA Posting Date"; "FA Posting Date")
                {
                    ToolTip = 'Specifies the posting date for the fixed asset.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the dimension value code that the sales line is associated with.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the dimension value code that the sales line is associated with.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                group("Drop Shipment")
                {
                    Caption = 'Drop Shipment';
                    Image = Delivery;
                    action("Purchase &Order")
                    {
                        Caption = 'Purchase &Order';
                        Image = Document;
                        ToolTip = 'Purchase goods or services from a vendor.';

                        trigger OnAction()
                        begin
                            OpenPurchOrderForm;
                        end;
                    }
                }
                group("Special Order")
                {
                    Caption = 'Special Order';
                    Image = SpecialOrder;
                    action(Action1902819104)
                    {
                        Caption = 'Purchase &Order';
                        Image = Document;
                        ToolTip = 'Purchase goods or services from a vendor.';

                        trigger OnAction()
                        begin
                            OpenPurchOrderForm;
                        end;
                    }
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
                action("Item Charge &Assignment")
                {
                    Caption = 'Item Charge &Assignment';
                    Ellipsis = true;
                    ToolTip = 'Assign additional direct costs, for example for freight, to the item on the line.';

                    trigger OnAction()
                    begin
                        ItemChargeAssgnt;
                    end;
                }
                action("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := xRec.Type;
        Clear(ShortcutDimCode);
    end;

    var
        SalesHeader: Record "Sales Header";
        ItemCrossReference: Record "Item Cross Reference";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ShortcutDimCode: array[8] of Code[20];

    procedure ApproveCalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Disc. (Yes/No)", Rec);
    end;

    procedure CalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", Rec);
    end;

    procedure ExplodeBOM()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
    end;

    procedure OpenPurchOrderForm()
    var
        PurchHeader: Record "Purchase Header";
        PurchOrder: Page "Purchase Order";
    begin
        PurchHeader.SetRange("No.", "Purchase Order No.");
        PurchOrder.SetTableView(PurchHeader);
        PurchOrder.Editable := false;
        PurchOrder.Run;
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            TransferExtendedText.InsertSalesExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate then
            UpdateForm(true);
    end;

    procedure ShowLineReservation()
    begin
        Find;
        ShowReservation;
    end;

    procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin)
    begin
        ItemAvailability(AvailabilityType);
    end;

    procedure ShowReservationEntries()
    begin
        ShowReservationEntries(true);
    end;

    procedure ShowNonstockItems()
    begin
        ShowNonstock;
    end;

    procedure ShowTracking()
    var
        TrackingForm: Page "Order Tracking";
    begin
        TrackingForm.SetSalesLine(Rec);
        TrackingForm.RunModal;
    end;

    procedure ItemChargeAssgnt()
    begin
        ShowItemChargeAssgnt;
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
        if (Type = Type::"Charge (Item)") and ("No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord;
    end;

    local procedure QuantityOnAfterValidate()
    begin
        if Reserve = Reserve::Always then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;

    local procedure UnitofMeasureCodeOnAfterValida()
    begin
        if Reserve = Reserve::Always then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;
}

