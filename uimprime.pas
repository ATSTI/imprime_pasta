unit uImprime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ACBrPosPrinter, IniFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    ACBrPosPrinter1: TACBrPosPrinter;
    memImp: TMemo;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    portaImp: String;
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
  arquivo : TStringList;
  busca: TSearchRec;
  i: Integer;
begin
  // listar aquivos no diretorio
  {
  arquivo := TStringList.Create;
  try
    i := FindFirst('C:\home\imp', 0, busca);
    While i = 0 do
    begin
      arquivo.Add(copy(busca.Name,1,Pos('.',busca.Name)-1));
      i := FindNext(busca);
    end;
    memImp.Text:=arquivo;
  except
    arquivo.Free;
    raise;
  end;}
  if (not FileExists('c:\home\imp\imp.txt')) then
  begin
    memImp.Clear;
    memImp.Lines.Add('Sem impressão.');
    exit;
  end;
  arquivo := TStringList.Create;
  try
    arquivo.LoadFromFile('c:\home\imp\imp.txt');
    memImp.Clear;
    memImp.Text:= arquivo.Text;
  finally
    arquivo.Free;
  end;
  DeleteFile('c:\home\imp\imp.txt');
  ACBrPosPrinter1.Desativar;
  ACBrPosPrinter1.LinhasBuffer := 0;
  ACBrPosPrinter1.LinhasEntreCupons := espacoEntreLinhas;
  //ACBrPosPrinter1.EspacoEntreLinhas := 0;
  ACBrPosPrinter1.ColunasFonteNormal := 48;
  ACBrPosPrinter1.Porta  := portaImp;
  //ACBrPosPrinter1.ControlePorta := cbControlePorta.Checked;
  ACBrPosPrinter1.CortaPapel := True;
  //ACBrPosPrinter1.TraduzirTags := cbTraduzirTags.Checked;
  //ACBrPosPrinter1.IgnorarTags := cbIgnorarTags.Checked;
  // ACBrPosPrinter1.PaginaDeCodigo := TACBrPosPaginaCodigo( cbxPagCodigo.ItemIndex );
  // ACBrPosPrinter1.ConfigBarras.MostrarCodigo := cbHRI.Checked;
  // ACBrPosPrinter1.ConfigBarras.LarguraLinha := seBarrasLargura.Value;
  // ACBrPosPrinter1.ConfigBarras.Altura := seBarrasAltura.Value;
  // ACBrPosPrinter1.ConfigQRCode.Tipo := seQRCodeTipo.Value;
  // ACBrPosPrinter1.ConfigQRCode.LarguraModulo := seQRCodeLarguraModulo.Value;
  // ACBrPosPrinter1.ConfigQRCode.ErrorLevel := seQRCodeErrorLevel.Value;
  // ACBrPosPrinter1.ConfigLogo.KeyCode1 := seLogoKC1.Value;
  // ACBrPosPrinter1.ConfigLogo.KeyCode2 := seLogoKC2.Value;
  // ACBrPosPrinter1.ConfigLogo.FatorX := seLogoFatorX.Value;
  // ACBrPosPrinter1.ConfigLogo.FatorY := seLogoFatorY.Value;
  ACBrPosPrinter1.Modelo := TACBrPosPrinterModelo(modeloImp);
  ACBrPosPrinter1.Ativar ;

  ACBrPosPrinter1.Buffer.Text := MemImp.Lines.Text;
  ACBrPosPrinter1.Imprimir;

end;

procedure TForm1.FormShow(Sender: TObject);
var path_exe: String;
    conf: TIniFile;
begin
  path_exe := ExtractFilePath(ParamStr(0));
  conf := TIniFile.Create(path_exe + 'conf.ini');
  try
    portaImp := conf.ReadString('IMPRESSORA', 'porta', '');
    ModeloImp := conf.ReadInteger('IMPRESSORA', 'Modelo', 0);
    //CupomImp := conf.ReadString('IMPRESSORA', 'Cupom', 'Texto');
    espacoEntreLinhas := conf.ReadInteger('IMPRESSORA', 'EspacoEntreLinhas', 10);
  finally
    conf.Free;
  end;
end;

end.

