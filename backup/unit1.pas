unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, DateTimePicker, LCLType, Character, LazUTF8;

type

  { TForm1 }

  TForm1 = class(TForm)
    add: TButton;
    DateTimePicker1: TDateTimePicker;
    Exi: TButton;
    Label1: TLabel;
    Save: TButton;
    Delet: TButton;
    Edit: TButton;
    StringGrid1: TStringGrid;
    Visiblin: TButton;
    procedure addClick(Sender: TObject);
    procedure DeletClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure ExiClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure StringGrid1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure VisiblinClick(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DateTimePicker1Change(Sender: TObject);
  private
FCanDelete: Boolean;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ExiClick(Sender: TObject);
begin
  close;
end;

procedure TForm1.SaveClick(Sender: TObject);
var
  F: TextFile;
  i: Integer;
begin
  AssignFile(F, 'C:\Users\pro\Documents\GitHub\dkr9\car.txt');
  Rewrite(F);
  for i := 1 to StringGrid1.RowCount - 1 do
  begin
    WriteLn(F, StringGrid1.Cells[0, i] + ',' +
                  StringGrid1.Cells[1, i] + ',' +
                  StringGrid1.Cells[2, i] + ',' +
                  StringGrid1.Cells[3, i] + ',' +
                  StringGrid1.Cells[4, i]);
  end;
  CloseFile(F);
end;

procedure TForm1.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CurrentText: string;
begin
  if FCanDelete then
  begin
    if (Key = VK_BACK) then
    begin
      CurrentText := StringGrid1.Cells[StringGrid1.Col, StringGrid1.Row];
      if Length(CurrentText) > 0 then
      begin
        StringGrid1.Cells[StringGrid1.Col, StringGrid1.Row] := Copy(CurrentText, 1, Length(CurrentText) - 1);
      end;
      Key := 0;
    end;
  end
  else
  begin
    if (Key = VK_BACK) then
    begin
      Key := 0;
    end;
  end;
end;

procedure TForm1.StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var
  NewValue: string;
begin
  if (ACol in [1, 3, 4]) and (ARow > 0) then
  begin
    if Value <> '' then
    begin
      NewValue := UTF8UpperCase(UTF8Copy(Value, 1, 1)) + UTF8LowerCase(UTF8Copy(Value, 2, UTF8Length(Value) - 1));
      if NewValue <> Value then
        TStringGrid(Sender).Cells[ACol, ARow] := NewValue;
    end;
  end;
end;

procedure TForm1.StringGrid1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
var
  ch: WideChar;
begin
  if (StringGrid1.Col = 2) then
  begin
    if not (UTF8Key[1] in ['0'..'9', '.']) then
      UTF8Key := '';
    if (UTF8Key = '.') and (Pos('.', StringGrid1.Cells[2, StringGrid1.Row]) > 0) then
      UTF8Key := '';
  end;

  if (StringGrid1.Col = 1) then
  begin
    ch := UTF8ToUTF16(UTF8Key)[1];
    if not (IsLetter(ch) or (ch = ' ')) then
      UTF8Key := '';
  end;
end;

procedure TForm1.EditClick(Sender: TObject);
begin
  StringGrid1.Options := StringGrid1.Options + [goEditing];
end;

procedure TForm1.addClick(Sender: TObject);
begin
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
end;

procedure TForm1.DeletClick(Sender: TObject);
begin
  if StringGrid1.Row > 0 then
    StringGrid1.Cells[StringGrid1.Col, StringGrid1.Row] := '';
   FCanDelete := True;
end;

procedure TForm1.VisiblinClick(Sender: TObject);
var
  F: TextFile;
  Line: string;
  Cells: TStringArray;
  Row: Integer;
begin
  StringGrid1.ColCount := 5;
  StringGrid1.RowCount := 1;
  StringGrid1.Cells[0, 0] := 'Дата';
  StringGrid1.Cells[1, 0] := 'Страна';
  StringGrid1.Cells[2, 0] := 'Стоимость';
  StringGrid1.Cells[3, 0] := 'Цвет';
  StringGrid1.Cells[4, 0] := 'Марка';
  Row := 1;
  AssignFile(F, 'C:\Users\Иван\Desktop\lzrs\dkr9\car.txt');
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    ShowMessage('Файл не найден или ошибка чтения!');
    Exit;
  end;
  while not EOF(F) do
  begin
    ReadLn(F, Line);
    Cells := Line.Split([',']);
    if Length(Cells) = 5 then
    begin
      StringGrid1.RowCount := Row + 1;
      StringGrid1.Cells[0, Row] := Trim(Cells[0]);
      StringGrid1.Cells[1, Row] := Trim(Cells[1]);
      StringGrid1.Cells[2, Row] := Trim(Cells[2]);
      StringGrid1.Cells[3, Row] := Trim(Cells[3]);
      StringGrid1.Cells[4, Row] := Trim(Cells[4]);
      Inc(Row);
    end
    else
    begin
      ShowMessage('Неверный формат строки в файле: ' + Line);
    end;
  end;
  CloseFile(F);
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  R: TRect;
begin
  if ACol = 0 then
  begin
    R := StringGrid1.CellRect(ACol, ARow);
    DateTimePicker1.SetBounds(
      StringGrid1.Left + R.Left + 1,
      StringGrid1.Top + R.Top + 1,
      R.Right - R.Left - 2,
      R.Bottom - R.Top - 2);
    DateTimePicker1.Visible := True;
    DateTimePicker1.Date := Now;
    DateTimePicker1.Tag := ARow;
    CanSelect := False;
  end
  else
  begin
    DateTimePicker1.Visible := False;
    CanSelect := True;
  end;
end;

procedure TForm1.DateTimePicker1Change(Sender: TObject);
begin
  StringGrid1.Cells[0, DateTimePicker1.Tag] := DateToStr(DateTimePicker1.Date);
    StringGrid1.Cells[0, StringGrid1.Row] := DateTimeToStr(DateTimePicker1.Date);
  DateTimePicker1.Visible := False;
end;

end.

