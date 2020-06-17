unit uImprime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ACBrPosPrinter, IniFiles, IBConnection, sqldb, base64;

type

  { TForm1 }

  TForm1 = class(TForm)
    ACBrPosPrinter1: TACBrPosPrinter;
    IbCon: TIBConnection;
    memImp: TMemo;
    sqlImprime: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    portaImp: String;
    pathImp: String;
    CupomImp : String;
    espacoEntreLinhas: Integer;
    modeloImp : Integer;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  arquivo, arq : TStringList;
  busca: TSearchRec;
  i: Integer;
  nome_arq: String;
begin
  ACBrPosPrinter1.LinhasBuffer := 0;
  ACBrPosPrinter1.LinhasEntreCupons := espacoEntreLinhas;
  //ACBrPosPrinter1.ColunasFonteNormal := 48;
  ACBrPosPrinter1.Porta  := portaImp;
  memImp.Lines.Add(portaImp);
  ACBrPosPrinter1.CortaPapel := True;
  //ACBrPosPrinter1.Device.Baud := 115200;
  ACBrPosPrinter1.Modelo := TACBrPosPrinterModelo(modeloImp);
  memImp.Lines.Add(IntToStr(modeloImp));
  if (CupomImp <> 'BD') then
  begin
    // listar aquivos no diretorio
    arquivo := TStringList.Create;
    //try
      //i := FindFirst('C:\home\imp', 0, busca);
      memImp.Lines.Add(pathImp + '\*');
      i := FindFirst(pathImp + '\*', faAnyFile, busca);
      While i = 0 do
      begin
        nome_arq := busca.Name;
        if (Length(nome_arq) > 2) then
        begin
          nome_arq := pathImp + '\' + busca.Name;
          memImp.Lines.Add(nome_arq);
          arquivo.Add(nome_arq);
        end;
        i := FindNext(busca);
      end;
    //  memImp.Text:=arquivo.GetText;
    //finally;
    //  arquivo.Free;
    //end;
    for i := 0 to arquivo.Count - 1 do
    begin
      arq := TStringList.Create;
      try
        nome_arq := arquivo[i];
        arq.LoadFromFile(nome_arq);
        memImp.Clear;
        memImp.Text:= arq.Text;
        ACBrPosPrinter1.Ativar ;
        ACBrPosPrinter1.Buffer.Text := MemImp.Lines.Text;
        ACBrPosPrinter1.Imprimir;
        ACBrPosPrinter1.Desativar;
        DeleteFile(nome_arq);
      finally
        arq.Free;
      end;
    end;
    arquivo.Free;
  end
  else begin // DB
    if (sqlImprime.Active) then
      sqlImprime.Close;
    sqlImprime.SQL.Clear;
    sqlImprime.SQL.Add('SELECT * FROM AVISOS');
    sqlImprime.Open;
    While not sqlImprime.EOF do
    begin
      memImp.Text := sqlImprime.FieldByName('DESCRICAO').AsString;
      ACBrPosPrinter1.Ativar ;
      ACBrPosPrinter1.Buffer.Text := MemImp.Lines.Text;
      ACBrPosPrinter1.Imprimir;
      ACBrPosPrinter1.Desativar;
      IbCon.ExecuteDirect('DELETE FROM AVISOS WHERE CODAVISOS = ' +
        IntToStr(sqlImprime.FieldByName('CODAVISOS').AsInteger));
      sqlImprime.Next;
    end;
    SQLTransaction1.Commit;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var path_exe: String;
    conf: TIniFile;
    vstr: String;
begin
  path_exe := ExtractFilePath(ParamStr(0));
  conf := TIniFile.Create(path_exe + 'conf.ini');
  try
    portaImp := conf.ReadString('IMPRESSORA', 'porta', '');
    ModeloImp := conf.ReadInteger('IMPRESSORA', 'Modelo', 0);
    pathImp := conf.ReadString('IMPRESSORA', 'path', path_exe+'imp');
    CupomImp := conf.ReadString('IMPRESSORA', 'Cupom', 'Texto');
    //CupomImp := conf.ReadString('IMPRESSORA', 'Cupom', 'Texto');
    espacoEntreLinhas := conf.ReadInteger('IMPRESSORA', 'EspacoEntreLinhas', 10);
    if (CupomImp = 'BD') then
    begin
      IbCon.Connected:=False;
      vstr := conf.ReadString('DATABASE', 'name', '');
      IBCon.DatabaseName := vstr;
      vstr := conf.ReadString('DATABASE', 'HostName', '');
      IBCon.HostName := vstr;
      vstr := conf.ReadString('DATABASE', 'Acesso', '');
      //snh:= EncodeStringBase64(snh); // Ver a senha Encryptada
      vstr:= DecodeStringBase64(vstr);
      IBCon.Password := vstr;
      vstr := IntToStr(conf.ReadInteger('DATABASE', 'Port', 3050));
      IbCon.Params.Add('port=' + vstr);
      IbCon.Connected:=True;
    end;
  finally
    conf.Free;
  end;

end;

end.

