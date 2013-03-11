unit modules;

interface

uses
  SysUtils, Classes, Dialogs;

type
  TDataModule2 = class(TDataModule)
    Open: TOpenDialog;
    Save: TSaveDialog;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule2: TDataModule2;

implementation

{$R *.dfm}

end.
