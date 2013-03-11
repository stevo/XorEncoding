{by Blazej Kosmowski}
unit Unit1;    // ver.2.1.0

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Gauges, ComCtrls;
type
  TPswdForm = class(TForm)
    First: TLabeledEdit;
    Second: TLabeledEdit;
    OKButton: TBitBtn;
    DelCB: TCheckBox;
    Bevel1: TBevel;
    CancelButton: TBitBtn;
    StatusBar1: TStatusBar;
    CheckBox1: TCheckBox;
    FUNCTION XorChar(a,b : CHAR):Char;
    FUNCTION AssignWriteMode(filename : STRING) : WORD;
    PROCEDURE EncDecFile (input, output : STRING);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE EncodeBuffer (password : STRING) ;
    PROCEDURE DeleteSourceFile(filename : STRING);
    PROCEDURE OKButtonClick(Sender: TObject);
    PROCEDURE CancelButtonClick(Sender: TObject);
    PROCEDURE FirstKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    PROCEDURE SecondKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    PROCEDURE FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
END;


CONST ReadSize = 1024;

VAR
  PswdForm     : TPswdForm;
  input,output : String;                                //i/o file names
  source       : TFileStream;                           //file streams
  destination  : TFileStream;
  A            : ARRAY [0..ReadSize] OF CHAR;          //buffers for storing chars
  buffer       : Array [0..ReadSize] Of Char;
  Password     : String;                              //password's string
  RedSize      : Integer;

IMPLEMENTATION

USES modules, progress;

{$R *.dfm}


{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}

//Function for XOR'ing character with character from specified string on specified position
Function TPswdForm.XorChar(a,b :Char):Char;
BEGIN
Result:=Chr( Ord(a) xor Ord(b) );
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
//Procedure creating encoded array
PROCEDURE TPswdForm.EncodeBuffer (password : STRING) ;
VAR pwdln       : BYTE;
    i           : INTEGER;
BEGIN
pwdln:=Length(password);
FOR i:=0 TO RedSize  DO
   BEGIN
        A[i]:=XorChar(buffer[i],password[i mod pwdln]);
   END;
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
//Function choosing appropriate WriteToFile Mode
FUNCTION TPswdForm.AssignWriteMode(filename : STRING) : WORD;
VAR FileAttributes : INTEGER;
BEGIN
 If FileExists(filename) THEN    {This block manages opening file }
    BEGIN
     WITH Application DO
      If MessageBox('Output file with specified name already exist. Overwrite?', 'Overwrite?', mb_OkCancel)=IdCancel THEN
       Application.Terminate() ELSE
         FileAttributes := FileGetAttr(output);
          if FileAttributes=-1 THEN
            BEGIN
             MessageDlg('Unable to access output file due to application unhnadled exception', mtError, [mbOK], 0);
            END ELSE
          IF FileAttributes AND faReadOnly <> 0 then
           BEGIN
            If Application.MessageBox('File is Read-Only! Do you want to change it to read/write?','File is Read-Only',mb_OkCancel)=IdCancel THEN
             Application.Terminate() ELSE FileSetAttr(output,  FileAttributes + faReadOnly);
              Result:=fmOpenWrite;
           END ELSE Result:=fmOpenWrite;
        END ELSE Result:=fmCreate;
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
//Procedure dealing with deleting source file after encoding
PROCEDURE TPswdForm.DeleteSourceFile(filename : STRING);
VAR FileAttributes : INTEGER;
BEGIN
FileAttributes := FileGetAttr(filename);
          if FileAttributes=-1 THEN
            BEGIN
             MessageDlg('Unable to access input file due to application unhnadled exception', mtError, [mbOK], 0);
            END
            ELSE
          IF FileAttributes AND faReadOnly <> 0 then
           BEGIN
            If Application.MessageBox('Input File is Read-Only! Do you want to delete it anyway?','File is Read-Only',mb_OkCancel)=IdCancel THEN
             Application.Terminate()
             ELSE
              BEGIN
                FileSetAttr(filename,  FileAttributes + faReadOnly);
               DeleteFile(filename);
              END;
           END ELSE DeleteFile(filename);
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
//Function that reads data stream from one file and writes it into another in encoded form
PROCEDURE TPswdForm.EncDecFile (input, output : STRING);
VAR WriteMode      : WORD;                        //Create or open file to write?
    Size           : Int64;                       //Size of file in bytes
    Pos            : Int64;                       //Position of byte in file
BEGIN
pos:=0;
WriteMode:=AssignWriteMode(output);

    source := TFileStream.Create(input, fmOpenRead);                       //Creating File Streams
    destination := TFileStream.Create(output, WriteMode);
     size:=source.size;

      If CheckBox1.Checked=FALSE THEN
        BEGIN
           GaugeForm.Show;
           PswdForm.Hide;
        END;

 WHILE NOT (pos=size) DO
   BEGIN
      If CheckBox1.Checked=FALSE THEN
        GaugeForm.Gauge1.Progress:=(pos*100)div size;

      RedSize :=source.Read(buffer,ReadSize);                            //Reads data kbyte by kbyte from file
       EncodeBuffer(password);
        destination.Write(A,RedSize);                                   //Writes encoded data byte by byte to file
         pos:=pos+RedSize ;
   END;

  GaugeForm.Gauge1.Progress:=100;
   GaugeForm.Hide ;
    Source.Free;                                                   // Closes data streams
     Destination.Free;
      ShowMessage('File Encrypted/Decrypted');

   If DelCB.Checked=TRUE THEN  DeleteSourceFile(input);            //This block manages deleting source file after encoding

Application.Terminate;
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
PROCEDURE TPswdForm.FormCreate(Sender: TObject);
BEGIN
PswdForm.FormStyle:=fsStayOnTop;END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
PROCEDURE TPswdForm.OKButtonClick(Sender: TObject);
BEGIN
 IF NOT (First.Text=Second.Text) THEN                           //Checking password integrity
   BEGIN
       ShowMessage('Passwords do not match!');
       First.SetFocus;
   END
 ELSE
   BEGIN
       Password:=First.Text;
       EncDecFile(input,output);
       Application.Terminate();
   END;
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
PROCEDURE TPswdForm.CancelButtonClick(Sender: TObject);
BEGIN
 Application.Terminate();
END;

{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
procedure TPswdForm.FirstKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key=VK_CAPITAL) THEN
   IF StatusBar1.SimpleText='CapsLock Enabled' THEN
       StatusBar1.SimpleText:='CapsLock Disabled' ELSE
         StatusBar1.SimpleText:='CapsLock Enabled';
end;

procedure TPswdForm.SecondKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key=VK_CAPITAL) THEN
   IF StatusBar1.SimpleText='CapsLock Enabled' THEN
       StatusBar1.SimpleText:='CapsLock Disabled' ELSE
         StatusBar1.SimpleText:='CapsLock Enabled';
end;

procedure TPswdForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key=VK_CAPITAL) THEN
   IF StatusBar1.SimpleText='CapsLock Enabled' THEN
       StatusBar1.SimpleText:='CapsLock Disabled' ELSE
         StatusBar1.SimpleText:='CapsLock Enabled';
end;

end.

