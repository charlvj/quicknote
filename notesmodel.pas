unit notesmodel;
{$MODE objfpc}{$H+}
interface
    
uses
    SysUtils, Classes, strutils;
    

type
    TNote = record
        date : TDateTime;
        text : string;
    end;
    PNote = ^TNote;

    TNotes = class
    private
        _notes : TFPList;
    public
        constructor Create();
        destructor Destroy; override;

        function addNote(text: string):PNote; overload;
        function addNote(date: TDateTime; text: string) : PNote; overload;

        function getCount : integer;
        function getNote(idx : integer) : PNote;

        property notes[idx : integer] : PNote read getNote; default;
    published
        property count : integer read getCount;
    end;


    TNotesFile = class
    private
        _directory : string;
        _filename : string;

        function getFilename : string;
    public
        constructor Create(); overload;
        constructor Create(directory, filename : string); overload;
        destructor Destroy(); override;

        procedure save(notes : TNotes);
        procedure load(notes : TNotes);
    end;

implementation
    
constructor TNotes.Create();
begin
    _notes := TFPList.create();
end;

destructor TNotes.Destroy;
begin
    freeAndNil(_notes);
end;


function TNotes.addNote(text: string):PNote;
begin
    result := addNote(date, text);
end;


function TNotes.addNote(date: TDateTime; text: string) : PNote;
var
    note : PNote;
begin
    note := new(PNote);
    note^.date := date;
    note^.text := text;
    _notes.add(note);

    result := note;
end;

function TNotes.getCount() : integer;
begin
    result := _notes.count;
end;


function TNotes.getNote(idx : integer) : PNote;
begin
    result := _notes[idx];
end;



constructor TNotesFile.Create();
begin
    _directory := getUserDir + '.quicknotes/';
    _filename := 'notes.quicknotes';
end;


constructor TNotesFile.Create(directory, filename : string);
begin
    _directory := directory;
    _filename := filename;
end;

destructor TNotesFile.Destroy();
begin
    
end;


function TNotesFile.getFilename : string;
begin
    result := _directory + _filename;
end;

procedure TNotesFile.save(notes : TNotes);
var 
    counter : integer;
    note : PNote;
    outputFile : text;
begin
    if not directoryExists(_directory) then
        createDir(_directory);

    assign(outputFile, getFilename());
    rewrite(outputFile);
    for counter := 0 to notes.count - 1 do
    begin
        note := notes[counter];
        writeln(outputFile, 
                dateToStr(note^.date),
                #9,
                note^.text);
    end;
    close(outputFile);
end;

procedure TNotesFile.load(notes : TNotes);
var
    inputFile : text;
    line : string;
    tabPos : integer;
    dateStr, text : string;
begin
    if fileExists(getFilename()) then
    begin
        assign(inputFile, getFilename());
        reset(inputFile);

        while not eof(inputFile) do
        begin
            readln(inputFile, line);

            tabPos := npos(#9, line, 1);
            dateStr := midStr(line, 1, tabPos);
            text := midStr(line, tabPos + 1, length(line) - tabPos);

            notes.addNote(strToDate(dateStr), text);
        end;

        close(inputFile);
    end;
end;

begin
    
end.