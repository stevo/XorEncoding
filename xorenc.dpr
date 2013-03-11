{by Blazej Kosmowski}
program xorenc;   //ver.2.0.1

uses
  SysUtils,
  Forms,
  Dialogs,
  Unit1 in 'Unit1.pas' {PswdForm},
  progress in 'progress.pas' {GaugeForm};

{$R *.RES}

var
  I: Integer;

begin
if ParamCount = 0 then  // If there are no parameters, then execute OpenFile Dialog
  begin
   
    with TOpenDialog.Create(nil) do
    try
      DefaultExt := '.txt';
       if Execute then //Execute TOpenDialog

      Begin
       input:=Filename;      //Get FileName into input Variable

          If input='' THEN Application.Terminate;  //Define proper extension
            If copy(input,Length(input)-2,3)='xor' THEN
                output:=copy(input,1,Length(input)-4) ELSE
                output:=input+'.xor';
       end;

    finally
      Free;  //Free OpenDialog Instance

    end;
  end
  //If there are parameters - assume that the first one is the file to encode
  else begin
    //ShowMessage('Params are here :-D');
    for I := 1 to ParamCount do
     begin
      if input <> '' then input := input + ' ';  //Get a little space between program executable and param name :)
      input := input + ParamStr(I);

       If copy(input,Length(input)-2,3)='xor' THEN
        output:=copy(input,1,Length(input)-4) ELSE
         output:=input+'.xor';
        end;
  end;



  // exit application if file to encode cannot be found
  if (input = '') or not FileExists(input) then
    MessageDlg(Format('File "%s" not found for encoding!'+#10#13+' Please, try again...', [input]), mtError, [mbOk], 0)
  else
   begin
    // If all is OK, run application
     Application.Initialize;
     Application.CreateForm(TPswdForm, PswdForm);
  Application.CreateForm(TGaugeForm, GaugeForm);
  Application.Run;
  end;
end.










