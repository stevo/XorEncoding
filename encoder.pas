unit Unit14;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Function XorChar(a : Char; psswd : String; pos : Integer) : Char;
    Procedure FileRewrite ({name : STRING});
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.dfm}

Function Tform1.XorChar(a : Char; psswd : String; pos : Integer) : Char;
var temp : Char;
BEGIN
temp:=psswd[pos];
Result:=Chr(Ord(a) XOR Ord(temp));
END;


Procedure TForm1.FileRewrite ({name : STRING});
var
     source      : TFileStream;
     destination : TFileStream;
     buffer      : Char;
     filename    : String;
     size        : Int64;
     pos         : Int64;
     Password    : String;
     PwdLen      : ShortInt;
Begin
pos:=0;
Password:='7362368238946389eehjefhjefhjwekuf';
PwdLen:=Length(password);

DataModule2.OpenDialog1.Execute;
FileName := DataModule2.OpenDialog1.FileName;

source := TFileStream.Create(FileName, fmOpenRead);
destination := TFileStream.Create('encoded.txt', fmCreate);
size:=source.Size;
While pos<size DO
BEGIN
 source.ReadBuffer(buffer,1);

 buffer:=XorChar(buffer, password, (pos mod pwdlen) );
 destination.WriteBuffer(buffer,1);
 Inc(pos);
END;
Source.Free;
Destination.Free;
End;




procedure TForm1.Button1Click(Sender: TObject);
begin
FileRewrite;
end;

end.
