page 10120 "Bank Rec. Worksheet"
{
    Caption = 'Bank Rec. Worksheet';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Posting,Bank Rec.';
    RefreshOnActivate = true;
    SourceTable = "Bank Rec. Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code for the bank account the reconciliation applies to.';
                }
                field("Statement No."; "Statement No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the statement number to be reconciled.';
                }
                field("Statement Date"; "Statement Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the as-of date of the statement. All G/L balances will be calculated based upon this date.';
                }
                field("G/L Balance (LCY)"; "G/L Balance (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the general ledger balance for the assigned account number.';
                }
                field("G/L Balance"; "G/L Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the general ledger balance for the assigned account number.';
                }
                field("""Positive Adjustments"" - ""Negative Bal. Adjustments"""; "Positive Adjustments" - "Negative Bal. Adjustments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '+ Positive Adjustments';
                    Editable = false;
                    ToolTip = 'Specifies the total amount of positive adjustments for the bank statement.';
                }
                field("""G/L Balance"" + (""Positive Adjustments"" - ""Negative Bal. Adjustments"")"; "G/L Balance" + ("Positive Adjustments" - "Negative Bal. Adjustments"))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subtotal';
                    Editable = false;
                    ToolTip = 'Specifies a subtotal amount for the posted worksheet. The subtotal is calculated by using the general ledger balance and any positive or negative adjustments.';
                }
                field("""Negative Adjustments"" - ""Positive Bal. Adjustments"""; "Negative Adjustments" - "Positive Bal. Adjustments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '- Negative Adjustments';
                    Editable = false;
                    ToolTip = 'Specifies the total of the negative adjustment lines for the bank statement.';
                }
                field("Ending G/L Balance"; "G/L Balance" + ("Positive Adjustments" - "Negative Bal. Adjustments") + ("Negative Adjustments" - "Positive Bal. Adjustments"))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ending G/L Balance';
                    Editable = false;
                    ToolTip = 'Specifies the sum of values in the G/L Balance field, plus the Positive Adjustments field, minus the Negative Adjustments field. This is what the G/L balance will be after the bank reconciliation worksheet is posted and the adjustments are posted to the general ledger.';
                }
                field(Difference; ("G/L Balance" + ("Positive Adjustments" - "Negative Bal. Adjustments") + ("Negative Adjustments" - "Positive Bal. Adjustments")) - (("Statement Balance" + "Outstanding Deposits") - "Outstanding Checks"))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Difference';
                    Editable = false;
                    ToolTip = 'Specifies the difference between the Amount field and the Cleared Amount field.';
                }
                field("Cleared With./Chks. Per Stmnt."; "Cleared With./Chks. Per Stmnt.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of withdrawals or checks that cleared the bank for this statement.';
                }
                field("Cleared Inc./Dpsts. Per Stmnt."; "Cleared Inc./Dpsts. Per Stmnt.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of increases or deposits that cleared the bank for this statement.';
                }
                field(BalanceOnStatement; "Statement Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance on Statement';
                    ToolTip = 'Specifies the amount entered by the operator from the balance found on the bank statement.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Outstanding Deposits"; "Outstanding Deposits")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '+ Outstanding Deposits';
                    Editable = false;
                    ToolTip = 'Specifies the total of outstanding deposits of type Increase for the bank statement.';
                }
                field("""Statement Balance"" + ""Outstanding Deposits"""; "Statement Balance" + "Outstanding Deposits")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subtotal';
                    Editable = false;
                    ToolTip = 'Specifies a subtotal amount for the posted worksheet. The subtotal is calculated by using the general ledger balance and any positive or negative adjustments.';
                }
                field("Outstanding Checks"; "Outstanding Checks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '- Outstanding Checks';
                    Editable = false;
                    ToolTip = 'Specifies the total of outstanding check withdrawals for the bank statement.';
                }
                field(CalculateEndingBalance; CalculateEndingBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ending Balance';
                    Editable = false;
                    ToolTip = 'Specifies the sum of values in the Balance on Statement field, plus the Outstanding Deposits field, minus the Outstanding Checks field.';
                }
            }
            group(Checks)
            {
                Caption = 'Checks';
                part(ChecksSubForm; "Bank Rec. Check Lines Subform")
                {
                    ApplicationArea = Basic, Suite;
                    SubPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "Statement No." = FIELD("Statement No.");
                }
            }
            group("Deposits/Transfers")
            {
                Caption = 'Deposits/Transfers';
                part(DepositsSubForm; "Bank Rec. Dep. Lines Subform")
                {
                    ApplicationArea = Basic, Suite;
                    SubPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "Statement No." = FIELD("Statement No.");
                }
            }
            group(Adjustments)
            {
                Caption = 'Adjustments';
                part(AdjustmentsSubForm; "Bank Rec. Adj. Lines Subform")
                {
                    ApplicationArea = Basic, Suite;
                    SubPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "Statement No." = FIELD("Statement No.");
                }
            }
            group("Control Info")
            {
                Caption = 'Control Info';
                field("Bank Account No.2"; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the code for the bank account the reconciliation applies to.';
                }
                field("Statement No.2"; "Statement No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the statement number to be reconciled.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code assigned to the bank account.';
                }
                field("Currency Factor"; "Currency Factor")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies currency conversions when posting adjustments for bank accounts with a foreign currency code assigned.';
                }
                field("Statement Date2"; "Statement Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the as-of date of the statement. All G/L balances will be calculated based upon this date.';
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a date automatically populated when the record is created.';
                }
                field("Time Created"; "Time Created")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the time created, which is automatically populated when the record is created.';
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = Basic, Suite;
                    AssistEdit = false;
                    DrillDown = false;
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the User ID of the person who created the record.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Editable = false;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Bank Rec.")
            {
                Caption = '&Bank Rec.';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Bank Comment Sheet";
                    RunPageLink = "Bank Account No." = FIELD("Bank Account No."),
                                  "No." = FIELD("Statement No.");
                    RunPageView = WHERE("Table Name" = CONST("Bank Rec."));
                    ToolTip = 'View comments that apply.';
                }
                action("C&ard")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'C&ard';
                    Image = EditLines;
                    RunObject = Page "Bank Account Card";
                    RunPageLink = "No." = FIELD("Bank Account No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the card for the bank account that is being reconciled. ';
                }
            }
        }
        area(reporting)
        {
            action(BankRecTestReport)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Rec. Test Report';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'View a preliminary draft of the bank reconciliation statement. You can preview, print, or save the bank reconciliation test statement in several file formats. This step in the bank reconciliation process allows you to test the bank reconciliation statement entries for accuracy prior to posting the bank reconciliation statement.';

                trigger OnAction()
                var
                    BankRecHdr: Record "Bank Rec. Header";
                begin
                    BankRecHdr := Rec;
                    BankRecHdr.SetRecFilter;
                    REPORT.Run(REPORT::"Bank Rec. Test Report", true, false, BankRecHdr);
                end;
            }
            action("Bank Account - Reconcile")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Account - Reconcile';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Bank Account - Reconcile";
                ToolTip = 'Reconcile bank transactions with bank account ledger entries to ensure that your bank account in Dynamics NAV reflects your actual liquidity.';
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(SuggestLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggest Lines';
                    Ellipsis = true;
                    Image = SuggestReconciliationLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Add deposit lines to the worksheet that have identical external document numbers.';

                    trigger OnAction()
                    begin
                        RunProcessLines(0);
                    end;
                }
                action(MarkLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mark Lines';
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Mark transactions that you want to reconcile.';

                    trigger OnAction()
                    begin
                        RunProcessLines(1);
                    end;
                }
                action(ClearLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Clear Lines';
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Delete the selected worksheet lines.';

                    trigger OnAction()
                    begin
                        RunProcessLines(3);
                    end;
                }
                action(RecordAdjustments)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Record Adjustments';
                    Ellipsis = true;
                    Image = AdjustEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Create adjustments because company and bank values differ.';

                    trigger OnAction()
                    begin
                        RunProcessLines(2);
                    end;
                }
                separator(Action1020070)
                {
                }
                action(RecalculateGLBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recalc &G/L Balance';
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Calculate the G/L balance again.';

                    trigger OnAction()
                    begin
                        RecalcGLBalance;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(TestReport)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        ReportPrint.PrintBankRec(Rec);
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Bank Rec.-Post (Yes/No)", Rec);
                        CurrPage.Update(false);
                        RefreshSharedTempTable;
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Bank Rec.-Post + Print", Rec);
                        CurrPage.Update(false);
                        RefreshSharedTempTable;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AfterGetCurrentRecord;
    end;

    trigger OnClosePage()
    begin
        RefreshSharedTempTable;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        RefreshSharedTempTable;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Modify(true);
        RefreshSharedTempTable;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AfterGetCurrentRecord;
        RefreshSharedTempTable;
    end;

    trigger OnOpenPage()
    begin
        RefreshSharedTempTable;
    end;

    var
        TempBankAccReconciliationDataset: Record "Bank Acc. Reconciliation" temporary;
        ReportPrint: Codeunit "Test Report-Print";
        Text001: Label 'Do you want to recalculate the G/L Balance from the General Ledger?';

    procedure SetupRecord()
    begin
        SetRange("Date Filter", "Statement Date");
        CalcFields("Positive Adjustments",
          "Negative Adjustments",
          "Positive Bal. Adjustments",
          "Negative Bal. Adjustments");
    end;

    procedure RunProcessLines(ActionToTake: Option "Suggest Lines","Mark Lines","Record Adjustments","Clear Lines")
    var
        ProcessLines: Report "Bank Rec. Process Lines";
    begin
        case ActionToTake of
            ActionToTake::"Suggest Lines":
                ProcessLines.SetDoSuggestLines(true, "Bank Account No.", "Statement No.");
            ActionToTake::"Mark Lines":
                ProcessLines.SetDoMarkLines(true, "Bank Account No.", "Statement No.");
            ActionToTake::"Record Adjustments":
                ProcessLines.SetDoAdjLines(true, "Bank Account No.", "Statement No.");
            ActionToTake::"Clear Lines":
                ProcessLines.SetDoClearLines(true, "Bank Account No.", "Statement No.");
        end;
        ProcessLines.SetTableView(Rec);
        ProcessLines.RunModal;
        DoRecalc;
    end;

    procedure RecalcGLBalance()
    begin
        if Confirm(Text001, true) then
            DoRecalc;
    end;

    procedure DoRecalc()
    begin
        CalculateBalance;
        CurrPage.Update;
    end;

    local procedure AfterGetCurrentRecord()
    begin
        xRec := Rec;
        SetupRecord;
    end;

    procedure SetSharedTempTable(var TempBankAccReconciliationOnList: Record "Bank Acc. Reconciliation" temporary)
    begin
        TempBankAccReconciliationDataset.Copy(TempBankAccReconciliationOnList, true);
    end;

    local procedure RefreshSharedTempTable()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        TempBankAccReconciliationDataset.DeleteAll();
        BankAccReconciliation.GetTempCopyFromBankRecHeader(TempBankAccReconciliationDataset);
    end;
}

