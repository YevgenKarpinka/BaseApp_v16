codeunit 10091 "Export Payments (RB)"
{

    trigger OnRun()
    begin
    end;

    var
        ExportInProcessErr: Label 'Cannot start new Export File while %1 is in process.', Comment = '%1 = the filename that is already being processed.';
        ExportFilePathErr: Label '%1 in %2 %3 is invalid.', Comment = '%1 = the export file path, %2 the field in the table, ie, bank, customer etc, %3 = the identifier for the record, ie, bankaccount number etc. ';
        FileAlreadyExistsErr: Label 'File %1 already exists. Check the %2 in %3 %4.', Comment = '%1 = file name, %2 file patch, the bank account table, the identifier in the bank account table, ie the .No';
        ExportDetailsFileNotStartedErr: Label 'Cannot export details until an export file is started.';
        InvalidPaymentSpecErr: Label 'Either %1 or %2 must refer to either a %3 or a %4 for an electronic payment.', Comment = '%1 = Account Type, %2 = the account,%3 = Vendor table, %4 = Customer table';
        VendorBankAccErr: Label 'Vendor No. %1 has no bank account setup for electronic payments.', Comment = 'The Vendor No';
        VendorMoreThanOneBankAccErr: Label 'Vendor No. %1 has more than one bank account setup for electronic payments.', Comment = '%1 = The Vendor No.';
        CustBankAccErr: Label 'Customer No. %1 has no bank account setup for electronic payments.', Comment = '%1 the Customer No.';
        CustMoreThanOneBankAccErr: Label 'Customer No. %1 has more than one bank account setup for electronic payments.', Comment = '%1 the customer No.';
        ExportFileNotEndedFileNotStartedErr: Label 'Cannot end export file until an export file is started.';
        FileDoesNoteExistErr: Label 'File %1 does not exist.', Comment = '%1 = the file name.';
        DidTransmissionWorkQst: Label 'Did the transmission work properly?';
        CustomerBlockedErr: Label '%1 is blocked for %2 processing.', Comment = '%1 = account type, %2 = customer.blocked';
        PrivacyBlockedErr: Label '%1 is blocked for privacy.', Comment = '%1 = accountant type';
        Vendor: Record Vendor;
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        CompanyInformation: Record "Company Information";
        RBMgt: Codeunit "File Management";
        ExportFile: File;
        TotalFileDebit: Decimal;
        TotalFileCredit: Decimal;
        RecordLength: Integer;
        NoOfRec: Integer;
        Justification: Option Left,Right;
        FileName: Text;
        FileIsInProcess: Boolean;
        FileDate: Date;
        ModifierValues: array[26] of Code[1];
        TraceNo: Integer;
        PaymentsThisAcct: Integer;
        DemandDebitErr: Label 'Demand Debits are not supported. Check sign on %1 %2, %3 %4, %5 %6.', Comment = '%1= Journal Template Name Caption, %2 = Journal Template Name,%3=Journal Batch Name Caption,%4=Journal Batch Name,%5=Line No. Caption,%6=Line No.';
        ConfirmTransmissioinQst: Label 'You must now run the program that transmits the payments file to the bank. Transmit the file named %1 located at %2 to %3 (%4 %5 %6).  After the transmission is completed, you will be asked if it worked correctly.  Are you ready to transmit (answer No to cancel the transmission process)?', Comment = '%1 = full  filename, %2 = file path, %3 = file name, %4 = bank account table, %5 = bank account no.caption, %6 = bank account no. ';
        Transactions: Integer;
        CurrencyType: Code[3];
        NoOfCustInfoRec: Integer;
        AcctNo: Code[20];
        AcctName: Text[30];
        AcctLanguage: Option "E  English","F  French";
        RecipientAddress: Text[80];
        RecipientCity: Text[30];
        RecipientCountryCode: Text[30];
        RecipientCounty: Text[30];
        RecipientPostCode: Code[20];
        RecipientBankAcctNo: Text[30];
        RecipientTransitNo: Text[20];
        RecipientBankNo: Text[20];
        RecipientBankAcctCurrencyCode: Code[10];
        RecipientBankAcctCountryCode: Code[10];

    procedure StartExportFile(BankAccountNo: Code[20]; GenJnlLine: Record "Gen. Journal Line")
    var
        GLSetup: Record "General Ledger Setup";
        FileHeaderRec: Text[250];
        i: Integer;
    begin
        BuildIDModifier;
        if FileIsInProcess then
            Error(ExportInProcessErr, FileName);

        CompanyInformation.Get();
        CompanyInformation.TestField("Federal ID No.");

        with BankAccount do begin
            LockTable();
            Get(BankAccountNo);
            TestField("Export Format", "Export Format"::CA);
            TestField("Transit No.");
            TestField("E-Pay Export File Path");
            if "E-Pay Export File Path"[StrLen("E-Pay Export File Path")] <> '\' then
                Error(ExportFilePathErr,
                  FieldCaption("E-Pay Export File Path"),
                  TableCaption,
                  "No.");
            TestField("Last E-Pay Export File Name");
            TestField("Bank Acc. Posting Group");
            TestField(Blocked, false);
            TestField("Client No.");
            TestField("Client Name");

            if GenJnlLine."Bank Payment Type" =
               GenJnlLine."Bank Payment Type"::"Electronic Payment-IAT"
            then begin
                GenJnlLine.TestField("Transaction Code");
                GenJnlLine.TestField("Company Entry Description");
            end;

            "Last E-Pay Export File Name" := IncStr("Last E-Pay Export File Name");
            FileName := RBMgt.ServerTempFileName('');
            if "Last ACH File ID Modifier" = '' then
                "Last ACH File ID Modifier" := '1'
            else begin
                i := 1;
                while (i < ArrayLen(ModifierValues)) and
                      ("Last ACH File ID Modifier" <> ModifierValues[i])
                do
                    i := i + 1;
                if i = ArrayLen(ModifierValues) then
                    i := 1
                else
                    i := i + 1;
                "Last ACH File ID Modifier" := ModifierValues[i];
            end;
            "Last E-Pay File Creation No." := "Last E-Pay File Creation No." + 1;
            Modify;

            if Exists(FileName) then
                Error(FileAlreadyExistsErr,
                  FileName,
                  FieldCaption("Last E-Pay Export File Name"),
                  TableCaption,
                  "No.");
            ExportFile.TextMode(true);
            ExportFile.WriteMode(true);
            ExportFile.Create(FileName);

            FileIsInProcess := true;
            FileDate := Today;
            NoOfRec := 0;
            NoOfCustInfoRec := 0;
            TotalFileDebit := 0;
            TotalFileCredit := 0;
            RecordLength := 152;
            Transactions := 0;
            FileHeaderRec := '';
            ExportPrnString(FileHeaderRec);

            FileHeaderRec := '';
            AddNumToPrnString(FileHeaderRec, NoOfRec, 1, 6);                              // Record Count
            AddToPrnString(FileHeaderRec, 'A', 7, 1, Justification::Left, ' ');             // Record Type
            AddToPrnString(FileHeaderRec, 'HDR', 8, 3, Justification::Left, ' ');           // Transaction Code
            AddToPrnString(FileHeaderRec, "Client No.", 11, 10, Justification::Left, '0');  // Client Number
            AddToPrnString(FileHeaderRec, "Client Name", 21, 30, Justification::Left, ' '); // Client Name
            AddNumToPrnString(FileHeaderRec, "Last E-Pay File Creation No.", 51, 4);      // File Creation Number
            AddNumToPrnString(FileHeaderRec, JulianDate(FileDate), 55, 7);                // File Creation Date
            if GenJnlLine."Currency Code" = '' then begin
                GLSetup.Get();
                CurrencyType := GLSetup."LCY Code";
            end else
                CurrencyType := GenJnlLine."Currency Code";
            AddToPrnString(FileHeaderRec, CurrencyType, 62, 3, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, '1', 65, 1, Justification::Left, ' ');            // Input Type
            AddToPrnString(FileHeaderRec, ' ', 66, 15, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, ' ', 81, 6, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, ' ', 87, 8, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, ' ', 95, 9, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, ' ', 104, 46, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, ' ', 150, 2, Justification::Left, ' ');
            AddToPrnString(FileHeaderRec, ' ', 152, 1, Justification::Left, ' ');
            ExportPrnString(FileHeaderRec);
        end;
    end;

    procedure ExportElectronicPayment(GenJnlLine: Record "Gen. Journal Line"; PaymentAmount: Decimal; SettleDate: Date): Code[30]
    var
        DemandCredit: Boolean;
    begin
        if not FileIsInProcess then
            Error(ExportDetailsFileNotStartedErr);
        // NOTE:  If PaymentAmount is Positive, then we are Receiving money.
        // If PaymentAmount is Negative, then we are Sending money.
        if PaymentAmount = 0 then
            exit('');
        DemandCredit := (PaymentAmount < 0);
        PaymentAmount := Abs(PaymentAmount);
        if DemandCredit then
            TotalFileCredit := TotalFileCredit + PaymentAmount
        else
            TotalFileDebit := TotalFileDebit + PaymentAmount;
        with GenJnlLine do begin
            if not DemandCredit then // for now, this is not supported for Canada
                Error(DemandDebitErr,
                  FieldCaption("Journal Template Name"), "Journal Template Name",
                  FieldCaption("Journal Batch Name"), "Journal Batch Name",
                  FieldCaption("Line No."), "Line No.");

            GetRecipientData(GenJnlLine);
            WriteRecord(GenJnlLine, PaymentAmount, SettleDate);
        end;

        exit(GenerateFullTraceNoCode(TraceNo));
    end;

    procedure EndExportFile(): Boolean
    var
        FileControlRec: Text[250];
        ClientFile: Text;
    begin
        if not FileIsInProcess then
            Error(ExportFileNotEndedFileNotStartedErr);

        FileIsInProcess := false;

        FileControlRec := '';
        AddNumToPrnString(FileControlRec, NoOfRec, 1, 6);                                         // Record Count
        AddToPrnString(FileControlRec, 'Z', 7, 1, Justification::Left, ' ');                        // Record Type
        AddToPrnString(FileControlRec, 'TRL', 8, 3, Justification::Left, ' ');                      // Transaction Code
        AddToPrnString(FileControlRec, BankAccount."Client No.", 11, 10, Justification::Left, '0'); // Client Number
        AddNumToPrnString(FileControlRec, Transactions, 21, 6);                                   // Number of Credit Payment Transactions
        AddAmtToPrnString(FileControlRec, TotalFileCredit, 27, 14);                               // Total Value of Credit Payment Transactions
        AddToPrnString(FileControlRec, ' ', 41, 6, Justification::Left, '0');
        AddToPrnString(FileControlRec, ' ', 47, 14, Justification::Left, '0');
        AddNumToPrnString(FileControlRec, 0, 61, 2);                                              // Zero Fill
        AddNumToPrnString(FileControlRec, NoOfCustInfoRec, 63, 6);                                // Number of Cust. Info Records
        AddToPrnString(FileControlRec, ' ', 69, 12, Justification::Left, ' ');
        AddToPrnString(FileControlRec, ' ', 81, 6, Justification::Left, ' ');
        AddToPrnString(FileControlRec, ' ', 87, 63, Justification::Left, ' ');
        AddToPrnString(FileControlRec, ' ', 150, 2, Justification::Left, ' ');
        AddToPrnString(FileControlRec, ' ', 152, 1, Justification::Left, ' ');
        ExportPrnString(FileControlRec);
        ExportFile.Close;

        ClientFile := BankAccount."E-Pay Export File Path" + BankAccount."Last E-Pay Export File Name";
        RBMgt.DownloadToFile(FileName, ClientFile);
        Erase(FileName);
        exit(true);
    end;

    local procedure GenerateFullTraceNoCode(TraceNo: Integer): Code[30]
    var
        TraceCode: Text[250];
    begin
        TraceCode := '';
        AddNumToPrnString(TraceCode, BankAccount."Last E-Pay File Creation No.", 1, 6);
        AddNumToPrnString(TraceCode, TraceNo, 7, 6);
        exit(TraceCode);
    end;

    local procedure AddNumToPrnString(var PrnString: Text[250]; Number: Integer; StartPos: Integer; Length: Integer)
    var
        TmpString: Text[250];
    begin
        TmpString := DelChr(Format(Number), '=', '.,-');
        AddToPrnString(PrnString, TmpString, StartPos, Length, Justification::Right, '0');
    end;

    local procedure AddAmtToPrnString(var PrnString: Text[250]; Amount: Decimal; StartPos: Integer; Length: Integer)
    var
        TmpString: Text[250];
        I: Integer;
    begin
        TmpString := Format(Amount);
        I := StrPos(TmpString, '.');
        case true of
            I = 0:
                TmpString := TmpString + '.00';
            I = StrLen(TmpString) - 1:
                TmpString := TmpString + '0';
        end;
        TmpString := DelChr(TmpString, '=', '.,-');
        AddToPrnString(PrnString, TmpString, StartPos, Length, Justification::Right, '0');
    end;

    procedure AddFedIDToPrnString(var PrnString: Text[250]; FedID: Text[30]; StartPos: Integer; Length: Integer)
    begin
        AddToPrnString(PrnString, '1' + DelChr(FedID, '=', ' .,-'), StartPos, Length, Justification::Left, ' ');
    end;

    local procedure AddToPrnString(var PrnString: Text[251]; SubString: Text[250]; StartPos: Integer; Length: Integer; Justification: Option Left,Right; Filler: Text[1])
    var
        I: Integer;
        SubStrLen: Integer;
    begin
        SubString := UpperCase(DelChr(SubString, '<>', ' '));
        SubStrLen := StrLen(SubString);

        if SubStrLen > Length then begin
            SubString := CopyStr(SubString, 1, Length);
            SubStrLen := Length;
        end;

        if Justification = Justification::Right then
            for I := 1 to (Length - SubStrLen) do
                SubString := Filler + SubString
        else
            for I := SubStrLen + 1 to Length do
                SubString := SubString + Filler;

        if StrLen(PrnString) >= StartPos then
            if StartPos > 1 then
                PrnString := CopyStr(PrnString, 1, StartPos - 1) + SubString + CopyStr(PrnString, StartPos)
            else
                PrnString := SubString + PrnString
        else begin
            for I := StrLen(PrnString) + 1 to StartPos - 1 do
                PrnString := PrnString + ' ';
            PrnString := PrnString + SubString;
        end;
    end;

    local procedure ExportPrnString(var PrnString: Text[250])
    begin
        PrnString := PadStr(PrnString, RecordLength, ' ');
        ExportFile.Write(PrnString);
        NoOfRec := NoOfRec + 1;
        PrnString := '';
    end;

    local procedure GetRecipientData(GenJournalLine: Record "Gen. Journal Line")
    var
        AcctType: Text[1];
    begin
        with GenJournalLine do begin
            if "Account Type" = "Account Type"::Vendor then begin
                AcctType := 'V';
                AcctNo := "Account No.";
            end else
                if "Account Type" = "Account Type"::Customer then begin
                    AcctType := 'C';
                    AcctNo := "Account No.";
                end else
                    if "Bal. Account Type" = "Bal. Account Type"::Vendor then begin
                        AcctType := 'V';
                        AcctNo := "Bal. Account No.";
                    end else
                        if "Bal. Account Type" = "Bal. Account Type"::Customer then begin
                            AcctType := 'C';
                            AcctNo := "Bal. Account No.";
                        end else
                            Error(InvalidPaymentSpecErr,
                              FieldCaption("Account Type"), FieldCaption("Bal. Account Type"), Vendor.TableCaption, Customer.TableCaption);
            if AcctType = 'V' then
                GetRecipientDataFromVendor
            else
                if AcctType = 'C' then
                    GetRecipientDataFromCustomer(GenJournalLine);
        end;
    end;

    local procedure GetRecipientDataFromVendor()
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if AcctNo <> Vendor."No." then begin
            Vendor.Get(AcctNo);
            Vendor.TestField(Blocked, Vendor.Blocked::" ");
            Vendor.TestField("Privacy Blocked", false);
            PaymentsThisAcct := 0;
        end else
            PaymentsThisAcct := PaymentsThisAcct + 1;
        AcctName := CopyStr(Vendor.Name, 1, 30);
        AcctLanguage := Vendor."Bank Communication";
        RecipientAddress := CopyStr(Vendor.Address, 1, 35) + ' ' + CopyStr(Vendor."Address 2", 1, 35);
        RecipientCity := Vendor.City;
        RecipientCountryCode := Vendor."Country/Region Code";
        RecipientCounty := Vendor.County;
        RecipientPostCode := Vendor."Post Code";
        VendorBankAccount.SetRange("Vendor No.", AcctNo);
        VendorBankAccount.SetRange("Use for Electronic Payments", true);
        if VendorBankAccount.Count < 1 then
            Error(VendorBankAccErr, AcctNo);
        if VendorBankAccount.Count > 1 then
            Error(VendorMoreThanOneBankAccErr, AcctNo);
        VendorBankAccount.FindFirst;
        VendorBankAccount.TestField("Bank Account No.");
        RecipientBankNo := VendorBankAccount."Bank Branch No.";
        RecipientTransitNo := VendorBankAccount."Transit No.";
        RecipientBankAcctNo := VendorBankAccount."Bank Account No.";
        RecipientBankAcctCurrencyCode := VendorBankAccount."Currency Code";
        RecipientBankAcctCountryCode := VendorBankAccount."Country/Region Code";
    end;

    local procedure GetRecipientDataFromCustomer(GenJournalLine: Record "Gen. Journal Line")
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if AcctNo <> Customer."No." then begin
            Customer.Get(AcctNo);
            if Customer."Privacy Blocked" then
                Error(PrivacyBlockedErr, GenJournalLine."Account Type");

            if Customer.Blocked = Customer.Blocked::All then
                Error(CustomerBlockedErr, GenJournalLine."Account Type", Customer.Blocked);
            PaymentsThisAcct := 0;
        end else
            PaymentsThisAcct := PaymentsThisAcct + 1;
        AcctName := CopyStr(Customer.Name, 1, 30);
        AcctLanguage := Customer."Bank Communication";
        RecipientAddress := CopyStr(Customer.Address, 1, 35) + ' ' + CopyStr(Customer."Address 2", 1, 35);
        RecipientCity := Customer.City;
        RecipientCountryCode := Customer."Country/Region Code";
        RecipientCounty := Customer.County;
        RecipientPostCode := Customer."Post Code";
        CustomerBankAccount.SetRange("Customer No.", AcctNo);
        CustomerBankAccount.SetRange("Use for Electronic Payments", true);
        if CustomerBankAccount.Count < 1 then
            Error(CustBankAccErr, AcctNo);
        if CustomerBankAccount.Count > 1 then
            Error(CustMoreThanOneBankAccErr, AcctNo);
        CustomerBankAccount.FindFirst;
        CustomerBankAccount.TestField("Bank Account No.");
        RecipientBankNo := CustomerBankAccount."Bank Branch No.";
        RecipientTransitNo := CustomerBankAccount."Transit No.";
        RecipientBankAcctNo := CustomerBankAccount."Bank Account No.";
        RecipientBankAcctCurrencyCode := CustomerBankAccount."Currency Code";
        RecipientBankAcctCountryCode := CustomerBankAccount."Country/Region Code"
    end;

    local procedure JulianDate(NormalDate: Date): Integer
    var
        Year: Integer;
        Days: Integer;
    begin
        Year := Date2DMY(NormalDate, 3);
        Days := (NormalDate - DMY2Date(1, 1, Year)) + 1;
        exit(Year * 1000 + Days);
    end;

    local procedure BuildIDModifier()
    begin
        ModifierValues[1] := 'A';
        ModifierValues[2] := 'B';
        ModifierValues[3] := 'C';
        ModifierValues[4] := 'D';
        ModifierValues[5] := 'E';
        ModifierValues[6] := 'F';
        ModifierValues[7] := 'G';
        ModifierValues[8] := 'H';
        ModifierValues[9] := 'I';
        ModifierValues[10] := 'J';
        ModifierValues[11] := 'K';
        ModifierValues[12] := 'L';
        ModifierValues[13] := 'M';
        ModifierValues[14] := 'N';
        ModifierValues[15] := 'O';
        ModifierValues[16] := 'P';
        ModifierValues[17] := 'Q';
        ModifierValues[18] := 'R';
        ModifierValues[19] := 'S';
        ModifierValues[20] := 'T';
        ModifierValues[21] := 'U';
        ModifierValues[22] := 'V';
        ModifierValues[23] := 'W';
        ModifierValues[24] := 'X';
        ModifierValues[25] := 'Y';
        ModifierValues[26] := 'Z';
    end;

    procedure TransmitExportedFile(BankAccountNo: Code[20]; FName: Text)
    var
        ExportFullPathName: Text;
        TransmitFullPathName: Text;
    begin
        with BankAccount do begin
            Get(BankAccountNo);
            TestField("E-Pay Export File Path");
            if "E-Pay Export File Path"[StrLen("E-Pay Export File Path")] <> '\' then
                Error(ExportFilePathErr,
                  FieldCaption("E-Pay Export File Path"),
                  TableCaption,
                  "No.");
            TestField("E-Pay Trans. Program Path");
            if "E-Pay Trans. Program Path"[StrLen("E-Pay Trans. Program Path")] <> '\' then
                Error(ExportFilePathErr,
                  FieldCaption("E-Pay Trans. Program Path"),
                  TableCaption,
                  "No.");
            ExportFullPathName := "E-Pay Export File Path" + FName;
            TransmitFullPathName := "E-Pay Trans. Program Path" + FName;

            if not RBMgt.ClientFileExists(ExportFullPathName) then
                Error(FileDoesNoteExistErr, FName);
            RBMgt.CopyClientFile(ExportFullPathName, TransmitFullPathName, true);

            if Confirm(ConfirmTransmissioinQst, true, FName, "E-Pay Trans. Program Path", Name, TableCaption, FieldCaption("No."), "No.") then
                if Confirm(DidTransmissionWorkQst) then
                    RBMgt.DeleteClientFile(ExportFullPathName);
        end;
    end;

    local procedure WriteRecord(GenJournalLine: Record "Gen. Journal Line"; PaymentAmount: Decimal; SettleDate: Date)
    var
        DetailRec: Text[250];
        IATAddressInfo1Rec: Text[250];
        IATAddressInfo2Rec: Text[250];
        IATRemittanceRec: Text[250];
    begin
        with GenJournalLine do begin
            Transactions := Transactions + 1;
            DetailRec := '';
            TraceNo := NoOfRec;
            AddNumToPrnString(DetailRec, NoOfRec, 1, 6);                                          // Record Count
            AddToPrnString(DetailRec, 'C', 7, 1, Justification::Left, ' ');
            AddToPrnString(DetailRec, "Transaction Code", 8, 3, Justification::Left, ' ');          // Transaction Code
            AddToPrnString(DetailRec, BankAccount."Client No.", 11, 10, Justification::Left, '0');  // Client Number
            AddToPrnString(DetailRec, ' ', 21, 1, Justification::Left, ' ');
            AddToPrnString(DetailRec, AcctNo, 22, 19, Justification::Left, ' ');                    // Customer Number
            AddNumToPrnString(DetailRec, PaymentsThisAcct, 41, 2);                                // Payment Number
            if RecipientBankAcctCountryCode = 'CA' then begin
                AddToPrnString(DetailRec, RecipientBankNo, 43, 4, Justification::Right, '0');        // Bank No.
                AddToPrnString(DetailRec, RecipientTransitNo, 47, 5, Justification::Right, '0');     // Transit No.
            end else
                if RecipientBankAcctCountryCode = 'US' then
                    AddToPrnString(DetailRec, RecipientTransitNo, 43, 9, Justification::Right, '0');

            AddToPrnString(DetailRec, RecipientBankAcctNo, 52, 18, Justification::Left, ' ');
            AddToPrnString(DetailRec, ' ', 70, 1, Justification::Left, ' ');
            AddAmtToPrnString(DetailRec, PaymentAmount, 71, 10);                                  // Payment Amount
            AddToPrnString(DetailRec, ' ', 81, 6, Justification::Left, ' ');
            AddNumToPrnString(DetailRec, JulianDate(SettleDate), 87, 7);                          // Payment Date
            AddToPrnString(DetailRec, AcctName, 94, 30, Justification::Left, ' ');                  // Customer Name
            AddToPrnString(DetailRec, Format(AcctLanguage), 124, 1, Justification::Left, ' ');      // Language Code
            AddToPrnString(DetailRec, ' ', 125, 1, Justification::Left, ' ');
            AddToPrnString(DetailRec, BankAccount."Client Name", 126, 15, Justification::Left, ' ');// Client Name
            if RecipientBankAcctCurrencyCode = '' then
                AddToPrnString(DetailRec, CurrencyType, 141, 3, Justification::Left, ' ')
            else
                AddToPrnString(DetailRec, RecipientBankAcctCurrencyCode, 141, 3, Justification::Left, ' ');
            AddToPrnString(DetailRec, ' ', 144, 1, Justification::Left, ' ');
            if RecipientCountryCode = 'CA' then
                AddToPrnString(DetailRec, 'CAN', 145, 3, Justification::Left, ' ')
            else
                if RecipientCountryCode = 'US' then
                    AddToPrnString(DetailRec, 'USA', 145, 3, Justification::Left, ' ');
            AddToPrnString(DetailRec, ' ', 148, 2, Justification::Left, ' ');
            AddToPrnString(DetailRec, ' ', 150, 2, Justification::Left, ' ');
            AddToPrnString(DetailRec, 'N', 152, 1, Justification::Left, ' ');                       // No Optional Records Follow

            ExportPrnString(DetailRec);
            IATAddressInfo1Rec := '';
            AddNumToPrnString(IATAddressInfo1Rec, NoOfRec, 1, 6);
            AddToPrnString(IATAddressInfo1Rec, 'C', 7, 1, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo1Rec, 'AD1', 8, 3, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo1Rec, BankAccount."Client No.", 11, 10, Justification::Left, '0');
            AddToPrnString(IATAddressInfo1Rec, CompanyInformation.Name, 21, 30, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo1Rec, CopyStr(CompanyInformation.Address, 1, 35) + ' ' +
              CopyStr(CompanyInformation."Address 2", 1, 35), 51, 35, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo1Rec, CompanyInformation.City + '*' + CompanyInformation.County +
              '\', 86, 35, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo1Rec, CompanyInformation."Country/Region Code" + '*' + CompanyInformation."Post Code" +
              '\', 121, 32, Justification::Left, ' ');

            ExportPrnString(IATAddressInfo1Rec);
            NoOfCustInfoRec += 1;

            IATAddressInfo2Rec := '';
            AddNumToPrnString(IATAddressInfo2Rec, NoOfRec, 1, 6);
            AddToPrnString(IATAddressInfo2Rec, 'C', 7, 1, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, 'AD2', 8, 3, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, BankAccount."Client No.", 11, 10, Justification::Left, '0');
            AddToPrnString(IATAddressInfo2Rec, RecipientAddress, 21, 35, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, RecipientCity + '*' + RecipientCounty + '\', 56, 35, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, RecipientCountryCode + '*' + RecipientPostCode + '\', 91, 35, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, Format("Transaction Type Code"), 126, 3, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, "Company Entry Description", 129, 10, Justification::Left, ' ');
            AddToPrnString(IATAddressInfo2Rec, ' ', 139, 14, Justification::Left, ' ');

            ExportPrnString(IATAddressInfo2Rec);
            NoOfCustInfoRec += +1;

            if ("Payment Related Information 1" <> '') or ("Payment Related Information 2" <> '') then begin
                IATRemittanceRec := '';
                AddNumToPrnString(IATRemittanceRec, NoOfRec, 1, 6);
                AddToPrnString(IATRemittanceRec, 'C', 7, 1, Justification::Left, ' ');
                AddToPrnString(IATRemittanceRec, 'REM', 8, 3, Justification::Left, ' ');
                AddToPrnString(IATRemittanceRec, BankAccount."Client No.", 11, 10, Justification::Left, '0');
                AddToPrnString(IATRemittanceRec, "Payment Related Information 1", 21, 80, Justification::Left, ' ');
                AddToPrnString(IATRemittanceRec, "Payment Related Information 2", 101, 52, Justification::Left, ' ');

                ExportPrnString(IATRemittanceRec);
                NoOfCustInfoRec += +1;
            end;
        end;
    end;
}

